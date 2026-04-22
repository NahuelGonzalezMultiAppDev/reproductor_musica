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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_path': coverPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_system': isSystem ? 1 : 0,
    };
  }

  factory Playlist.fromMap(
    Map<String, Object?> row,
    List<String> songIds,
  ) {
    return Playlist(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      coverPath: row['cover_path'] as String?,
      songIds: songIds,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      isSystem: ((row['is_system'] as int?) ?? 0) == 1,
    );
  }
}
