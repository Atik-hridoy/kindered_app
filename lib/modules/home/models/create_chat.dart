class CreateChatResponse {
  final bool success;
  final String message;
  final int statusCode;
  final ChatData data;

  CreateChatResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory CreateChatResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatResponse(
      success: json['success'],
      message: json['message'],
      statusCode: json['statusCode'],
      data: ChatData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "statusCode": statusCode,
      "data": data.toJson(),
    };
  }
}

class ChatData {
  final List<String> participants;
  final String? lastMessage;
  final String status;
  final bool isDeleted;
  final List<dynamic> readBy;
  final List<dynamic> mutedBy;
  final String id;
  final List<dynamic> deletedByDetails;
  final List<dynamic> blockedUsers;
  final List<dynamic> userPinnedMessages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ChatData({
    required this.participants,
    required this.lastMessage,
    required this.status,
    required this.isDeleted,
    required this.readBy,
    required this.mutedBy,
    required this.id,
    required this.deletedByDetails,
    required this.blockedUsers,
    required this.userPinnedMessages,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      participants: List<String>.from(json['participants']),
      lastMessage: json['lastMessage'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      readBy: json['readBy'] ?? [],
      mutedBy: json['mutedBy'] ?? [],
      id: json['_id'],
      deletedByDetails: json['deletedByDetails'] ?? [],
      blockedUsers: json['blockedUsers'] ?? [],
      userPinnedMessages: json['userPinnedMessages'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "participants": participants,
      "lastMessage": lastMessage,
      "status": status,
      "isDeleted": isDeleted,
      "readBy": readBy,
      "mutedBy": mutedBy,
      "_id": id,
      "deletedByDetails": deletedByDetails,
      "blockedUsers": blockedUsers,
      "userPinnedMessages": userPinnedMessages,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "__v": v,
    };
  }
}
