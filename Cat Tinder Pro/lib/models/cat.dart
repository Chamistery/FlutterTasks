class Cat {
  final String id;
  final String imageUrl;
  final String breed;
  final String description;
  final DateTime? likedAt;

  Cat({
    required this.id,
    required this.imageUrl,
    required this.breed,
    required this.description,
    this.likedAt,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    final breedData =
        json['breeds'] != null && (json['breeds'] as List).isNotEmpty
            ? json['breeds'][0]
            : null;

    return Cat(
      id: json['id'] as String,
      imageUrl: json['url'] as String,
      breed: breedData != null ? breedData['name'] as String : 'Unknown',
      description: breedData != null ? breedData['description'] as String : '',
    );
  }

  Cat copyWith({DateTime? likedAt}) {
    return Cat(
      id: id,
      imageUrl: imageUrl,
      breed: breed,
      description: description,
      likedAt: likedAt ?? this.likedAt,
    );
  }
}
