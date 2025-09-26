import 'dart:convert';

/// Top-level response
class CurrentMatchResponse {
  final bool success;
  final String message;
  final int statusCode;
  final MatchData data;

  CurrentMatchResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory CurrentMatchResponse.fromJson(Map<String, dynamic> json) {
    return CurrentMatchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: MatchData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'statusCode': statusCode,
        'data': data.toJson(),
      };
}

class MatchData {
  final CurrentMatch currentMatch;
  final bool hasMoreMatches;
  final String sessionId;
  final String message;

  MatchData({
    required this.currentMatch,
    required this.hasMoreMatches,
    required this.sessionId,
    required this.message,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      currentMatch: CurrentMatch.fromJson(json['currentMatch']),
      hasMoreMatches: json['hasMoreMatches'] ?? false,
      sessionId: json['sessionId'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'currentMatch': currentMatch.toJson(),
        'hasMoreMatches': hasMoreMatches,
        'sessionId': sessionId,
        'message': message,
      };
}

class CurrentMatch {
  final MatchUser user;
  final int matchScore;
  final List<String> commonInterests;
  final List<String> reasons;
  final double distance;

  CurrentMatch({
    required this.user,
    required this.matchScore,
    required this.commonInterests,
    required this.reasons,
    required this.distance,
  });

  factory CurrentMatch.fromJson(Map<String, dynamic> json) {
    return CurrentMatch(
      user: MatchUser.fromJson(json['user']),
      matchScore: json['matchScore'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      reasons: List<String>.from(json['reasons'] ?? []),
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
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
  final String phone;
  final int age;
  final String gender;
  final Location location;
  final String bodyImage;
  final String headShotImage;
  final String personalityImage;
  final List<String> image;
  final List<String> likeToMeet;
  final String relationType;
  final Body body;
  final EduJob eduJob;
  final Interests interests;
  final List<String> personalTraitsInspire;
  final String religion;
  final String zodiacSign;
  final Lifestyle lifestyle;
  final Habits habits;
  final String beliefsOtherText;
  final String address;
  final String traitsOtherText;
  final String aboutMe;
  final String status;
  final bool isVerified;
  final int profileCompletionPercentage;
  final bool isDeleted;
  final String updatedAt;

  MatchUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.location,
    required this.bodyImage,
    required this.headShotImage,
    required this.personalityImage,
    required this.image,
    required this.likeToMeet,
    required this.relationType,
    required this.body,
    required this.eduJob,
    required this.interests,
    required this.personalTraitsInspire,
    required this.religion,
    required this.zodiacSign,
    required this.lifestyle,
    required this.habits,
    required this.beliefsOtherText,
    required this.address,
    required this.traitsOtherText,
    required this.aboutMe,
    required this.status,
    required this.isVerified,
    required this.profileCompletionPercentage,
    required this.isDeleted,
    required this.updatedAt,
  });

  factory MatchUser.fromJson(Map<String, dynamic> json) {
    return MatchUser(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      location: Location.fromJson(json['location']),
      bodyImage: json['bodyImage'] ?? '',
      headShotImage: json['headShotImage'] ?? '',
      personalityImage: json['personalityImage'] ?? '',
      image: List<String>.from(json['image'] ?? []),
      likeToMeet: List<String>.from(json['likeToMeet'] ?? []),
      relationType: json['relationType'] ?? '',
      body: Body.fromJson(json['body']),
      eduJob: EduJob.fromJson(json['eduJob']),
      interests: Interests.fromJson(json['interests']),
      personalTraitsInspire:
          List<String>.from(json['personalTraitsInspire'] ?? []),
      religion: json['religion'] ?? '',
      zodiacSign: json['zodiacSign'] ?? '',
      lifestyle: Lifestyle.fromJson(json['lifestyle']),
      habits: Habits.fromJson(json['habits']),
      beliefsOtherText: json['beliefsOtherText'] ?? '',
      address: json['address'] ?? '',
      traitsOtherText: json['traitsOtherText'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'email': email,
        'phone': phone,
        'age': age,
        'gender': gender,
        'location': location.toJson(),
        'bodyImage': bodyImage,
        'headShotImage': headShotImage,
        'personalityImage': personalityImage,
        'image': image,
        'likeToMeet': likeToMeet,
        'relationType': relationType,
        'body': body.toJson(),
        'eduJob': eduJob.toJson(),
        'interests': interests.toJson(),
        'personalTraitsInspire': personalTraitsInspire,
        'religion': religion,
        'zodiacSign': zodiacSign,
        'lifestyle': lifestyle.toJson(),
        'habits': habits.toJson(),
        'beliefsOtherText': beliefsOtherText,
        'address': address,
        'traitsOtherText': traitsOtherText,
        'aboutMe': aboutMe,
        'status': status,
        'isVerified': isVerified,
        'profileCompletionPercentage': profileCompletionPercentage,
        'isDeleted': isDeleted,
        'updatedAt': updatedAt,
      };
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class Body {
  final int heightCm;
  final int weightKg;

  Body({required this.heightCm, required this.weightKg});

  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      heightCm: json['heightCm'] ?? 0,
      weightKg: json['weightKg'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'weightKg': weightKg,
      };
}

class EduJob {
  final String educationLevel;
  final String jobTitle;
  final int annualIncome;

  EduJob({
    required this.educationLevel,
    required this.jobTitle,
    required this.annualIncome,
  });

  factory EduJob.fromJson(Map<String, dynamic> json) {
    return EduJob(
      educationLevel: json['educationLevel'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      annualIncome: json['annualIncome'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'educationLevel': educationLevel,
        'jobTitle': jobTitle,
        'annualIncome': annualIncome,
      };
}

class Interests {
  final List<String> hobbies;
  final List<String> creativeOutlets;
  final List<String> fitnessAndSports;
  final List<String> entertainment;
  final List<String> leisureActivities;
  final List<String> musicGenres;
  final List<String> healthAndWellness;
  final List<String> readingAndContent;

  Interests({
    required this.hobbies,
    required this.creativeOutlets,
    required this.fitnessAndSports,
    required this.entertainment,
    required this.leisureActivities,
    required this.musicGenres,
    required this.healthAndWellness,
    required this.readingAndContent,
  });

  factory Interests.fromJson(Map<String, dynamic> json) {
    return Interests(
      hobbies: List<String>.from(json['hobbies'] ?? []),
      creativeOutlets: List<String>.from(json['creativeOutlets'] ?? []),
      fitnessAndSports: List<String>.from(json['fitnessAndSports'] ?? []),
      entertainment: List<String>.from(json['entertainment'] ?? []),
      leisureActivities: List<String>.from(json['leisureActivities'] ?? []),
      musicGenres: List<String>.from(json['musicGenres'] ?? []),
      healthAndWellness: List<String>.from(json['healthAndWellness'] ?? []),
      readingAndContent: List<String>.from(json['readingAndContent'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'hobbies': hobbies,
        'creativeOutlets': creativeOutlets,
        'fitnessAndSports': fitnessAndSports,
        'entertainment': entertainment,
        'leisureActivities': leisureActivities,
        'musicGenres': musicGenres,
        'healthAndWellness': healthAndWellness,
        'readingAndContent': readingAndContent,
      };
}

class Lifestyle {
  final String sleepingStyle;
  final String loveStyle;
  final String weekends;
  final String traveling;
  final String homeEnvironment;
  final String livingSpace;

  Lifestyle({
    required this.sleepingStyle,
    required this.loveStyle,
    required this.weekends,
    required this.traveling,
    required this.homeEnvironment,
    required this.livingSpace,
  });

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(
      sleepingStyle: json['sleepingStyle'] ?? '',
      loveStyle: json['loveStyle'] ?? '',
      weekends: json['weekends'] ?? '',
      traveling: json['traveling'] ?? '',
      homeEnvironment: json['homeEnvironment'] ?? '',
      livingSpace: json['livingSpace'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'sleepingStyle': sleepingStyle,
        'loveStyle': loveStyle,
        'weekends': weekends,
        'traveling': traveling,
        'homeEnvironment': homeEnvironment,
        'livingSpace': livingSpace,
      };
}

class Habits {
  final List<String> communicationStyle;
  final String workout;
  final List<String> eatingStyle;
  final String socialMedia;
  final String smokeOrDrink;
  final String newExercise;

  Habits({
    required this.communicationStyle,
    required this.workout,
    required this.eatingStyle,
    required this.socialMedia,
    required this.smokeOrDrink,
    required this.newExercise,
  });

  factory Habits.fromJson(Map<String, dynamic> json) {
    return Habits(
      communicationStyle: List<String>.from(json['communicationStyle'] ?? []),
      workout: json['workout'] ?? '',
      eatingStyle: List<String>.from(json['eatingStyle'] ?? []),
      socialMedia: json['socialMedia'] ?? '',
      smokeOrDrink: json['smokeOrDrink'] ?? '',
      newExercise: json['newExercise'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'communicationStyle': communicationStyle,
        'workout': workout,
        'eatingStyle': eatingStyle,
        'socialMedia': socialMedia,
        'smokeOrDrink': smokeOrDrink,
        'newExercise': newExercise,
      };
}

