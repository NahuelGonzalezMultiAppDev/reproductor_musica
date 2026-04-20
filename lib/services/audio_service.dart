import 'package:just_audio/just_audio.dart';

class AudioService {
  final player = AudioPlayer();

  Future<void> play(String path) async {
    await player.setFilePath(path);
    player.play();
  }

  void pause() {
    player.pause();
  }
}