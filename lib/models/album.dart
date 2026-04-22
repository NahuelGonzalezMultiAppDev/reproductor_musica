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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'cover_path': coverPath,
      'genre': genre?.label,
    };
  }

  factory Album.fromMap(Map<String, Object?> row) {
    final genreLabel = row['genre'] as String?;
    return Album(
      id: row['id'] as String,
      title: row['title'] as String,
      artist: row['artist'] as String,
      year: row['year'] as int?,
      coverPath: row['cover_path'] as String?,
      genre: genreLabel == null ? null : Genre.fromLabel(genreLabel),
    );
  }
}
