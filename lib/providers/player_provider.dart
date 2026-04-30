import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/database_helper.dart';
import 'library_provider.dart';

// ─── Audio Service ────────────────────────────────────────────────────────────

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ─── Player State ─────────────────────────────────────────────────────────────

class PlayerState {
  final List<Song> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isRepeat;
  final bool isShuffle;

  const PlayerState({
    this.playlist = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isRepeat = false,
    this.isShuffle = false,
  });

  Song? get currentSong {
    if (playlist.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= playlist.length) return null;
    return playlist[currentIndex];
  }

  PlayerState copyWith({
    List<Song>? playlist,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffle,
    bool? isRepeat,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}

// ─── Player Notifier ──────────────────────────────────────────────────────────

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);

class PlayerNotifier extends Notifier<PlayerState> {
  AudioService get _audio => ref.read(audioServiceProvider);

  @override
  PlayerState build() {
    // Escucha fin de canción → avanza automáticamente
    _audio.player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        next();
      }
    });

    // Sincroniza isPlaying con el stream real del player
    _audio.player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    return const PlayerState();
  }

  // ── Reproducción ────────────────────────────────────────────────────────────

  Future<void> playSong(List<Song> songs, int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;

    final song = songs[index];

    state = state.copyWith(
      playlist: songs,
      currentIndex: index,
      isPlaying: true,
    );

    if (song.path.isNotEmpty) {
      await _audio.play(song.path, title: song.title, artist: song.artist);
      // Incrementa play count en BD y notifica al libraryProvider
      await DatabaseHelper.instance.incrementSongPlayCount(song.id);
      await ref.read(libraryProvider.notifier).incrementPlayCount(song.id);
    }
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _audio.pause();
    } else {
      await _audio.player.play();
    }
  }

  Future<void> next() async {
    if (state.playlist.isEmpty) return;

    final int nextIndex;
    if (state.isRepeat) {
      nextIndex = state.currentIndex;
    } else if (state.isShuffle) {
      if (state.playlist.length == 1) {
        nextIndex = state.currentIndex;
      } else {
        int idx;
        do {
          idx = Random().nextInt(state.playlist.length);
        } while (idx == state.currentIndex);
        nextIndex = idx;
      }
    } else {
      nextIndex = (state.currentIndex + 1) % state.playlist.length;
    }

    final nextSong = state.playlist[nextIndex];

    state = state.copyWith(currentIndex: nextIndex, isPlaying: true);

    if (nextSong.path.isNotEmpty) {
      await _audio.play(nextSong.path,
          title: nextSong.title, artist: nextSong.artist);
      await DatabaseHelper.instance.incrementSongPlayCount(nextSong.id);
      await ref.read(libraryProvider.notifier).incrementPlayCount(nextSong.id);
    }
  }

  Future<void> previous() async {
    if (state.playlist.isEmpty) return;

    final prevIndex = state.currentIndex == 0
        ? state.playlist.length - 1
        : state.currentIndex - 1;

    final prevSong = state.playlist[prevIndex];

    state = state.copyWith(currentIndex: prevIndex, isPlaying: true);

    if (prevSong.path.isNotEmpty) {
      await _audio.play(prevSong.path,
          title: prevSong.title, artist: prevSong.artist);
    }
  }

  // ── Controles ────────────────────────────────────────────────────────────────

  void toggleShuffle() => state = state.copyWith(isShuffle: !state.isShuffle);
  void toggleRepeat() => state = state.copyWith(isRepeat: !state.isRepeat);

  // ── Agregar canción desde archivo ────────────────────────────────────────────

  Future<void> pickAndAddSong() async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;
    final newSong = Song(
      title: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''), // sin extensión
      path: file.path!,
      artist: 'Desconocido',
      dateAdded: DateTime.now(),
    );

    // Persiste en SQLite y actualiza el estado de la librería
    await ref.read(libraryProvider.notifier).addSong(newSong);
  }

  // ── Toggle favorito (delega al libraryProvider) ───────────────────────────────

  Future<void> toggleFavorite(String songId) async {
    await ref.read(libraryProvider.notifier).toggleFavorite(songId);

    // Refleja el cambio en la playlist activa
    final lib = ref.read(libraryProvider).value;
    if (lib == null) return;
    final updatedPlaylist = state.playlist.map((s) {
      final updated = lib.songs.where((ls) => ls.id == s.id).firstOrNull;
      return updated ?? s;
    }).toList();
    state = state.copyWith(playlist: updatedPlaylist);
  }
}
