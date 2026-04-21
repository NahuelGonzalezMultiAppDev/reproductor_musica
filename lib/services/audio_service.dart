import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();

  /// Reproducir canción
  Future<void> play(String path) async {
    try {
      await player.setFilePath(path);
      await player.play();
    } catch (e) {
      print("Error al reproducir: $e");
    }
  }

  ///  Pausar
  void pause() {
    player.pause();
  }

  ///  Reanudar
  void resume() {
    player.play();
  }

  ///  Detener
  void stop() {
    player.stop();
  }

  /// Streams para la barra de progreso
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  /// MUY IMPORTANTE(evita bugs y consumo de memoria)
  Future<void> dispose() async {
    await player.dispose();
  }
}
