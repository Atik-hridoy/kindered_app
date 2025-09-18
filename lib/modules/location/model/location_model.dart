// user_location_response.dart

class UserLocationResponse {
  final bool success;
  final String message;
  final int statusCode;
  final UserData? data;

  UserLocationResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory UserLocationResponse.fromJson(Map<String, dynamic> json) {
    return UserLocationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'statusCode': statusCode,
        'data': data?.toJson(),
      };
}

class UserData {
  final String id;
  final String role;
  final String email;
  final int age;
  final String? gender;
  final String bodyImage;
  final String headShotImage;
  final String personalityImage;
  final List<dynamic> image;
  final List<dynamic> likeToMeet;
  final List<dynamic> personalTraitsInspire;
  final String address;
  final String status;
  final bool isVerified;
  final int profileCompletionPercentage;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;
  final Location? location;

  UserData({
    required this.id,
    required this.role,
    required this.email,
    required this.age,
    this.gender,
    required this.bodyImage,
    required this.headShotImage,
    required this.personalityImage,
    required this.image,
    required this.likeToMeet,
    required this.personalTraitsInspire,
    required this.address,
    required this.status,
    required this.isVerified,
    required this.profileCompletionPercentage,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.location,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'],
      bodyImage: json['bodyImage'] ?? '',
      headShotImage: json['headShotImage'] ?? '',
      personalityImage: json['personalityImage'] ?? '',
      image: json['image'] ?? [],
      likeToMeet: json['likeToMeet'] ?? [],
      personalTraitsInspire: json['personalTraitsInspire'] ?? [],
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'role': role,
        'email': email,
        'age': age,
        'gender': gender,
        'bodyImage': bodyImage,
        'headShotImage': headShotImage,
        'personalityImage': personalityImage,
        'image': image,
        'likeToMeet': likeToMeet,
        'personalTraitsInspire': personalTraitsInspire,
        'address': address,
        'status': status,
        'isVerified': isVerified,
        'profileCompletionPercentage': profileCompletionPercentage,
        'isDeleted': isDeleted,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'location': location?.toJson(),
      };
}

class Location {
  final List<double> coordinates;
  final String type;

  Location({
    required this.coordinates,
    required this.type,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates,
        'type': type,
      };
}
