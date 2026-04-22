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
}
