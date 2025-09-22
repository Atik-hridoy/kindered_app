class UserSuggestion {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final String matchPercentage;
  final String location;
  final List<String>? images;

  UserSuggestion({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.matchPercentage,
    required this.location,
    this.images,
  });

  factory UserSuggestion.fromJson(Map<String, dynamic> json) {
    return UserSuggestion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      matchPercentage: json['matchPercentage']?.toString() ?? '0%',
      location: json['location'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'imageUrl': imageUrl,
      'matchPercentage': matchPercentage,
      'location': location,
      'images': images,
    };
  }
}
