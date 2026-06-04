import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/artist.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final Artist artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final songs = ref.watch(songsByArtistProvider(artist.name));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(artist.name,
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
          // Header del artista
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: cs.primary.withOpacity(0.2),
                  child: Text(
                    artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: cs.primary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artist.name,
                          style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          '${songs.length} canción${songs.length != 1 ? 'es' : ''}',
                          style:
                              TextStyle(color: cs.onSurface.withOpacity(0.4))),
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
                        Text('No hay canciones de este artista',
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
