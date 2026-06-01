import 'package:just_audio/just_audio.dart';
import 'audio_handler.dart';

class PlayerAudioService {
  final AudioPlayerHandler _handler;

  PlayerAudioService(this._handler);

  AudioPlayer get player => _handler.player;

  Future<void> play(String path, {String? title, String? artist}) =>
      _handler.playFromPath(path, title: title, artist: artist);

  Future<void> pause() => _handler.pause();

  Future<void> stop() => _handler.stop();

  Stream<Duration> get positionStream => _handler.player.positionStream;
  Stream<Duration?> get durationStream => _handler.player.durationStream;

  void dispose() => _handler.dispose();
}
