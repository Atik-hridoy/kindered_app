import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../models/send_message_model.dart';
import 'dart:io';

class SendMessageService {
  final Dio _dio = Dio();

  /// Send a message to a specific chat
  /// 
  /// Parameters:
  /// - [chatId]: The ID of the chat to send the message to
  /// - [content]: The message content/text
  /// - [messageType]: Type of message (default: 'text')
  /// 
  /// Returns a SendMessageResponse containing the server response
  Future<SendMessageResponse> sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      // Get authentication token
      final token = LocalStorage.token;
      
      if (token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }
      
      
      // Replace the :chatId placeholder in the URL with the actual chat ID
      final endpoint = AppUrls.sentMessage.replaceAll(':chatId', chatId);
      final url = '${AppUrls.baseUrl}$endpoint';
      
      
      // Prepare request data based on message type
      Map<String, dynamic> requestData;
      
      switch (messageType.toLowerCase()) {
        case 'image':
          // For image messages, parse the content to extract image URL and caption
          final lines = content.split('\n');
          final imageUrl = lines.last;
          final caption = lines.length > 1 ? lines.sublist(0, lines.length - 1).join('\n') : '';
          
          requestData = {
            'text': caption,
            'images': [imageUrl],
            'type': 'image',
          };
          break;
          
        case 'both':
        
          // For mixed messages (text + image)
          final lines = content.split('\n');
          final imageUrl = lines.last;
          final text = lines.length > 1 ? lines.sublist(0, lines.length - 1).join('\n') : content;
          
          requestData = {
            'text': text,
            'images': [imageUrl],
            'type': 'both', // or 'mixed' based on what the API expects
          };
          break;
          
        case 'text':
        default:
          // For text messages or any other type
          requestData = {
            'text': content,
            'images': null,
            'type': messageType.toLowerCase(), // Use the provided type
          };
          break;
      }
      
      
      // Make the POST request
      final response = await _dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      
      return SendMessageResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      // Handle Dio-specific errors
      
      if (e.response != null) {
        // Server responded with an error
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        
        // Handle specific HTTP status codes
        switch (statusCode) {
          case 400:
            throw Exception('Bad request: ${responseData['message'] ?? 'Invalid request data'}');
          case 401:
            throw Exception('Authentication failed. Please login again.');
          case 403:
            throw Exception('Forbidden: You do not have permission to send messages to this chat');
          case 404:
            throw Exception('Chat not found. Please check the chat ID and try again.');
          case 422:
            throw Exception('Validation error: ${responseData['message'] ?? 'Invalid message data'}');
          case 429:
            throw Exception('Too many requests. Please wait before sending another message.');
          case 500:
            throw Exception('Server error. Please try again later.');
          case 502:
          case 503:
          case 504:
            throw Exception('Service unavailable. Please check your connection and try again.');
          default:
            throw Exception('Failed to send message: ${responseData['message'] ?? 'Unknown error occurred'}');
        }
      } else {
        // Network error or no response from server
        
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Network connection error. Please check your internet connection.');
        } else {
          throw Exception('Network error: ${e.message ?? 'Unknown network error occurred'}');
        }
      }
      
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Send a message with image using form-data (matches Postman setup)
  /// 
  /// Parameters:
  /// - [chatId]: The ID of the chat to send the message to
  /// - [imageFile]: The image file to send
  /// - [content]: Optional text content to send with the image
  /// 
  /// Returns a SendMessageResponse containing the server response
  Future<SendMessageResponse> sendMessageWithImage({
    required String chatId,
    required File imageFile,
    String content = '',
  }) async {
    try {
      // Get authentication token
      final token = LocalStorage.token;
      
      if (token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }
      
      // Prepare the multipart request with 'images' field as per Postman
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (content.isNotEmpty) 'content': content,
      });
      
      
      // Make the request to the send message endpoint
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.sentMessage.replaceFirst(':chatId', chatId)}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SendMessageResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data as Map<String, dynamic>;
        
        switch (statusCode) {
          case 400:
            throw Exception('Bad request: ${responseData['message'] ?? 'Invalid message data'}');
          case 401:
            throw Exception('Authentication failed. Please login again.');
          case 403:
            throw Exception('Permission denied. You cannot send messages to this chat.');
          case 404:
            throw Exception('Chat not found.');
          case 413:
            throw Exception('Image file too large. Please choose a smaller image.');
          case 429:
            throw Exception('Too many requests. Please wait before sending another message.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Failed to send message: ${responseData['message'] ?? 'Unknown error occurred'}');
        }
      } else {
        // Network error or no response from server
        
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Network connection error. Please check your internet connection.');
        } else {
          throw Exception('Network error: ${e.message ?? 'Unknown network error occurred'}');
        }
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Convenience method to send a text message (most common use case)
  Future<SendMessageResponse> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    return sendMessage(
      chatId: chatId,
      content: content,
      messageType: 'text',
    );
  }

  /// Convenience method to send an image message
  Future<SendMessageResponse> sendImageMessage({
    required String chatId,
    required String imageUrl,
    String? caption,
  }) async {
    final content = caption != null && caption.isNotEmpty 
        ? '$caption\n$imageUrl' 
        : imageUrl;
    
    return sendMessage(
      chatId: chatId,
      content: content,
      messageType: 'image',
    );
  }

  /// Convenience method to send a mixed message (text + image)
  Future<SendMessageResponse> sendMixedMessage({
    required String chatId,
    required String text,
    required String imageUrl,
    String messageType = 'both', // can be 'both', 'mixed', or custom
  }) async {
    final content = '$text\n$imageUrl';
    
    return sendMessage(
      chatId: chatId,
      content: content,
      messageType: messageType,
    );
  }

  /// Convenience method to send a custom message type
  Future<SendMessageResponse> sendCustomMessage({
    required String chatId,
    required String content,
    required String messageType, // any custom type like 'file', 'audio', 'video', etc.
    List<String>? images, // optional images for custom types
  }) async {
    // For custom types, we'll use the main sendMessage method directly
    // but with custom handling for images
    if (images != null && images.isNotEmpty) {
      // If images are provided, include them in the content
      final imageContent = images.join('\n');
      final fullContent = '$content\n$imageContent';
      
      return sendMessage(
        chatId: chatId,
        content: fullContent,
        messageType: messageType,
      );
    } else {
      return sendMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
      );
    }
  }

  /// Check if a message content is valid before sending
  bool isValidMessageContent(String content) {
    if (content.trim().isEmpty) {
      return false;
    }
    
    // You can add additional validation rules here
    // For example, maximum length check
    if (content.length > 5000) {
      return false;
    }
    
    return true;
  }

  /// Validate chat ID format
  bool isValidChatId(String chatId) {
    if (chatId.trim().isEmpty) {
      return false;
    }
    
    // Basic MongoDB ObjectId validation (24 hex characters)
    final objectIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');
    return objectIdRegex.hasMatch(chatId);
  }

}
