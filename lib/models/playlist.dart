class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverPath;
  final List<String> songIds;
  final DateTime createdAt;
  final bool isSystem;

  const Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    this.description,
    this.coverPath,
    this.isSystem = false,
  });

  Playlist copyWith({
    String? name,
    String? description,
    String? coverPath,
    List<String>? songIds,
    bool? isSystem,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
