import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../services/audio_service.dart';

final audioServiceProvider = Provider((ref) => AudioService());

// 1. Usamos NotifierProvider en lugar del antiguo StateNotifierProvider
final playerProvider = NotifierProvider<PlayerNotifier, Song?>(() {
  return PlayerNotifier();
});

// 2. Heredamos de Notifier en lugar de StateNotifier
class PlayerNotifier extends Notifier<Song?> {
  // 3. El estado inicial se define sobreescribiendo el método build()
  @override
  Song? build() {
    return null;
  }

  void playSong(Song song) {
    state = song;
    // 'ref' ya viene heredado de la clase padre Notifier, lo usamos directamente
    ref.read(audioServiceProvider).play(song.path);
  }

  void pause() {
    ref.read(audioServiceProvider).pause();
  }
}
