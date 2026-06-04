import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../services/music_database.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';
import 'artist_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final libraryAsync = ref.watch(libraryProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: cs.onSurface),
            onPressed: () async =>
                await ref.read(playerProvider.notifier).pickAndAddSong(),
          ),
        ],
      ),
      body: Stack(
        children: [
          libraryAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent)),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.redAccent))),
            data: (library) => _LibraryBody(library: library),
          ),
          if (player.currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MiniPlayer(player: player),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LibraryBody extends ConsumerWidget {
  final MusicLibrary library;
  const _LibraryBody({required this.library});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredSongs = ref.watch(filteredSongsProvider);

    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            style: TextStyle(color: cs.onSurface),
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Buscar canción, artista...',
              hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
              prefixIcon:
                  Icon(Icons.search, color: cs.onSurface.withOpacity(0.4)),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close,
                          color: cs.onSurface.withOpacity(0.4)),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '',
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
        const SizedBox(height: 8),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: cs.primary,
                  labelColor: cs.primary,
                  unselectedLabelColor: cs.onSurface.withOpacity(0.6),
                  tabs: const [
                    Tab(text: 'Canciones'),
                    Tab(text: 'Artistas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // ── Canciones ──────────────────────────────────────────
                      filteredSongs.isEmpty
                          ? _EmptyState(
                              icon: Icons.music_off,
                              message: searchQuery.isNotEmpty
                                  ? 'No se encontraron canciones'
                                  : 'No hay canciones.\nToca + para agregar una.')
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: filteredSongs.length,
                              itemBuilder: (ctx, i) => SongTile(
                                song: filteredSongs[i],
                                playlist: filteredSongs,
                                index: i,
                              ),
                            ),

                      // ── Artistas ───────────────────────────────────────────
                      library.artists.isEmpty
                          ? const _EmptyState(
                              icon: Icons.person,
                              message:
                                  'No hay artistas.\nSe agregan automáticamente\ncuando agregás canciones.')
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: library.artists.length,
                              itemBuilder: (ctx, i) {
                                final artist = library.artists[i];
                                final songs = ref
                                    .read(songsByArtistProvider(artist.name));
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        cs.primary.withOpacity(0.2),
                                    child: Text(
                                      artist.name.isNotEmpty
                                          ? artist.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(artist.name,
                                      style: TextStyle(color: cs.onSurface)),
                                  subtitle: Text(
                                    '${songs.length} canción${songs.length != 1 ? 'es' : ''}',
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.5)),
                                  ),
                                  trailing: Icon(Icons.chevron_right,
                                      color: cs.onSurface.withOpacity(0.3)),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ArtistDetailScreen(artist: artist)),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.onSurface.withOpacity(0.2), size: 60),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.4), fontSize: 16)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini Reproductor
// ─────────────────────────────────────────────────────────────────────────────

class _MiniPlayer extends ConsumerWidget {
  final PlayerState player;
  const _MiniPlayer({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
      child: Container(
        height: 82,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            StreamBuilder<Duration>(
              stream: audioService.positionStream,
              builder: (_, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: audioService.durationStream,
                  builder: (_, durSnap) {
                    final dur = durSnap.data ?? Duration.zero;
                    double progress = dur.inMilliseconds > 0
                        ? (pos.inMilliseconds / dur.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0;
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: cs.onSurface.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.music_note, color: cs.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.currentSong!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text(player.currentSong!.artist ?? 'Desconocido',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.skip_previous, color: cs.onSurface),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).previous()),
                  Container(
                    decoration: BoxDecoration(
                        color: cs.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                          player.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: cs.onPrimary),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).togglePlay(),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.skip_next, color: cs.onSurface),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).next()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
