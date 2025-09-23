
class UserProfile {
  final String id;
  final String role;
  final String email;
  final int? age;
  final String gender;
  final String firstName;
  final String lastName;
  final String? aboutMe;
  final String? religion;
  final String? zodiacSign;
  final String status;
  final int profileCompletionPercentage;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Habits? habits;
  final Interests? interests;
  final Lifestyle? lifestyle;
  final List<String> likeToMeet;
  final List<String> personalTraitsInspire;
  final List<String> image;
  final String? bodyImage;
  final String? phone;
  final String? relationType;
  final Location? location;

  UserProfile({
    required this.id,
    required this.role,
    required this.email,
    this.age,
    required this.gender,
    required this.firstName,
    required this.lastName,
    this.aboutMe,
    this.religion,
    this.zodiacSign,
    required this.status,
    required this.profileCompletionPercentage,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.habits,
    this.interests,
    this.lifestyle,
    this.likeToMeet = const [],
    this.personalTraitsInspire = const [],
    this.image = const [],
    this.bodyImage,
    this.phone,
    this.relationType,
    this.location,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print('DEBUG: UserProfile.fromJson called');
    print('DEBUG: Raw JSON data: $json');
    
    final userProfile = UserProfile(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      age: json['age'],
      gender: json['gender'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      religion: json['religion'],
      zodiacSign: json['zodiacSign'],
      status: json['status'] ?? '',
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      habits: json['habits'] != null ? Habits.fromJson(json['habits']) : null,
      interests: json['interests'] != null ? Interests.fromJson(json['interests']) : null,
      lifestyle: json['lifestyle'] != null ? Lifestyle.fromJson(json['lifestyle']) : null,
      likeToMeet: List<String>.from(json['likeToMeet'] ?? []),
      personalTraitsInspire: List<String>.from(json['personalTraitsInspire'] ?? []),
      image: List<String>.from(json['image'] ?? []),
      bodyImage: json['bodyImage'],
      phone: json['phone'] ?? '',
      relationType: json['relationType'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
    

    return userProfile;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'email': email,
      'age': age,
      'gender': gender,
      'firstName': firstName,
      'lastName': lastName,
      'aboutMe': aboutMe,
      'religion': religion,
      'zodiacSign': zodiacSign,
      'status': status,
      'profileCompletionPercentage': profileCompletionPercentage,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'habits': habits?.toJson(),
      'interests': interests?.toJson(),
      'lifestyle': lifestyle?.toJson(),
      'likeToMeet': likeToMeet,
      'personalTraitsInspire': personalTraitsInspire,
      'image': image,
      'phone': phone,
      'relationType': relationType,
      'location': location?.toJson(),
    };
  }
}

class Habits {
  final List<String> communicationStyle;
  final String? workout;
  final List<String> eatingStyle;
  final String? socialMedia;
  final String? smokeOrDrink;
  final String? newExercise;

  Habits({
    this.communicationStyle = const [],
    this.workout,
    this.eatingStyle = const [],
    this.socialMedia,
    this.smokeOrDrink,
    this.newExercise,
  });

  factory Habits.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Habits.fromJson called with: $json');
    final habits = Habits(
      communicationStyle: List<String>.from(json['communicationStyle'] ?? []),
      workout: json['workout'],
      eatingStyle: List<String>.from(json['eatingStyle'] ?? []),
      socialMedia: json['socialMedia'],
      smokeOrDrink: json['smokeOrDrink'],
      newExercise: json['newExercise'],
    );
    print('DEBUG: Habits object created:');
    print('DEBUG:   workout: ${habits.workout}');
    print('DEBUG:   socialMedia: ${habits.socialMedia}');
    print('DEBUG:   smokeOrDrink: ${habits.smokeOrDrink}');
    print('DEBUG:   newExercise: ${habits.newExercise}');
    print('DEBUG:   eatingStyle: ${habits.eatingStyle}');
    return habits;
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
    this.hobbies = const [],
    this.creativeOutlets = const [],
    this.fitnessAndSports = const [],
    this.entertainment = const [],
    this.leisureActivities = const [],
    this.musicGenres = const [],
    this.healthAndWellness = const [],
    this.readingAndContent = const [],
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
  final String? sleepingStyle;
  final String? loveStyle;
  final String? weekends;
  final String? traveling;
  final String? homeEnvironment;
  final String? livingSpace;

  Lifestyle({
    this.sleepingStyle,
    this.loveStyle,
    this.weekends,
    this.traveling,
    this.homeEnvironment,
    this.livingSpace,
  });

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(
      sleepingStyle: json['sleepingStyle'],
      loveStyle: json['loveStyle'],
      weekends: json['weekends'],
      traveling: json['traveling'],
      homeEnvironment: json['homeEnvironment'],
      livingSpace: json['livingSpace'],
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

class Location {
  final List<double> coordinates;
  final String type;

  Location({
    this.coordinates = const [],
    this.type = '',
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates: (json['coordinates'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'type': type,
    };
  }
}
