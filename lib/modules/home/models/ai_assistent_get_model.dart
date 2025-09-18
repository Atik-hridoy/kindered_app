// matchmaking_response.dart

class MatchmakingResponse {
  final bool success;
  final String message;
  final int statusCode;
  final MatchmakingData? data;

  MatchmakingResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory MatchmakingResponse.fromJson(Map<String, dynamic> json) {
    return MatchmakingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? MatchmakingData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'statusCode': statusCode,
        'data': data?.toJson(),
      };
}

class MatchmakingData {
  final String greeting;
  final CurrentMatch? currentMatch;
  final bool hasMoreMatches;
  final String sessionId;

  MatchmakingData({
    required this.greeting,
    this.currentMatch,
    required this.hasMoreMatches,
    required this.sessionId,
  });

  factory MatchmakingData.fromJson(Map<String, dynamic> json) {
    return MatchmakingData(
      greeting: json['greeting'] ?? '',
      currentMatch: json['currentMatch'] != null
          ? CurrentMatch.fromJson(json['currentMatch'])
          : null,
      hasMoreMatches: json['hasMoreMatches'] ?? false,
      sessionId: json['sessionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'greeting': greeting,
        'currentMatch': currentMatch?.toJson(),
        'hasMoreMatches': hasMoreMatches,
        'sessionId': sessionId,
      };
}

class CurrentMatch {
  final MatchUser? user;
  final int matchScore;
  final List<String> commonInterests;
  final List<String> reasons;
  final int distance;

  CurrentMatch({
    this.user,
    required this.matchScore,
    required this.commonInterests,
    required this.reasons,
    required this.distance,
  });

  factory CurrentMatch.fromJson(Map<String, dynamic> json) {
    return CurrentMatch(
      user: json['user'] != null ? MatchUser.fromJson(json['user']) : null,
      matchScore: json['matchScore'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      reasons: List<String>.from(json['reasons'] ?? []),
      distance: json['distance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'matchScore': matchScore,
        'commonInterests': commonInterests,
        'reasons': reasons,
        'distance': distance,
      };
}

class MatchUser {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String email;
  final int age;
  final String gender;
  final String address;
  final String bodyImage;
  final String headShotImage;
  final String personalityImage;
  final List<dynamic> image;
  final List<dynamic> likeToMeet;
  final List<dynamic> personalTraitsInspire;
  final String status;
  final bool isVerified;
  final int profileCompletionPercentage;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  MatchUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.age,
    required this.gender,
    required this.address,
    required this.bodyImage,
    required this.headShotImage,
    required this.personalityImage,
    required this.image,
    required this.likeToMeet,
    required this.personalTraitsInspire,
    required this.status,
    required this.isVerified,
    required this.profileCompletionPercentage,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchUser.fromJson(Map<String, dynamic> json) {
    return MatchUser(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      bodyImage: json['bodyImage'] ?? '',
      headShotImage: json['headShotImage'] ?? '',
      personalityImage: json['personalityImage'] ?? '',
      image: json['image'] ?? [],
      likeToMeet: json['likeToMeet'] ?? [],
      personalTraitsInspire: json['personalTraitsInspire'] ?? [],
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'email': email,
        'age': age,
        'gender': gender,
        'address': address,
        'bodyImage': bodyImage,
        'headShotImage': headShotImage,
        'personalityImage': personalityImage,
        'image': image,
        'likeToMeet': likeToMeet,
        'personalTraitsInspire': personalTraitsInspire,
        'status': status,
        'isVerified': isVerified,
        'profileCompletionPercentage': profileCompletionPercentage,
        'isDeleted': isDeleted,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
