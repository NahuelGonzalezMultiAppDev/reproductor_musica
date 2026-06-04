import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';

class ListasScreen extends ConsumerWidget {
  const ListasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Biblioteca',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: cs.onSurface),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: libraryAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.tealAccent)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.redAccent))),
        data: (library) {
          if (library.playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_music,
                      color: cs.onSurface.withOpacity(0.2), size: 64),
                  const SizedBox(height: 16),
                  Text('No hay listas de reproducción.\nToca + para crear una.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.4), fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: library.playlists.length,
            itemBuilder: (ctx, i) =>
                _PlaylistTile(playlist: library.playlists[i]),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceVariant,
        title: Text('Nueva lista', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Nombre de la lista',
            hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(libraryProvider.notifier).createPlaylist(name);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text('Crear', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }
}

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({required this.playlist, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsInPlaylistProvider(playlist.id)); // List<Song>
    final playerState = ref.watch(playerProvider); // PlayerState (direct)
    final playerNotifier = ref.read(playerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    void _playAt(int index, List<Song> list) {
      if (list.isEmpty || index < 0 || index >= list.length) return;
      playerNotifier.playSong(list, index);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reproduciendo "${list[index].title}"'),
          backgroundColor: cs.primary,
          duration: const Duration(seconds: 2),
        ));
      }
    }

    Future<void> _removeSong(String songId, String songTitle) async {
      await ref
          .read(libraryProvider.notifier)
          .removeSongFromPlaylist(playlist.id, songId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Eliminada "$songTitle" de "${playlist.name}"'),
          duration: const Duration(seconds: 2),
        ));
      }
    }

    void _toggleShuffleAndPlay() {
      // Toggle shuffle flag in player state
      playerNotifier.toggleShuffle();

      // Play shuffled copy immediately
      if (songs.isEmpty) return;
      final shuffled = List<Song>.from(songs);
      shuffled.shuffle();
      _playAt(0, shuffled);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name, style: TextStyle(color: cs.onSurface)),
        actions: [
          IconButton(
            tooltip: 'Aleatoria',
            icon: Icon(Icons.shuffle, color: cs.onSurface),
            onPressed: songs.isEmpty ? null : _toggleShuffleAndPlay,
          ),
        ],
      ),
      body: songs.isEmpty
          ? Center(
              child: Text('No hay canciones en esta lista',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: songs.length,
              itemBuilder: (ctx, i) {
                final s = songs[i];

                // Determine if this song is the one currently playing
                final current = playerState.currentSong; // Song? or null
                final bool isCurrent = current != null && current.id == s.id;

                // Check if the player's playlist matches this playlist (same ids in same order)
                bool isSamePlaylist = false;
                final playerList = playerState.playlist;
                if (playerList.length == songs.length) {
                  isSamePlaylist = true;
                  for (int k = 0; k < songs.length; k++) {
                    if (playerList[k].id != songs[k].id) {
                      isSamePlaylist = false;
                      break;
                    }
                  }
                }

                final tileColor =
                    isCurrent ? cs.primary.withOpacity(0.12) : null;
                final leadingIcon = isCurrent
                    ? Icon(Icons.equalizer, color: cs.primary)
                    : Icon(Icons.music_note,
                        color: cs.onSurface.withOpacity(0.7));

                final key = ValueKey(s.id);

                return Dismissible(
                  key: key,
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Eliminar canción'),
                            content: Text(
                                '¿Eliminar "${s.title}" de "${playlist.name}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancelar')),
                              TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Eliminar')),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    _removeSong(s.id, s.title);
                  },
                  child: ListTile(
                    tileColor: tileColor,
                    leading: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: leadingIcon),
                    title: Text(s.title, style: TextStyle(color: cs.onSurface)),
                    subtitle: Text(s.artist ?? '',
                        style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          IconButton(
                            icon: Icon(
                              playerState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: cs.onSurface.withOpacity(0.9),
                            ),
                            onPressed: () => playerNotifier.togglePlay(),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.play_arrow,
                                color: cs.onSurface.withOpacity(0.8)),
                            onPressed: () {
                              if (isSamePlaylist) {
                                _playAt(i, playerState.playlist);
                              } else {
                                _playAt(i, songs);
                              }
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: cs.onSurface.withOpacity(0.4)),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Eliminar canción'),
                                    content: Text(
                                        '¿Eliminar "${s.title}" de "${playlist.name}"?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text('Cancelar')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text('Eliminar')),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (confirmed) await _removeSong(s.id, s.title);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      if (isCurrent) {
                        playerNotifier.togglePlay();
                      } else {
                        _playAt(i, songs);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsInPlaylistProvider(playlist.id));
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: playlist.isSystem
                ? [cs.primary, cs.surface]
                : [cs.secondary, cs.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(playlist.isSystem ? Icons.favorite : Icons.playlist_play,
            color: cs.onPrimary),
      ),
      title: Text(playlist.name,
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      subtitle: Text('${songs.length} canción${songs.length != 1 ? 'es' : ''}',
          style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
      // Al tocar: abrir pantalla de detalle (no reproducir)
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaylistDetailScreen(playlist: playlist),
          ),
        );
      },
      // Trailing: botón play + (si aplica) botón borrar
      trailing: playlist.isSystem
          ? IconButton(
              icon:
                  Icon(Icons.play_arrow, color: cs.onSurface.withOpacity(0.7)),
              onPressed: songs.isNotEmpty
                  ? () {
                      ref.read(playerProvider.notifier).playSong(songs, 0);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Reproduciendo "${playlist.name}"'),
                        backgroundColor: cs.primary,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  : null,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow,
                      color: cs.onSurface.withOpacity(0.7)),
                  onPressed: songs.isNotEmpty
                      ? () {
                          ref.read(playerProvider.notifier).playSong(songs, 0);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Reproduciendo "${playlist.name}"'),
                            backgroundColor: cs.primary,
                            duration: const Duration(seconds: 2),
                          ));
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: cs.onSurface.withOpacity(0.3)),
                  onPressed: () async => await ref
                      .read(libraryProvider.notifier)
                      .deletePlaylist(playlist.id),
                ),
              ],
            ),
    );
  }
}
