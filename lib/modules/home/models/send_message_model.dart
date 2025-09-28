class SendMessageResponse {
  final bool success;
  final String message;
  final int statusCode;
  final SendMessageData data;

  SendMessageResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: SendMessageData.fromJson(json['data'] ?? {}),
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

class SendMessageData {
  final String chatId;
  final String sender;
  final String text;
  final List<String>? images;
  final bool read;
  final String type;
  final bool isDeleted;
  final bool isPinned;
  final String? replyTo;
  final List<String> iconViewed;
  final String id;
  final DateTime createdAt;
  final List<String> pinnedByUsers;
  final List<String> deletedForUsers;
  final List<dynamic> reactions;
  final DateTime updatedAt;
  final int v;

  SendMessageData({
    required this.chatId,
    required this.sender,
    required this.text,
    this.images,
    required this.read,
    required this.type,
    required this.isDeleted,
    required this.isPinned,
    this.replyTo,
    required this.iconViewed,
    required this.id,
    required this.createdAt,
    required this.pinnedByUsers,
    required this.deletedForUsers,
    required this.reactions,
    required this.updatedAt,
    required this.v,
  });

  factory SendMessageData.fromJson(Map<String, dynamic> json) {
    return SendMessageData(
      chatId: json['chatId'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      read: json['read'] ?? false,
      type: json['type'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      replyTo: json['replyTo'],
      iconViewed: json['iconViewed'] != null ? List<String>.from(json['iconViewed']) : [],
      id: json['_id'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      pinnedByUsers: json['pinnedByUsers'] != null ? List<String>.from(json['pinnedByUsers']) : [],
      deletedForUsers: json['deletedForUsers'] != null ? List<String>.from(json['deletedForUsers']) : [],
      reactions: json['reactions'] ?? [],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'sender': sender,
      'text': text,
      'images': images,
      'read': read,
      'type': type,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'replyTo': replyTo,
      'iconViewed': iconViewed,
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'pinnedByUsers': pinnedByUsers,
      'deletedForUsers': deletedForUsers,
      'reactions': reactions,
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}