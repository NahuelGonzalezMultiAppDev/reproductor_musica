import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final query = ref.watch(searchQueryProvider);
    final songs = ref.watch(filteredSongsProvider);
    final allArtists = ref.watch(allArtistsProvider);
    final allAlbums = ref.watch(allAlbumsProvider);

    final artists = query.isEmpty
        ? []
        : allArtists
            .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    final albums = query.isEmpty
        ? []
        : allAlbums
            .where((a) =>
                a.title.toLowerCase().contains(query.toLowerCase()) ||
                a.artist.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              style: TextStyle(color: cs.onSurface),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Canciones, artistas, álbumes...',
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                prefixIcon:
                    Icon(Icons.search, color: cs.onSurface.withOpacity(0.4)),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close,
                            color: cs.onSurface.withOpacity(0.4)),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.4),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _EmptySearch()
                : (songs.isEmpty && artists.isEmpty && albums.isEmpty)
                    ? const _NoResults()
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 90),
                        children: [
                          if (songs.isNotEmpty) ...[
                            _SectionHeader(
                                icon: Icons.music_note,
                                title: 'Canciones',
                                count: songs.length),
                            ...songs.map((s) => SongTile(
                                song: s,
                                playlist: songs,
                                index: songs.indexOf(s))),
                          ],
                          if (artists.isNotEmpty) ...[
                            _SectionHeader(
                                icon: Icons.person,
                                title: 'Artistas',
                                count: artists.length),
                            ...artists.map((a) {
                              final artistSongs =
                                  ref.read(songsByArtistProvider(a.name));
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  child: Text(a.name[0].toUpperCase(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(a.name,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                                subtitle: Text(
                                    '${artistSongs.length} canción${artistSongs.length != 1 ? 'es' : ''}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5))),
                                onTap: () {
                                  if (artistSongs.isNotEmpty) {
                                    ref
                                        .read(playerProvider.notifier)
                                        .playSong(artistSongs, 0);
                                  }
                                },
                              );
                            }),
                          ],
                          if (albums.isNotEmpty) ...[
                            _SectionHeader(
                                icon: Icons.album,
                                title: 'Álbumes',
                                count: albums.length),
                            ...albums.map((a) {
                              final albumSongs =
                                  ref.read(songsByAlbumProvider(a.title));
                              return ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [cs.primary, cs.surface],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(Icons.album,
                                      color: cs.onPrimary, size: 24),
                                ),
                                title: Text(a.title,
                                    style: TextStyle(color: cs.onSurface)),
                                subtitle: Text(a.artist,
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.5))),
                                onTap: () {
                                  if (albumSongs.isNotEmpty) {
                                    ref
                                        .read(playerProvider.notifier)
                                        .playSong(albumSongs, 0);
                                  }
                                },
                              );
                            }),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  const _SectionHeader(
      {required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(color: cs.primary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final library = ref.watch(libraryProvider).value;
    final totalSongs = library?.songs.length ?? 0;
    final totalArtists = library?.artists.length ?? 0;
    final totalAlbums = library?.albums.length ?? 0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: cs.onSurface.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text('Buscá canciones, artistas o álbumes',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.4), fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(icon: Icons.music_note, label: '$totalSongs canciones'),
              const SizedBox(width: 8),
              _StatChip(icon: Icons.person, label: '$totalArtists artistas'),
              const SizedBox(width: 8),
              _StatChip(icon: Icons.album, label: '$totalAlbums álbumes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.onSurface.withOpacity(0.4), size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              color: cs.onSurface.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text('Sin resultados',
              style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 8),
          Text('Intentá con otro nombre',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.4), fontSize: 14)),
        ],
      ),
    );
  }
}
