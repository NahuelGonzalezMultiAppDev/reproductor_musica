import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

class SongTile extends ConsumerWidget {
  final Song song;

  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(song.title),
      onTap: () {
        ref.read(playerProvider.notifier).playSong(song);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen()),
        );
      },
    );
  }
}