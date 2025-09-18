import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart'; 
import 'package:kindered_app/core/logger/app_logger.dart';

class AccountSetupService {
  final Dio _dio;

  AccountSetupService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

  /// Complete Profile POST request
  /// If [images] are provided, the request will be sent as multipart/form-data
  /// with the images attached under the key 'photos'.
  Future<Response> completeProfile({
    required Map<String, dynamic> data,
    List<File>? images,
  }) async {
    try {
      // Build payload
      Response response;
      if (images != null && images.isNotEmpty) {
        // Prepare multipart form data
        final payload = Map<String, dynamic>.from(data);
        // Attach images list
        final files = <MultipartFile>[];
        for (final file in images) {
          try {
            final filename = file.path.split(Platform.pathSeparator).last;
            files.add(await MultipartFile.fromFile(file.path, filename: filename));
          } catch (e, st) {
            AppLogger.warning('⚠️ Skipping an image that could not be read: ${file.path}', e, st as StackTrace?);
          }
        }
        // Backend expects key `image` to be an array
        payload['image'] = files;

        final formData = FormData.fromMap(payload);
        AppLogger.api('POST', AppUrls.completeProfile, data: '[multipart form with ${files.length} photos]');
        response = await _dio.post(
          AppUrls.completeProfile,
          data: formData,
        );
      } else {
        // JSON payload - ensure `image` key exists as an empty array if backend requires it
        final json = {
          ...data,
          'image': data.containsKey('image') ? data['image'] : <dynamic>[],
        };
        AppLogger.api('POST', AppUrls.completeProfile, data: json);
        response = await _dio.post(
          AppUrls.completeProfile,
          data: json,
          options: Options(contentType: Headers.jsonContentType),
        );
      }

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.completeProfile,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ Complete profile successful');
      return response;
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Complete profile failed: ${e.message}', e, e.stackTrace);
      final message = e.response?.data ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }

  /// Multipart variant to match Postman structure:
  /// - data: JSON text (all non-file fields in a single JSON string)
  /// - bodyImage: single file
  /// - headShotImage: single file
  /// - personalityImage: single file
  /// - image: multiple files (array)
  Future<Response> completeProfileMultipart({
    required Map<String, dynamic> data,
    File? bodyImage,
    File? headShotImage,
    File? personalityImage,
    List<File>? extraImages,
  }) async {
    try {
      final formData = FormData();

      // Add JSON text field 'data'
      formData.fields.add(MapEntry('data', jsonEncode(data)));

      // Add named single-image fields if present
      if (bodyImage != null) {
        final name = bodyImage.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'bodyImage',
          await MultipartFile.fromFile(bodyImage.path, filename: name),
        ));
      }
      if (headShotImage != null) {
        final name = headShotImage.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'headShotImage',
          await MultipartFile.fromFile(headShotImage.path, filename: name),
        ));
      }
      if (personalityImage != null) {
        final name = personalityImage.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'personalityImage',
          await MultipartFile.fromFile(personalityImage.path, filename: name),
        ));
      }

      // Add additional images under the same key 'image'
      if (extraImages != null && extraImages.isNotEmpty) {
        for (final file in extraImages) {
          final name = file.path.split(Platform.pathSeparator).last;
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(file.path, filename: name),
          ));
        }
      } else {
        // If backend strictly requires an array key, but no files, we still include empty array via 'data'
        // (the server should parse 'data' JSON and see image: [])
      }

      AppLogger.api('POST', AppUrls.completeProfile, data: '[multipart: data(json) + named images + image[](${extraImages?.length ?? 0})]');
      final response = await _dio.post(AppUrls.completeProfile, data: formData);

      AppLogger.api(
        'POST',
        AppUrls.completeProfile,
        data: response.data,
        statusCode: response.statusCode,
      );
      AppLogger.success('✅ Complete profile (multipart) successful');
      return response;
    } on DioException catch (e) {
      AppLogger.error('❌ Complete profile (multipart) failed: ${e.message}', e, e.stackTrace);
      final message = e.response?.data ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }
}
