import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  final _skipNextController = StreamController<void>.broadcast();
  final _skipPreviousController = StreamController<void>.broadcast();

  Stream<void> get onSkipNext => _skipNextController.stream;
  Stream<void> get onSkipPrevious => _skipPreviousController.stream;

  AudioPlayerHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playFromPath(String path,
      {String? title, String? artist}) async {
    final item = MediaItem(
      id: path,
      title: title ?? 'Canción',
      artist: artist ?? '',
    );
    mediaItem.add(item);
    final source = path.startsWith('http')
        ? AudioSource.uri(Uri.parse(path), tag: item)
        : AudioSource.file(path, tag: item);
    await player.setAudioSource(source);
    await player.play();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async => _skipNextController.add(null);

  @override
  Future<void> skipToPrevious() async => _skipPreviousController.add(null);

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }

  void dispose() {
    _skipNextController.close();
    _skipPreviousController.close();
    player.dispose();
  }
}
