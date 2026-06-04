import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/album.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final Album album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final songs = ref.watch(songsByAlbumProvider(album.title));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(album.title,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          if (songs.isNotEmpty)
            IconButton(
              icon: Icon(Icons.play_circle, color: cs.primary, size: 32),
              onPressed: () =>
                  ref.read(playerProvider.notifier).playSong(songs, 0),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header del álbum
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(Icons.album, color: cs.onPrimary, size: 50),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.title,
                          style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(album.artist,
                          style:
                              TextStyle(color: cs.onSurface.withOpacity(0.6))),
                      if (album.year != null) ...[
                        const SizedBox(height: 4),
                        Text('${album.year}',
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.4))),
                      ],
                      const SizedBox(height: 4),
                      Text(
                          '${songs.length} canción${songs.length != 1 ? 'es' : ''}',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.4),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: cs.onSurface.withOpacity(0.1)),

          // Lista de canciones
          Expanded(
            child: songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_off,
                            color: cs.onSurface.withOpacity(0.2), size: 48),
                        const SizedBox(height: 12),
                        Text('No hay canciones en este álbum',
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.4))),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (ctx, i) =>
                        SongTile(song: songs[i], playlist: songs, index: i),
                  ),
          ),
        ],
      ),
    );
  }
}
