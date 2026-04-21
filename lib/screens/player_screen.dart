import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final progressProvider = StateProvider<double>((ref) => 84);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF021E1A),
      body: SafeArea(
        child: player.currentSong == null
            ? const Center(
                child: Text(
                  "No hay can ción seleccionada",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "REPRODUCIENDO\nAHORA",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // portada
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF67D3B3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 110,
                          color: Color(0xFF4AA88E),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // título y artista
                    Center(
                      child: Column(
                        children: [
                          Text(
                            player.currentSong!.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Siete • Horizontes",
                            style: TextStyle(
                              color: Color(0xFF7FD3C3),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // barra de progreso movible
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF67D3B3),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: const Color(0xFF67D3B3),
                            overlayColor: const Color(0x3367D3B3),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                          ),
                          child: Slider(
                            value: progress.clamp(0, 204),
                            min: 0,
                            max: 204,
                            onChanged: (value) {
                              ref.read(progressProvider.notifier).state = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(
                                  Duration(seconds: progress.toInt()),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF7FD3C3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                "3:24",
                                style: TextStyle(
                                  color: Color(0xFF7FD3C3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // controles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(
                          Icons.shuffle,
                          color: Colors.white,
                          size: 28,
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(playerProvider.notifier).previous();
                          },
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        Container(
                          width: 78,
                          height: 78,
                          decoration: const BoxDecoration(
                            color: Color(0xFF67D3B3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              ref.read(playerProvider.notifier).togglePlay();
                            },
                            icon: Icon(
                              player.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: const Color(0xFF021E1A),
                              size: 42,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(playerProvider.notifier).next();
                          },
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const Icon(Icons.repeat, color: Colors.white, size: 28),
                      ],
                    ),

                    const Spacer(),

                    // footer iconos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(
                          Icons.favorite_border,
                          color: Color(0xFF67D3B3),
                          size: 28,
                        ),
                        Icon(
                          Icons.queue_music,
                          color: Color(0xFF67D3B3),
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

String _formatTime(Duration d) {
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
}
