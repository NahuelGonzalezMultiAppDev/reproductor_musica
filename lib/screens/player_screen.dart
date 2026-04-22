import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final audioService = ref.read(audioServiceProvider);
    final currentSong = playerState.currentSong;

    if (currentSong == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF061A1A),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text(
            'No hay canción seleccionada',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'REPRODUCIENDO AHORA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 320,
                  maxHeight: 320,
                ),
                height: MediaQuery.of(context).size.width * 0.72,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    size: 90,
                    color: Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                currentSong.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentSong.artist ?? 'Desconocido',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 28),
              StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration?>(
                    stream: audioService.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;

                      double value = 0;
                      if (duration.inMilliseconds > 0) {
                        value =
                            position.inMilliseconds / duration.inMilliseconds;
                        if (value > 1) value = 1;
                      }

                      return Column(
                        children: [
                          Slider(
                            value: value,
                            onChanged: (newValue) async {
                              if (duration.inMilliseconds > 0) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (duration.inMilliseconds * newValue)
                                          .toInt(),
                                );
                                await audioService.player.seek(newPosition);
                              }
                            },
                            activeColor: Colors.tealAccent,
                            inactiveColor: Colors.white24,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(playerProvider.notifier).toggleShuffle();
                    },
                    icon: Icon(
                      Icons.shuffle,
                      color: playerState.isShuffle
                          ? Colors.tealAccent
                          : Colors.white,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(playerProvider.notifier).previous();
                    },
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await ref.read(playerProvider.notifier).togglePlay();
                      },
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 38,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(playerProvider.notifier).next();
                    },
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(playerProvider.notifier).toggleRepeat();
                    },
                    icon: Icon(
                      Icons.repeat,
                      color: playerState.isRepeat
                          ? Colors.tealAccent
                          : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
