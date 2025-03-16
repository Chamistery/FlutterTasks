class Cat {
  final String id;
  final String imageUrl;
  final String breed;
  final String description;

  Cat({
    required this.id,
    required this.imageUrl,
    required this.breed,
    required this.description,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    final breeds = (json['breeds'] as List<dynamic>?) ?? [];
    final breedName =
        breeds.isNotEmpty
            ? (breeds[0]['name'] as String? ?? 'Unknown')
            : 'Unknown';
    final breedDescription =
        breeds.isNotEmpty
            ? (breeds[0]['description'] as String? ??
                'No description available')
            : 'No description available';

    return Cat(
      id: json['id'] as String,
      imageUrl: json['url'] as String,
      breed: breedName,
      description: breedDescription,
    );
  }
}
