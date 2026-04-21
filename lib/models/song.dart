class Song {
  final String title;
  final String path;
  final String? artist;
  final String? album;
  final Duration? duration;
  final String? artwork; // portada

  Song({
    required this.title,
    required this.path,
    this.artist,
    this.album,
    this.duration,
    this.artwork,
  });
}
