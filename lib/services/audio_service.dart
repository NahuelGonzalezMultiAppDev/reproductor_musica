import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();

  Future<void> play(String path, {String? title, String? artist}) async {
    if (path.startsWith('http')) {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(path),
          tag: MediaItem(
            id: path,
            title: title ?? 'Canción',
            artist: artist ?? 'Desconocido',
          ),
        ),
      );
    } else {
      await player.setAudioSource(
        AudioSource.file(
          path,
          tag: MediaItem(
            id: path,
            title: title ?? 'Canción local',
            artist: artist ?? 'Local',
          ),
        ),
      );
    }

    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  void dispose() {}
}
