class Artist {
  final String id;
  final String name;
  final String? imagePath;
  final String? bio;

  const Artist({
    required this.id,
    required this.name,
    this.imagePath,
    this.bio,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'bio': bio,
    };
  }

  factory Artist.fromMap(Map<String, Object?> row) {
    return Artist(
      id: row['id'] as String,
      name: row['name'] as String,
      imagePath: row['image_path'] as String?,
      bio: row['bio'] as String?,
    );
  }
}
