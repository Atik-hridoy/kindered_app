/// Main response wrapper for get messages API
class GetMessageResponse {
  final bool success;
  final String message;
  final int statusCode;
  final GetMessageData data;

  GetMessageResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? GetMessageData.fromJson(json['data']) : GetMessageData(messages: [], pinnedMessages: []),
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

/// Data model containing messages and pinned messages
class GetMessageData {
  final List<Message> messages;
  final List<dynamic> pinnedMessages; // Can be List<Message> or List<dynamic> based on API

  GetMessageData({
    required this.messages,
    required this.pinnedMessages,
  });

  factory GetMessageData.fromJson(Map<String, dynamic> json) {
    var messagesList = <Message>[];
    if (json['messages'] != null) {
      json['messages'].forEach((v) {
        messagesList.add(Message.fromJson(v));
      });
    }
    
    var pinnedMessagesList = <dynamic>[];
    if (json['pinnedMessages'] != null) {
      pinnedMessagesList = List<dynamic>.from(json['pinnedMessages']);
    }
    
    return GetMessageData(
      messages: messagesList,
      pinnedMessages: pinnedMessagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((v) => v.toJson()).toList(),
      'pinnedMessages': pinnedMessages,
    };
  }
}

/// Individual message model with complete API structure
class Message {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String text;
  final List<String>? images;
  final bool read;
  final String type;
  final bool isDeleted;
  final bool isPinned;
  final dynamic replyTo; // Can be null or a Message object
  final List<dynamic> iconViewed;
  final DateTime createdAt;
  final List<dynamic> pinnedByUsers;
  final List<dynamic> deletedForUsers;
  final List<dynamic> reactions;
  final DateTime updatedAt;
  final int v; // __v field from MongoDB
  final bool isPinnedByCurrentUser;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.text,
    this.images,
    required this.read,
    required this.type,
    required this.isDeleted,
    required this.isPinned,
    required this.replyTo,
    required this.iconViewed,
    required this.createdAt,
    required this.pinnedByUsers,
    required this.deletedForUsers,
    required this.reactions,
    required this.updatedAt,
    required this.v,
    required this.isPinnedByCurrentUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      sender: json['sender'] != null ? MessageSender.fromJson(json['sender']) : MessageSender.empty(),
      text: json['text'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      read: json['read'] ?? false,
      type: json['type'] ?? 'text',
      isDeleted: json['isDeleted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      replyTo: json['replyTo'], // Keep as dynamic since it can be null or complex
      iconViewed: json['iconViewed'] != null ? List<dynamic>.from(json['iconViewed']) : [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      pinnedByUsers: json['pinnedByUsers'] != null ? List<dynamic>.from(json['pinnedByUsers']) : [],
      deletedForUsers: json['deletedForUsers'] != null ? List<dynamic>.from(json['deletedForUsers']) : [],
      reactions: json['reactions'] != null ? List<dynamic>.from(json['reactions']) : [],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      v: json['__v'] ?? 0,
      isPinnedByCurrentUser: json['isPinnedByCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'sender': sender.toJson(),
      'text': text,
      'images': images,
      'read': read,
      'type': type,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'replyTo': replyTo,
      'iconViewed': iconViewed,
      'createdAt': createdAt.toIso8601String(),
      'pinnedByUsers': pinnedByUsers,
      'deletedForUsers': deletedForUsers,
      'reactions': reactions,
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'isPinnedByCurrentUser': isPinnedByCurrentUser,
    };
  }

  /// Convenience getter to check if message has images
  bool get hasImages => images != null && images!.isNotEmpty;
  
  /// Convenience getter to check if message is from current user
  bool get isFromCurrentUser => false; // This will be set based on current user comparison
  
  /// Convenience getter for formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes == 0) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Sender information model with complete structure
class MessageSender {
  final String id;
  final String email;
  final List<String> image;
  final String firstName;
  final String lastName;

  MessageSender({
    required this.id,
    required this.email,
    required this.image,
    required this.firstName,
    required this.lastName,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
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

  /// Empty constructor for fallback cases
  factory MessageSender.empty() {
    return MessageSender(
      id: '',
      email: '',
      image: [],
      firstName: 'Unknown',
      lastName: 'User',
    );
  }

  /// Convenience getter for full name
  String get fullName => '$firstName $lastName'.trim();
  
  /// Convenience getter for display name (handles empty names)
  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return fullName;
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return 'Unknown User';
    }
  }
  
  /// Convenience getter for first image URL
  String? get firstImageUrl => image.isNotEmpty ? image.first : null;
}

/// Extension methods for message handling
extension MessageExtensions on Message {
  /// Check if message is of specific type
  bool isType(String type) => this.type.toLowerCase() == type.toLowerCase();
  
  /// Check if message is text type
  bool get isText => isType('text');
  
  /// Check if message is image type
  bool get isImage => isType('image');
  
  /// Check if message is mixed type
  bool get isMixed => isType('mixed');
  
  /// Check if message is custom type
  bool get isCustom => isType('custom');
  
  /// Check if message has been read
  bool get isRead => read;
  
  /// Check if message is pinned
  bool get isPinnedMessage => isPinned;
  
  /// Check if message is deleted
  bool get isDeletedMessage => isDeleted;
  
  /// Check if message has reactions
  bool get hasReactions => reactions.isNotEmpty;
  
  /// Check if message is pinned by current user
  bool get isPinnedByMe => isPinnedByCurrentUser;
  
  /// Get message preview (first 50 characters)
  String get preview {
    if (text.isEmpty) return '';
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }
}

/// Extension methods for message sender handling
extension MessageSenderExtensions on MessageSender {
  /// Check if sender has profile images
  bool get hasImages => image.isNotEmpty;
  
  /// Check if sender has valid email
  bool get hasValidEmail => email.contains('@');
  
  /// Get sender initials
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial'.trim();
  }
}