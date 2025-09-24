import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/utils/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';


class AccountSetupService {
  static const String _tag = 'AccountSetupService';
  final Dio _dio;

  AccountSetupService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: LocalStorage.getAuthHeaders(),
          ),
        ) {
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Complete profile with optional images
  Future<Response> completeProfile({
    required Map<String, dynamic> data,
    List<File>? images,
  }) async {
    _log('POST', AppUrls.completeProfile, 'Starting request');
    try {
      final response = images != null && images.isNotEmpty
          ? await _submitMultipartProfile(data, images)
          : await _submitJsonProfile(data);

      _log('POST', AppUrls.completeProfile, 'Success: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _logError('completeProfile', e);
      rethrow;
    }
  }

  /// Complete profile with specific image fields (multipart)
  Future<Response> completeProfileMultipart({
    required Map<String, dynamic> data,
    File? bodyImage,
    File? headShotImage,
    File? personalityImage,
    List<File>? extraImages,
  }) async {
    _log('POST', AppUrls.completeProfile, 'Starting multipart request');
    try {
      final formData = await _buildMultipartFormData(
        data: data,
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
        extraImages: extraImages,
      );

      final response = await _dio.post(AppUrls.completeProfile, data: formData);
      _log('POST', AppUrls.completeProfile, 'Success: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _logError('completeProfileMultipart', e);
      rethrow;
    }
  }

  /// Upload only specific images
  Future<Response> uploadSpecificImages({
    required File bodyImage,
    required File headShotImage,
    required File personalityImage,
  }) async {
    _log('POST', AppUrls.completeProfile, 'Uploading specific images');
    try {
      final formData = FormData();
      final imageFiles = [
        ('bodyImage', bodyImage),
        ('headShotImage', headShotImage),
        ('personalityImage', personalityImage),
      ];

      for (final (fieldName, file) in imageFiles) {
        final filename = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          fieldName,
          await MultipartFile.fromFile(file.path, filename: filename),
        ));
      }

      final response = await _dio.post(AppUrls.completeProfile, data: formData);
      _log('POST', AppUrls.completeProfile, 'Success: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _logError('uploadSpecificImages', e);
      rethrow;
    }
  }

  // ===== Private Helpers =====

  Future<Response> _submitJsonProfile(Map<String, dynamic> data) async {
    final json = {
      ...data,
      'image': data.containsKey('image') ? data['image'] : <dynamic>[],
    };
    return await _dio.post(
      AppUrls.completeProfile,
      data: json,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> _submitMultipartProfile(
    Map<String, dynamic> data,
    List<File> images,
  ) async {
    final payload = Map<String, dynamic>.from(data);
    final files = <MultipartFile>[];

    for (final file in images) {
      try {
        final filename = file.path.split(Platform.pathSeparator).last;
        files.add(await MultipartFile.fromFile(file.path, filename: filename));
      } catch (_) {
        // Skip unreadable images silently
      }
    }

    payload['image'] = files;
    final formData = FormData.fromMap(payload);
    return await _dio.post(AppUrls.completeProfile, data: formData);
  }

  Future<FormData> _buildMultipartFormData({
    required Map<String, dynamic> data,
    File? bodyImage,
    File? headShotImage,
    File? personalityImage,
    List<File>? extraImages,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(data)));

    final specificImages = [
      ('bodyImage', bodyImage),
      ('headShotImage', headShotImage),
      ('personalityImage', personalityImage),
    ];

    for (final (fieldName, file) in specificImages) {
      if (file != null) {
        final filename = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          fieldName,
          await MultipartFile.fromFile(file.path, filename: filename),
        ));
      }
    }

    if (extraImages != null) {
      for (final file in extraImages) {
        final filename = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(file.path, filename: filename),
        ));
      }
    }
    return formData;
  }

  /// Minimal centralized logging for service calls
  void _log(String method, String endpoint, String message) {
    AppLogger.info('[$_tag] $method $endpoint: $message');
  }

  void _logError(String operation, DioException error) {
    AppLogger.error('[$_tag] $operation failed: ${error.message}');
    if (error.response != null) {
      AppLogger.error('[$_tag] Status: ${error.response?.statusCode}');
    }
  }
}
