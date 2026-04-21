import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.primaries[index % Colors.primaries.length],
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),

      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: const Text(
        "Artista • 3:45",
        style: TextStyle(color: Colors.white54),
      ),

      trailing: const Icon(Icons.more_vert, color: Colors.white70),

      onTap: () {
        ref.read(playerProvider.notifier).playSong(playlist, index);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      },
    );
  }
}
