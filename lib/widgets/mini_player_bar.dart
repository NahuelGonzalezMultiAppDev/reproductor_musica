import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;

    if (song == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Portada / ícono
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: song.artwork != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(song.artwork!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.music_note, color: cs.primary)),
                    )
                  : Icon(Icons.music_note, color: cs.primary),
            ),
            // Título y artista
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (song.artist != null && song.artist!.isNotEmpty)
                    Text(
                      song.artist!,
                      style: TextStyle(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Botón play/pause
            IconButton(
              onPressed: () =>
                  ref.read(playerProvider.notifier).togglePlay(),
              icon: Icon(
                playerState.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: cs.primary,
                size: 32,
              ),
            ),
            // Botón siguiente
            IconButton(
              onPressed: () => ref.read(playerProvider.notifier).next(),
              icon: Icon(Icons.skip_next, color: cs.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
