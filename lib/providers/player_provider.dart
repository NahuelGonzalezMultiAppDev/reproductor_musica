import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/audio_service.dart';

final audioServiceProvider = Provider((ref) => AudioService());

final searchProvider = StateProvider<String>((ref) => '');

final songsProvider = StateProvider<List<Song>>(
  (ref) => [
    Song(title: "Blinding Lights", path: ""),
    Song(title: "Starboy", path: ""),
    Song(title: "Levitating", path: ""),
    Song(title: "Stay", path: ""),
    Song(title: "Industry Baby", path: ""),
    Song(title: "As It Was", path: ""),
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

  Song? get currentSong => playlist.isNotEmpty ? playlist[currentIndex] : null;

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
  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

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

  void playSong(List<Song> songs, int index) {
    final song = songs[index];

    state = state.copyWith(
      playlist: songs,
      currentIndex: index,
      isPlaying: true,
    );

    if (song.path.isNotEmpty) {
      ref.read(audioServiceProvider).play(song.path);
    }
  }

  void togglePlay() {
    final audio = ref.read(audioServiceProvider);

    if (state.isPlaying) {
      audio.pause();
    } else {
      audio.resume();
    }
  }

  void next() {
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
      ref.read(audioServiceProvider).play(nextSong.path);
    }
  }

  void previous() {
    if (state.playlist.isEmpty) return;

    int prevIndex = state.currentIndex - 1;

    if (prevIndex < 0) {
      prevIndex = state.playlist.length - 1;
    }

    final prevSong = state.playlist[prevIndex];

    state = state.copyWith(currentIndex: prevIndex, isPlaying: true);

    if (prevSong.path.isNotEmpty) {
      ref.read(audioServiceProvider).play(prevSong.path);
    }
  }
}
