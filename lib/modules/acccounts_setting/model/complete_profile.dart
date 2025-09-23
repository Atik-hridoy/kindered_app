class CompleteProfile {
  final String id;
  final String role;
  final String email;
  final int age;
  final String gender;
  final String? bodyImage;
  final String? headShotImage;
  final String? personalityImage;
  final String? image;
  final List<String> likeToMeet;
  final List<String> personalTraitsInspire;
  final String address;
  final String status;
  final int profileCompletionPercentage;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String aboutMe;
  final String beliefsOtherText;
  final Body body;
  final EduJob eduJob;
  final String firstName;
  final Habits habits;
  final Interests interests;
  final String lastName;
  final Lifestyle lifestyle;
  final String phone;
  final String relationType;
  final String religion;
  final String traitsOtherText;
  final String zodiacSign;
  final Location location;

  CompleteProfile({
    required this.id,
    required this.role,
    required this.email,
    required this.age,
    required this.gender,
    this.bodyImage,
    this.headShotImage,
    this.personalityImage,
    this.image,
    required this.likeToMeet,
    required this.personalTraitsInspire,
    required this.address,
    required this.status,
    required this.profileCompletionPercentage,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.aboutMe,
    required this.beliefsOtherText,
    required this.body,
    required this.eduJob,
    required this.firstName,
    required this.habits,
    required this.interests,
    required this.lastName,
    required this.lifestyle,
    required this.phone,
    required this.relationType,
    required this.religion,
    required this.traitsOtherText,
    required this.zodiacSign,
    required this.location,
  });

  factory CompleteProfile.fromJson(Map<String, dynamic> json) => CompleteProfile(
        id: json['_id'] ?? json['id'] ?? '',
        role: json['role'] ?? '',
        email: json['email'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? '',
        bodyImage: json['bodyImage'],
        headShotImage: json['headShotImage'],
        personalityImage: json['personalityImage'],
        image: json['image'],
        likeToMeet: List<String>.from(json['likeToMeet'] ?? []),
        personalTraitsInspire: List<String>.from(json['personalTraitsInspire'] ?? []),
        address: json['address'] ?? '',
        status: json['status'] ?? '',
        profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
        isDeleted: json['isDeleted'] ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
        aboutMe: json['aboutMe'] ?? '',
        beliefsOtherText: json['beliefsOtherText'] ?? '',
        body: Body.fromJson(json['body'] ?? {}),
        eduJob: EduJob.fromJson(json['eduJob'] ?? {}),
        firstName: json['firstName'] ?? '',
        habits: Habits.fromJson(json['habits'] ?? {}),
        interests: Interests.fromJson(json['interests'] ?? {}),
        lastName: json['lastName'] ?? '',
        lifestyle: Lifestyle.fromJson(json['lifestyle'] ?? {}),
        phone: json['phone'] ?? '',
        relationType: json['relationType'] ?? '',
        religion: json['religion'] ?? '',
        traitsOtherText: json['traitsOtherText'] ?? '',
        zodiacSign: json['zodiacSign'] ?? '',
        location: Location.fromJson(json['location'] ?? {}),
      );

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
        'profileCompletionPercentage': profileCompletionPercentage,
        'isDeleted': isDeleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'aboutMe': aboutMe,
        'beliefsOtherText': beliefsOtherText,
        'body': body.toJson(),
        'eduJob': eduJob.toJson(),
        'firstName': firstName,
        'habits': habits.toJson(),
        'interests': interests.toJson(),
        'lastName': lastName,
        'lifestyle': lifestyle.toJson(),
        'phone': phone,
        'relationType': relationType,
        'religion': religion,
        'traitsOtherText': traitsOtherText,
        'zodiacSign': zodiacSign,
        'location': location.toJson(),
      };
}

class Body {
  final int heightCm;
  final int weightKg;

  Body({required this.heightCm, required this.weightKg});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        heightCm: json['heightCm'] ?? 0,
        weightKg: json['weightKg'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'weightKg': weightKg,
      };
}

class EduJob {
  final String educationLevel;
  final String jobTitle;
  final int annualIncome;

  EduJob({required this.educationLevel, required this.jobTitle, required this.annualIncome});

  factory EduJob.fromJson(Map<String, dynamic> json) => EduJob(
        educationLevel: json['educationLevel'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        annualIncome: json['annualIncome'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'educationLevel': educationLevel,
        'jobTitle': jobTitle,
        'annualIncome': annualIncome,
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

  factory Habits.fromJson(Map<String, dynamic> json) => Habits(
        communicationStyle: List<String>.from(json['communicationStyle'] ?? []),
        workout: json['workout'] ?? '',
        eatingStyle: List<String>.from(json['eatingStyle'] ?? []),
        socialMedia: json['socialMedia'] ?? '',
        smokeOrDrink: json['smokeOrDrink'] ?? '',
        newExercise: json['newExercise'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'communicationStyle': communicationStyle,
        'workout': workout,
        'eatingStyle': eatingStyle,
        'socialMedia': socialMedia,
        'smokeOrDrink': smokeOrDrink,
        'newExercise': newExercise,
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

  factory Interests.fromJson(Map<String, dynamic> json) => Interests(
        hobbies: List<String>.from(json['hobbies'] ?? []),
        creativeOutlets: List<String>.from(json['creativeOutlets'] ?? []),
        fitnessAndSports: List<String>.from(json['fitnessAndSports'] ?? []),
        entertainment: List<String>.from(json['entertainment'] ?? []),
        leisureActivities: List<String>.from(json['leisureActivities'] ?? []),
        musicGenres: List<String>.from(json['musicGenres'] ?? []),
        healthAndWellness: List<String>.from(json['healthAndWellness'] ?? []),
        readingAndContent: List<String>.from(json['readingAndContent'] ?? []),
      );

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

  factory Lifestyle.fromJson(Map<String, dynamic> json) => Lifestyle(
        sleepingStyle: json['sleepingStyle'] ?? '',
        loveStyle: json['loveStyle'] ?? '',
        weekends: json['weekends'] ?? '',
        traveling: json['traveling'] ?? '',
        homeEnvironment: json['homeEnvironment'] ?? '',
        livingSpace: json['livingSpace'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'sleepingStyle': sleepingStyle,
        'loveStyle': loveStyle,
        'weekends': weekends,
        'traveling': traveling,
        'homeEnvironment': homeEnvironment,
        'livingSpace': livingSpace,
      };
}

class Location {
  final List<double> coordinates;
  final String type;

  Location({required this.coordinates, required this.type});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        coordinates: (json['coordinates'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        type: json['type'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates,
        'type': type,
      };
}
