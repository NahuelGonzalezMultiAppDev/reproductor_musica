import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/song.dart';
import '../services/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final searchProvider = StateProvider<String>((ref) => '');

final songsProvider = StateProvider<List<Song>>(
  (ref) => [
    Song(
      title: "Blinding Lights",
      path: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      artist: "Demo",
    ),
    Song(title: "Starboy", path: "", artist: "Demo"),
    Song(title: "Levitating", path: "", artist: "Demo"),
  ],
);

class PlayerState {
  final List<Song> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isRepeat;
  final bool isShuffle;

  PlayerState({
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

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});

class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    final audio = ref.read(audioServiceProvider);

    audio.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        next();
      }
    });

    audio.player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    return PlayerState();
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  Future<void> playSong(List<Song> songs, int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;

    final song = songs[index];

    state = state.copyWith(
      playlist: songs,
      currentIndex: index,
      isPlaying: true,
    );

    if (song.path.isNotEmpty) {
      await ref
          .read(audioServiceProvider)
          .play(song.path, title: song.title, artist: song.artist);
    }
  }

  Future<void> togglePlay() async {
    final audio = ref.read(audioServiceProvider);

    if (state.isPlaying) {
      await audio.pause();
    } else {
      await audio.player.play();
    }
  }

  Future<void> next() async {
    if (state.playlist.isEmpty) return;

    int nextIndex;

    if (state.isRepeat) {
      nextIndex = state.currentIndex;
    } else if (state.isShuffle) {
      if (state.playlist.length == 1) {
        nextIndex = state.currentIndex;
      } else {
        do {
          nextIndex = Random().nextInt(state.playlist.length);
        } while (nextIndex == state.currentIndex);
      }
    } else {
      nextIndex = (state.currentIndex + 1) % state.playlist.length;
    }

    final nextSong = state.playlist[nextIndex];

    state = state.copyWith(currentIndex: nextIndex, isPlaying: true);

    if (nextSong.path.isNotEmpty) {
      await ref.read(audioServiceProvider).play(nextSong.path);
    }
  }

  Future<void> previous() async {
    if (state.playlist.isEmpty) return;

    int prevIndex = state.currentIndex - 1;

    if (prevIndex < 0) {
      prevIndex = state.playlist.length - 1;
    }

    final prevSong = state.playlist[prevIndex];

    state = state.copyWith(currentIndex: prevIndex, isPlaying: true);

    if (prevSong.path.isNotEmpty) {
      await ref.read(audioServiceProvider).play(prevSong.path);
    }
  }

  Future<void> pickAndAddSong() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      final newSong = Song(title: file.name, path: file.path!, artist: "Local");

      final currentSongs = ref.read(songsProvider);
      ref.read(songsProvider.notifier).state = [...currentSongs, newSong];
    }
  }
}
