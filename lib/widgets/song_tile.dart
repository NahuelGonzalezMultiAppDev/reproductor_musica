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
    final cs = Theme.of(context).colorScheme;
    final player = ref.watch(playerProvider);
    final isPlaying = player.currentSong?.id == song.id && player.isPlaying;
    final isCurrent = player.currentSong?.id == song.id;

    final updatedSong = ref
            .watch(libraryProvider)
            .value
            ?.songs
            .where((s) => s.id == song.id)
            .firstOrNull ??
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
                ? [cs.primary, cs.surface]
                : [cs.surfaceVariant, cs.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isPlaying
            ? _AnimatedEqualizer(color: cs.primary)
            : Icon(Icons.music_note,
                color: cs.onSurface.withOpacity(0.5), size: 22),
      ),
      title: Text(updatedSong.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: isCurrent ? cs.primary : cs.onSurface,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(
          [
            updatedSong.artist ?? 'Desconocido',
            if (updatedSong.album != null) updatedSong.album!
          ].join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
                updatedSong.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: updatedSong.isFavorite
                    ? Colors.redAccent
                    : cs.onSurface.withOpacity(0.3),
                size: 20),
            onPressed: () async => await ref
                .read(libraryProvider.notifier)
                .toggleFavorite(updatedSong.id),
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: cs.onSurface.withOpacity(0.3), size: 20),
            onPressed: () => _showOptions(context, ref, updatedSong),
          ),
        ],
      ),
      onTap: () async =>
          await ref.read(playerProvider.notifier).playSong(playlist, index),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Song song) {
    final cs = Theme.of(context).colorScheme;
    final playlists = ref
            .read(libraryProvider)
            .value
            ?.playlists
            .where((p) => !p.isSystem)
            .toList() ??
        [];

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceVariant,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(song.title,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  textAlign: TextAlign.center),
            ),
            Divider(color: cs.onSurface.withOpacity(0.1)),
            if (playlists.isNotEmpty) ...[
              ListTile(
                  leading: Icon(Icons.playlist_add,
                      color: cs.onSurface.withOpacity(0.7)),
                  title: Text('Agregar a lista',
                      style: TextStyle(color: cs.onSurface.withOpacity(0.7)))),
              ...playlists.map((p) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                    leading: Icon(Icons.playlist_play,
                        color: cs.onSurface.withOpacity(0.4), size: 20),
                    title: Text(p.name,
                        style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                    onTap: () async {
                      await ref
                          .read(libraryProvider.notifier)
                          .addSongToPlaylist(p.id, song.id);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Agregada a "${p.name}"'),
                          backgroundColor: cs.primary,
                        ));
                      }
                    },
                  )),
              Divider(color: cs.onSurface.withOpacity(0.1)),
            ],
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

class _AnimatedEqualizer extends StatefulWidget {
  final Color color;
  const _AnimatedEqualizer({required this.color});

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
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
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
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final heights = [0.4, 0.8, 0.6];
          final h = heights[i] + (_ctrl.value * 0.4 * (i % 2 == 0 ? 1 : -1));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              width: 4,
              height: 20 * h.clamp(0.2, 1.0),
              decoration: BoxDecoration(
                  color: widget.color, borderRadius: BorderRadius.circular(2)),
            ),
          );
        }),
      ),
    );
  }
}
