import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';

class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> playlist;
  final int index;

  const SongTile({
    super.key,
    required this.song,
    required this.playlist,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final isPlaying = player.currentSong?.id == song.id && player.isPlaying;
    final isCurrent = player.currentSong?.id == song.id;

    // Obtiene el estado actualizado de favorito desde la librería
    final libraryAsync = ref.watch(libraryProvider);
    final updatedSong =
        libraryAsync.value?.songs.where((s) => s.id == song.id).firstOrNull ??
            song;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: isCurrent
                ? [Colors.tealAccent, const Color(0xFF0B0B1A)]
                : [
                    Colors.purpleAccent.withOpacity(0.4),
                    const Color(0xFF0B0B1A)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isPlaying
            ? const _AnimatedEqualizer()
            : const Icon(Icons.music_note, color: Colors.white70, size: 22),
      ),
      title: Text(
        updatedSong.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? Colors.tealAccent : Colors.white,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        [
          updatedSong.artist ?? 'Desconocido',
          if (updatedSong.album != null) updatedSong.album!,
        ].join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorito
          IconButton(
            icon: Icon(
              updatedSong.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: updatedSong.isFavorite ? Colors.redAccent : Colors.white38,
              size: 20,
            ),
            onPressed: () async {
              await ref
                  .read(libraryProvider.notifier)
                  .toggleFavorite(updatedSong.id);
            },
          ),
          // Más opciones
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            onPressed: () => _showOptions(context, ref, updatedSong),
          ),
        ],
      ),
      onTap: () async {
        await ref.read(playerProvider.notifier).playSong(playlist, index);
      },
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Song song) {
    final playlists = ref
            .read(libraryProvider)
            .value
            ?.playlists
            .where((p) => !p.isSystem)
            .toList() ??
        [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título de la canción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                song.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(color: Colors.white10),

            // Agregar a lista
            if (playlists.isNotEmpty) ...[
              const ListTile(
                leading: Icon(Icons.playlist_add, color: Colors.white70),
                title: Text('Agregar a lista',
                    style: TextStyle(color: Colors.white70)),
              ),
              ...playlists.map(
                (p) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                  leading: const Icon(Icons.playlist_play,
                      color: Colors.white38, size: 20),
                  title: Text(p.name,
                      style: const TextStyle(color: Colors.white60)),
                  onTap: () async {
                    await ref
                        .read(libraryProvider.notifier)
                        .addSongToPlaylist(p.id, song.id);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregada a "${p.name}"'),
                          backgroundColor: Colors.tealAccent.shade700,
                        ),
                      );
                    }
                  },
                ),
              ),
              const Divider(color: Colors.white10),
            ],

            // Eliminar canción
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Eliminar canción',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await ref.read(libraryProvider.notifier).removeSong(song.id);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ecualizador animado para la canción en reproducción
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedEqualizer extends StatefulWidget {
  const _AnimatedEqualizer();

  @override
  State<_AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<_AnimatedEqualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            final heights = [0.4, 0.8, 0.6];
            final animated =
                heights[i] + (_ctrl.value * 0.4 * (i % 2 == 0 ? 1 : -1));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 4,
                height: 20 * animated.clamp(0.2, 1.0),
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
