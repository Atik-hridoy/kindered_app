class ChatWithAIResponse {
  final bool success;
  final String message;
  final int statusCode;
  final ChatWithData data;

  ChatWithAIResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory ChatWithAIResponse.fromJson(Map<String, dynamic> json) {
    return ChatWithAIResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: ChatWithData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data.toJson(),
    };
  }
}

class ChatWithData {
  final ChatMessage userMessage;
  final ChatMessage aiResponse;
  final CurrentMatch currentMatch;
  final bool hasMoreMatches;

  ChatWithData({
    required this.userMessage,
    required this.aiResponse,
    required this.currentMatch,
    required this.hasMoreMatches,
  });

  factory ChatWithData.fromJson(Map<String, dynamic> json) {
    return ChatWithData(
      userMessage: ChatMessage.fromJson(json['userMessage'] ?? {}),
      aiResponse: ChatMessage.fromJson(json['aiResponse'] ?? {}),
      currentMatch: CurrentMatch.fromJson(json['currentMatch'] ?? {}),
      hasMoreMatches: json['hasMoreMatches'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userMessage': userMessage.toJson(),
      'aiResponse': aiResponse.toJson(),
      'currentMatch': currentMatch.toJson(),
      'hasMoreMatches': hasMoreMatches,
    };
  }
}

class ChatMessage {
  final String sessionId;
  final String userId;
  final String message;
  final String messageType;
  final MatchData? matchData;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ChatMessage({
    required this.sessionId,
    required this.userId,
    required this.message,
    required this.messageType,
    this.matchData,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sessionId: json['session_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? '',
      matchData: json['match_data'] != null ? MatchData.fromJson(json['match_data']) : null,
      id: json['_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'message': message,
      'message_type': messageType,
      'match_data': matchData?.toJson(),
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class MatchData {
  final List<String> userImage;
  final List<String> commonInterests;
  final String? userId;
  final String? userFirstName;
  final String? userLastName;
  final String? userGender;
  final int? userAge;
  final int? matchScore;
  final int? distance;

  MatchData({
    required this.userImage,
    required this.commonInterests,
    this.userId,
    this.userFirstName,
    this.userLastName,
    this.userGender,
    this.userAge,
    this.matchScore,
    this.distance,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      userImage: List<String>.from(json['user_image'] ?? []),
      commonInterests: List<String>.from(json['common_interests'] ?? []),
      userId: json['user_id'],
      userFirstName: json['user_firstName'],
      userLastName: json['user_lastName'],
      userGender: json['user_gender'],
      userAge: json['user_age'],
      matchScore: json['match_score'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_image': userImage,
      'common_interests': commonInterests,
      'user_id': userId,
      'user_firstName': userFirstName,
      'user_lastName': userLastName,
      'user_gender': userGender,
      'user_age': userAge,
      'match_score': matchScore,
      'distance': distance,
    };
  }
}

class CurrentMatch {
  final MatchUser user;
  final int matchScore;
  final List<String> commonInterests;
  final List<String> reasons;
  final int distance;

  CurrentMatch({
    required this.user,
    required this.matchScore,
    required this.commonInterests,
    required this.reasons,
    required this.distance,
  });

  factory CurrentMatch.fromJson(Map<String, dynamic> json) {
    return CurrentMatch(
      user: MatchUser.fromJson(json['user'] ?? {}),
      matchScore: json['matchScore'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      reasons: List<String>.from(json['reasons'] ?? []),
      distance: json['distance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'matchScore': matchScore,
      'commonInterests': commonInterests,
      'reasons': reasons,
      'distance': distance,
    };
  }
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
  final DateTime updatedAt;

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
      location: Location.fromJson(json['location'] ?? {}),
      bodyImage: json['bodyImage'] ?? '',
      headShotImage: json['headShotImage'] ?? '',
      personalityImage: json['personalityImage'] ?? '',
      image: List<String>.from(json['image'] ?? []),
      likeToMeet: List<String>.from(json['likeToMeet'] ?? []),
      relationType: json['relationType'] ?? '',
      body: Body.fromJson(json['body'] ?? {}),
      eduJob: EduJob.fromJson(json['eduJob'] ?? {}),
      interests: Interests.fromJson(json['interests'] ?? {}),
      personalTraitsInspire: List<String>.from(json['personalTraitsInspire'] ?? []),
      religion: json['religion'] ?? '',
      zodiacSign: json['zodiacSign'] ?? '',
      lifestyle: Lifestyle.fromJson(json['lifestyle'] ?? {}),
      habits: Habits.fromJson(json['habits'] ?? {}),
      beliefsOtherText: json['beliefsOtherText'] ?? '',
      address: json['address'] ?? '',
      traitsOtherText: json['traitsOtherText'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class Body {
  final int heightCm;
  final int weightKg;

  Body({
    required this.heightCm,
    required this.weightKg,
  });

  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      heightCm: json['heightCm'] ?? 0,
      weightKg: json['weightKg'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heightCm': heightCm,
      'weightKg': weightKg,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'educationLevel': educationLevel,
      'jobTitle': jobTitle,
      'annualIncome': annualIncome,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
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

  Map<String, dynamic> toJson() {
    return {
      'sleepingStyle': sleepingStyle,
      'loveStyle': loveStyle,
      'weekends': weekends,
      'traveling': traveling,
      'homeEnvironment': homeEnvironment,
      'livingSpace': livingSpace,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'communicationStyle': communicationStyle,
      'workout': workout,
      'eatingStyle': eatingStyle,
      'socialMedia': socialMedia,
      'smokeOrDrink': smokeOrDrink,
      'newExercise': newExercise,
    };
  }
}