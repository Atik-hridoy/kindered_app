class SettingResponse {
  final bool success;
  final String message;
  final int statusCode;
  final String data;

  SettingResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory SettingResponse.fromJson(Map<String, dynamic> json) {
    return SettingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data,
    };
  }
}
