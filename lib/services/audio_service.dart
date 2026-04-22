import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< Updated upstream
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
=======
class AudioService extends Notifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();

  @override
  AudioState build() {
    return AudioState();
  }

  /// Reproducir canción desde path real
  Future<void> play(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
      state = state.copyWith(isPlaying: true, currentPath: path, error: null);
    } catch (e) {
      // Evita crashes si el archivo falla
      state = state.copyWith(isPlaying: false, error: "No se pudo reproducir el archivo");
      print("Error al reproducir: $e");
    }
  }

  /// Pausar
  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  /// Reanudar
  Future<void> resume() async {
    await _player.play();
    state = state.copyWith(isPlaying: true);
  }

  /// Detener
  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, currentPath: null);
  }

  /// Buscar posición específica
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Cambiar volumen (0.0 a 1.0)
  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  /// Streams para la barra de progreso
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;

  /// Liberar recursos
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Estado del reproductor
class AudioState {
  final bool isPlaying;
  final String? currentPath;
  final String? error;

  AudioState({
    this.isPlaying = false,
    this.currentPath,
    this.error,
  });

  AudioState copyWith({
    bool? isPlaying,
    String? currentPath,
    String? error,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPath: currentPath ?? this.currentPath,
      error: error,
    );
  }
}

/// Provider para usar en toda la app
final audioServiceProvider = NotifierProvider<AudioService, AudioState>(
  AudioService.new,
);
>>>>>>> Stashed changes
