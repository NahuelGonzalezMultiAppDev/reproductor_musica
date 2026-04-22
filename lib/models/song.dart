import 'genre.dart';

class Song {
  final String id;
  final String title;
  final String path;
  final String? artist;
  final String? album;
  final Genre? genre;
  final int? year;
  final Duration? duration;
  final String? artwork;
  final int? trackNumber;
  final DateTime? dateAdded;
  final int playCount;
  final bool isFavorite;

  Song({
    String? id,
    required this.title,
    required this.path,
    this.artist,
    this.album,
    this.genre,
    this.year,
    this.duration,
    this.artwork,
    this.trackNumber,
    this.dateAdded,
    this.playCount = 0,
    this.isFavorite = false,
  }) : id = id ?? path;

  Song copyWith({
    String? title,
    String? path,
    String? artist,
    String? album,
    Genre? genre,
    int? year,
    Duration? duration,
    String? artwork,
    int? trackNumber,
    DateTime? dateAdded,
    int? playCount,
    bool? isFavorite,
  }) {
    return Song(
      id: id,
      title: title ?? this.title,
      path: path ?? this.path,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      artwork: artwork ?? this.artwork,
      trackNumber: trackNumber ?? this.trackNumber,
      dateAdded: dateAdded ?? this.dateAdded,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'artist': artist,
      'album': album,
      'genre': genre?.label,
      'year': year,
      'duration_ms': duration?.inMilliseconds,
      'artwork': artwork,
      'track_number': trackNumber,
      'date_added': dateAdded?.millisecondsSinceEpoch,
      'play_count': playCount,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Song.fromMap(Map<String, Object?> row) {
    final genreLabel = row['genre'] as String?;
    final durationMs = row['duration_ms'] as int?;
    final dateAddedMs = row['date_added'] as int?;
    return Song(
      id: row['id'] as String,
      title: row['title'] as String,
      path: row['path'] as String,
      artist: row['artist'] as String?,
      album: row['album'] as String?,
      genre: genreLabel == null ? null : Genre.fromLabel(genreLabel),
      year: row['year'] as int?,
      duration:
          durationMs == null ? null : Duration(milliseconds: durationMs),
      artwork: row['artwork'] as String?,
      trackNumber: row['track_number'] as int?,
      dateAdded: dateAddedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(dateAddedMs),
      playCount: (row['play_count'] as int?) ?? 0,
      isFavorite: ((row['is_favorite'] as int?) ?? 0) == 1,
    );
  }
}
