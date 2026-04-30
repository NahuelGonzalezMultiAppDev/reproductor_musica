import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';

class ListasScreen extends ConsumerWidget {
  const ListasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      appBar: AppBar(
        title: const Text(
          'Listas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: libraryAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.tealAccent)),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (library) {
          final playlists = library.playlists;

          if (playlists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_play, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No hay listas de reproducción.\nToca + para crear una.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: playlists.length,
            itemBuilder: (ctx, i) => _PlaylistTile(playlist: playlists[i]),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Nueva lista', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre de la lista',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(libraryProvider.notifier).createPlaylist(name);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child:
                const Text('Crear', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsInPlaylistProvider(playlist.id));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: playlist.isSystem
                ? [Colors.tealAccent, const Color(0xFF0B0B1A)]
                : [Colors.purpleAccent, const Color(0xFF0B0B1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          playlist.isSystem ? Icons.favorite : Icons.playlist_play,
          color: Colors.white,
        ),
      ),
      title: Text(
        playlist.name,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${songs.length} canción${songs.length != 1 ? 'es' : ''}',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: playlist.isSystem
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38),
              onPressed: () async {
                await ref
                    .read(libraryProvider.notifier)
                    .deletePlaylist(playlist.id);
              },
            ),
      onTap: () {
        if (songs.isNotEmpty) {
          ref.read(playerProvider.notifier).playSong(songs, 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reproduciendo "${playlist.name}"'),
              backgroundColor: Colors.tealAccent.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
