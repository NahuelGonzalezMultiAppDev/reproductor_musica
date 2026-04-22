import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/song_tile.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final searchText = ref.watch(searchProvider);
    final songs = ref.watch(songsProvider);
    final search = ref.watch(searchProvider);

    final filteredSongs = songs.where((song) {
      return song.title.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      appBar: AppBar(
        title: const Text(
          "Biblioteca",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 🔍 BUSCADOR
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  style: const TextStyle(color: Colors.white),

                  onChanged: (value) {
                    ref.read(searchProvider.notifier).state = value;
                  },

                  decoration: InputDecoration(
                    hintText: "Buscar canción, artista...",
                    hintStyle: const TextStyle(color: Colors.white54),

                    prefixIcon: const Icon(Icons.search, color: Colors.white54),

                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        ref.read(searchProvider.notifier).state = "";
                      },
                    ),

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
                          Tab(text: "Canciones"),
                          Tab(text: "Álbumes"),
                          Tab(text: "Artistas"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            filteredSongs.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No se encontraron canciones",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 90),
                                    itemCount: filteredSongs.length,
                                    itemBuilder: (context, index) {
                                      return SongTile(
                                        song: filteredSongs[index],
                                        playlist: filteredSongs,
                                        index: index,
                                      );
                                    },
                                  ),

                            const Center(
                              child: Text(
                                "Álbumes",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const Center(
                              child: Text(
                                "Artistas",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (player.currentSong != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  );
                },
                child: Container(
                  height: 75,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      StreamBuilder<Duration>(
                        stream: ref.read(audioServiceProvider).positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration?>(
                            stream: ref
                                .read(audioServiceProvider)
                                .durationStream,
                            builder: (context, snapshot2) {
                              final duration = snapshot2.data ?? Duration.zero;

                              double progress = 0;
                              if (duration.inSeconds > 0) {
                                progress =
                                    position.inSeconds / duration.inSeconds;
                              }

                              return LinearProgressIndicator(
                                value: progress,
                                minHeight: 3,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.purpleAccent,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.music_note),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                player.currentSong!.title,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                player.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                ref.read(playerProvider.notifier).togglePlay();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
