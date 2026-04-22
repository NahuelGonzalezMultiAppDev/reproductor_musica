import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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

/// Servicio de audio
class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  AudioState _state = AudioState();
  AudioState get state => _state;

  /// Reproducir canción desde path real
  Future<void> play(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
      _state = _state.copyWith(isPlaying: true, currentPath: path, error: null);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isPlaying: false, error: "No se pudo reproducir el archivo");
      notifyListeners();
      print("Error al reproducir: $e");
    }
  }

  /// Pausar
  Future<void> pause() async {
    await _player.pause();
    _state = _state.copyWith(isPlaying: false);
    notifyListeners();
  }

  /// Reanudar
  Future<void> resume() async {
    await _player.play();
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
  }

  /// Detener
  Future<void> stop() async {
    await _player.stop();
    _state = _state.copyWith(isPlaying: false, currentPath: null);
    notifyListeners();
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Provider para usar en toda la app
final audioServiceProvider = ChangeNotifierProvider<AudioService>(
  (ref) => AudioService(),
);
