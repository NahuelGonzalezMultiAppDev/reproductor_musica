import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Center(
        child: song == null
            ? const Text("No song playing")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(song.title, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(playerProvider.notifier).pause();
                    },
                    child: const Text("Pause"),
                  ),
                ],
              ),
      ),
    );
  }
}