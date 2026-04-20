import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Song> mockSongs = [
    Song(title: "Canción 1", path: "/storage/emulated/0/Music/song1.mp3"),
    Song(title: "Canción 2", path: "/storage/emulated/0/Music/song2.mp3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: ListView.builder(
        itemCount: mockSongs.length,
        itemBuilder: (context, index) {
          return SongTile(song: mockSongs[index]);
        },
      ),
    );
  }
}