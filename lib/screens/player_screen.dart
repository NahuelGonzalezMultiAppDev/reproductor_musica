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
    final cs = Theme.of(context).colorScheme;

    if (currentSong == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('No hay canción seleccionada'),
        ),
      );
    }

    return Scaffold(
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
                    icon: Icon(Icons.keyboard_arrow_down, color: cs.onSurface),
                  ),
                  Expanded(
                    child: Text('REPRODUCIENDO AHORA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                constraints:
                    const BoxConstraints(maxWidth: 320, maxHeight: 320),
                height: MediaQuery.of(context).size.width * 0.72,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(Icons.music_note,
                      size: 90, color: cs.onPrimary.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 28),
              Text(currentSong.title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(currentSong.artist ?? 'Desconocido',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6), fontSize: 18)),
              const SizedBox(height: 28),
              StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration?>(
                    stream: audioService.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      double value = duration.inMilliseconds > 0
                          ? (position.inMilliseconds / duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0;
                      return Column(
                        children: [
                          Slider(
                            value: value,
                            activeColor: cs.primary,
                            inactiveColor: cs.onSurface.withOpacity(0.2),
                            onChanged: (newValue) async {
                              if (duration.inMilliseconds > 0) {
                                await audioService.player.seek(Duration(
                                    milliseconds:
                                        (duration.inMilliseconds * newValue)
                                            .toInt()));
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position),
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.6))),
                                Text(_formatDuration(duration),
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.6))),
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
                    onPressed: () =>
                        ref.read(playerProvider.notifier).toggleShuffle(),
                    icon: Icon(Icons.shuffle,
                        color:
                            playerState.isShuffle ? cs.primary : cs.onSurface,
                        size: 28),
                  ),
                  IconButton(
                    onPressed: () async =>
                        await ref.read(playerProvider.notifier).previous(),
                    icon: Icon(Icons.skip_previous,
                        color: cs.onSurface, size: 42),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: cs.primary, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () async =>
                          await ref.read(playerProvider.notifier).togglePlay(),
                      icon: Icon(
                          playerState.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: cs.onPrimary,
                          size: 38),
                    ),
                  ),
                  IconButton(
                    onPressed: () async =>
                        await ref.read(playerProvider.notifier).next(),
                    icon: Icon(Icons.skip_next, color: cs.onSurface, size: 42),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(playerProvider.notifier).toggleRepeat(),
                    icon: Icon(Icons.repeat,
                        color: playerState.isRepeat ? cs.primary : cs.onSurface,
                        size: 28),
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
