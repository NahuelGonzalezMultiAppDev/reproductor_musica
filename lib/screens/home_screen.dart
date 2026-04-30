import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reproductor_musica/services/music_database.dart';

import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      appBar: AppBar(
        title: const Text(
          'Biblioteca',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await ref.read(playerProvider.notifier).pickAndAddSong();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Contenido principal ──────────────────────────────────────────────
          libraryAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error al cargar la biblioteca:\n$e',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
            data: (library) => _LibraryBody(library: library),
          ),

          // ── Mini reproductor flotante ────────────────────────────────────────
          if (player.currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MiniPlayer(player: player, ref: ref),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cuerpo con tabs: Canciones / Álbumes / Artistas
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryBody extends ConsumerStatefulWidget {
  final MusicLibrary library;
  const _LibraryBody({required this.library});

  @override
  ConsumerState<_LibraryBody> createState() => _LibraryBodyState();
}

class _LibraryBodyState extends ConsumerState<_LibraryBody> {
  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredSongs = ref.watch(filteredSongsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // ── Buscador ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Buscar canción, artista...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '',
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Tabs ──────────────────────────────────────────────────────────────
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: Colors.purpleAccent,
                  labelColor: Colors.purpleAccent,
                  unselectedLabelColor: Colors.white70,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Canciones'),
                    Tab(text: 'Álbumes'),
                    Tab(text: 'Artistas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // ── Tab Canciones ──────────────────────────────────────
                      filteredSongs.isEmpty
                          ? _EmptyState(
                              icon: Icons.music_off,
                              message: searchQuery.isNotEmpty
                                  ? 'No se encontraron canciones'
                                  : 'No hay canciones.\nToca + para agregar una.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: filteredSongs.length,
                              itemBuilder: (ctx, i) => SongTile(
                                song: filteredSongs[i],
                                playlist: filteredSongs,
                                index: i,
                              ),
                            ),

                      // ── Tab Álbumes ────────────────────────────────────────
                      widget.library.albums.isEmpty
                          ? const _EmptyState(
                              icon: Icons.album,
                              message: 'No hay álbumes disponibles',
                            )
                          : _AlbumsGrid(albums: widget.library.albums),

                      // ── Tab Artistas ───────────────────────────────────────
                      widget.library.artists.isEmpty
                          ? const _EmptyState(
                              icon: Icons.person,
                              message: 'No hay artistas disponibles',
                            )
                          : _ArtistsList(artists: widget.library.artists),
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

// ─────────────────────────────────────────────────────────────────────────────
// Álbumes en cuadrícula
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumsGrid extends ConsumerWidget {
  final List albums;
  const _AlbumsGrid({required this.albums});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (ctx, i) {
        final album = albums[i];
        return GestureDetector(
          onTap: () {
            // Reproduce todas las canciones del álbum
            final songs = ref.read(songsByAlbumProvider(album.title));
            if (songs.isNotEmpty) {
              ref.read(playerProvider.notifier).playSong(songs, 0);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Color(0xFF0B0B1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child:
                      const Icon(Icons.album, color: Colors.white70, size: 40),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    album.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                Text(
                  album.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista de artistas
// ─────────────────────────────────────────────────────────────────────────────

class _ArtistsList extends ConsumerWidget {
  final List artists;
  const _ArtistsList({required this.artists});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: artists.length,
      itemBuilder: (ctx, i) {
        final artist = artists[i];
        final songs = ref.read(songsByArtistProvider(artist.name));
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purpleAccent.withOpacity(0.3),
            child: Text(
              artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(artist.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${songs.length} canción${songs.length != 1 ? 'es' : ''}',
            style: const TextStyle(color: Colors.white54),
          ),
          onTap: () {
            if (songs.isNotEmpty) {
              ref.read(playerProvider.notifier).playSong(songs, 0);
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío genérico
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini reproductor flotante
// ─────────────────────────────────────────────────────────────────────────────

class _MiniPlayer extends ConsumerWidget {
  final PlayerState player;
  // ignore: unused_field
  final WidgetRef ref;
  const _MiniPlayer({required this.player, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        height: 82,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // Barra de progreso
            StreamBuilder<Duration>(
              stream: audioService.positionStream,
              builder: (_, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: audioService.durationStream,
                  builder: (_, durSnap) {
                    final dur = durSnap.data ?? Duration.zero;
                    double progress = 0;
                    if (dur.inMilliseconds > 0) {
                      progress =
                          (pos.inMilliseconds / dur.inMilliseconds).clamp(0, 1);
                    }
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white10,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.tealAccent),
                      ),
                    );
                  },
                );
              },
            ),

            // Controles
            Expanded(
              child: Row(
                children: [
                  // Ícono de canción
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.tealAccent, Color(0xFF0B0B1A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                  const SizedBox(width: 12),

                  // Título y artista
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.currentSong!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          player.currentSong!.artist ?? 'Desconocido',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // Botones de control
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: () =>
                        ref.read(playerProvider.notifier).previous(),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                      ),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).togglePlay(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => ref.read(playerProvider.notifier).next(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
