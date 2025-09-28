class ChatResponse {
  bool success;
  String message;
  int statusCode;
  ChatData data;
  Meta meta;

  ChatResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
    required this.meta,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? ChatData.fromJson(json['data']) : ChatData(chats: [], unreadChatsCount: 0, totalUnreadMessages: 0, totalIconUnreadMessages: 0),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : Meta(limit: 0, page: 0, total: 0, totalPage: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class ChatData {
  List<Chat> chats;
  int unreadChatsCount;
  int totalUnreadMessages;
  int totalIconUnreadMessages;

  ChatData({
    required this.chats,
    required this.unreadChatsCount,
    required this.totalUnreadMessages,
    required this.totalIconUnreadMessages,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      chats: json['chats'] != null 
          ? List<Chat>.from(json['chats'].map((x) => Chat.fromJson(x)))
          : [],
      unreadChatsCount: json['unreadChatsCount'] ?? 0,
      totalUnreadMessages: json['totalUnreadMessages'] ?? 0,
      totalIconUnreadMessages: json['totalIconUnreadMessages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chats': List<dynamic>.from(chats.map((x) => x.toJson())),
      'unreadChatsCount': unreadChatsCount,
      'totalUnreadMessages': totalUnreadMessages,
      'totalIconUnreadMessages': totalIconUnreadMessages,
    };
  }
}

class Chat {
  String id;
  List<Participant> participants;
  dynamic lastMessage;
  String status;
  bool isDeleted;
  List<dynamic> readBy;
  List<dynamic> mutedBy;
  List<dynamic> deletedByDetails;
  List<dynamic> blockedUsers;
  List<dynamic> userPinnedMessages;
  String createdAt;
  String updatedAt;
  bool isRead;
  int unreadCount;
  int iconUnreadCount;
  bool isMuted;
  bool isBlocked;
  bool wasDeletedByUser;
  dynamic deletedAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.status,
    required this.isDeleted,
    required this.readBy,
    required this.mutedBy,
    required this.deletedByDetails,
    required this.blockedUsers,
    required this.userPinnedMessages,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
    required this.unreadCount,
    required this.iconUnreadCount,
    required this.isMuted,
    required this.isBlocked,
    required this.wasDeletedByUser,
    this.deletedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id']?.toString() ?? '',
      participants: json['participants'] != null 
          ? List<Participant>.from(
              json['participants']
                  .where((participant) => participant != null)
                  .map((x) => Participant.fromJson(x)))
          : [],
      lastMessage: json['lastMessage'],
      status: json['status']?.toString() ?? 'active',
      isDeleted: json['isDeleted'] ?? false,
      readBy: json['readBy'] != null ? List<dynamic>.from(json['readBy']) : [],
      mutedBy: json['mutedBy'] != null ? List<dynamic>.from(json['mutedBy']) : [],
      deletedByDetails: json['deletedByDetails'] != null ? List<dynamic>.from(json['deletedByDetails']) : [],
      blockedUsers: json['blockedUsers'] != null ? List<dynamic>.from(json['blockedUsers']) : [],
      userPinnedMessages: json['userPinnedMessages'] != null ? List<dynamic>.from(json['userPinnedMessages']) : [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      iconUnreadCount: json['iconUnreadCount'] ?? 0,
      isMuted: json['isMuted'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      wasDeletedByUser: json['wasDeletedByUser'] ?? false,
      deletedAt: json['deletedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': List<dynamic>.from(participants.map((x) => x.toJson())),
      'lastMessage': lastMessage,
      'status': status,
      'isDeleted': isDeleted,
      'readBy': readBy,
      'mutedBy': mutedBy,
      'deletedByDetails': deletedByDetails,
      'blockedUsers': blockedUsers,
      'userPinnedMessages': userPinnedMessages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isRead': isRead,
      'unreadCount': unreadCount,
      'iconUnreadCount': iconUnreadCount,
      'isMuted': isMuted,
      'isBlocked': isBlocked,
      'wasDeletedByUser': wasDeletedByUser,
      'deletedAt': deletedAt,
    };
  }

  // Getter methods for easy access to participant information
  String get participantName {
    if (participants.isNotEmpty) {
      final participant = participants.first;
      return '${participant.firstName} ${participant.lastName}'.trim();
    }
    return 'Unknown';
  }

  String get participantId {
    if (participants.isNotEmpty) {
      return participants.first.id;
    }
    return '';
  }

  String get participantEmail {
    if (participants.isNotEmpty) {
      return participants.first.email;
    }
    return '';
  }

  List<dynamic> get participantImage {
    if (participants.isNotEmpty) {
      return participants.first.image;
    }
    return [];
  }
}

class Participant {
  String id;
  String email;
  List<dynamic> image;
  String firstName;
  String lastName;

  Participant({
    required this.id,
    required this.email,
    required this.image,
    required this.firstName,
    required this.lastName,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      image: json['image'] != null ? List<dynamic>.from(json['image']) : [],
      firstName: json['firstName']?.toString() ?? 'Unknown',
      lastName: json['lastName']?.toString() ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'image': image,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class Meta {
  int limit;
  int page;
  int total;
  int totalPage;

  Meta({
    required this.limit,
    required this.page,
    required this.total,
    required this.totalPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['totalPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'page': page,
      'total': total,
      'totalPage': totalPage,
    };
  }
}
