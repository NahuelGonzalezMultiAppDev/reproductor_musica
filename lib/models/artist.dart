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
}
