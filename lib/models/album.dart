import 'genre.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final int? year;
  final String? coverPath;
  final Genre? genre;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.year,
    this.coverPath,
    this.genre,
  });
}
