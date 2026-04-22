import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioTestScreen extends StatefulWidget {
  const AudioTestScreen({super.key});

  @override
  State<AudioTestScreen> createState() => _AudioTestScreenState();
}

class _AudioTestScreenState extends State<AudioTestScreen> {
  final AudioPlayer player = AudioPlayer();

  Future<void> playMusic() async {
    try {
      await player.setUrl(
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      );
      await player.play();
    } catch (e) {
      debugPrint('Error al reproducir: $e');
    }
  }

  Future<void> pauseMusic() async {
    await player.pause();
  }

  Future<void> stopMusic() async {
    await player.stop();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: playMusic,
              child: const Text('▶ Reproducir'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pauseMusic,
              child: const Text('⏸ Pausar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: stopMusic,
              child: const Text('⏹ Detener'),
            ),
          ],
        ),
      ),
    );
  }
}
