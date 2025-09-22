import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart'; 
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';

class AccountSetupService {
  final Dio _dio;

  AccountSetupService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: LocalStorage.getAuthHeaders(),
          ),
        ) {
    // Ensure the token is set correctly
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

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
      
      // Log request details similar to Postman
      AppLogger.info('🌐 [POSTMAN-STYLE REQUEST] ====================================');
      AppLogger.info('📡 Method: POST');
      AppLogger.info('🔗 URL: ${AppUrls.baseUrl}${AppUrls.completeProfile}');
      AppLogger.info('📋 Headers:');
      _dio.options.headers.forEach((key, value) => AppLogger.info('  • $key: $value'));
      
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
        
        // Log multipart form data
        AppLogger.info('📤 Body (MULTIPART FORM DATA):');
        AppLogger.info('  • Content-Type: multipart/form-data');
        AppLogger.info('  • Fields:');
        payload.forEach((key, value) {
          if (key != 'image') {
            AppLogger.info('    - $key: $value');
          }
        });
        AppLogger.info('  • Files:');
        for (int i = 0; i < files.length; i++) {
          AppLogger.info('    - image[$i]: ${files[i].filename} (${(files[i].length / 1024).toStringAsFixed(2)} KB)');
        }
        
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
        
        // Log JSON payload
        AppLogger.info('📤 Body (JSON):');
        AppLogger.info('  • Content-Type: application/json');
        AppLogger.info('  • Payload:');
        AppLogger.info('    ${const JsonEncoder.withIndent('    ').convert(json)}');
        
        response = await _dio.post(
          AppUrls.completeProfile,
          data: json,
          options: Options(contentType: Headers.jsonContentType),
        );
      }

      // Log the API response
      AppLogger.info('📡 [RESPONSE] ====================================');
      AppLogger.info('🔢 Status Code: ${response.statusCode}');
      AppLogger.info('📋 Status Message: ${response.statusMessage}');
      AppLogger.info('📤 Response Headers:');
      response.headers.forEach((name, values) => AppLogger.info('  • $name: ${values.join(', ')}'));
      AppLogger.info('📦 Response Body:');
      AppLogger.info('    ${const JsonEncoder.withIndent('    ').convert(response.data)}');
      
      AppLogger.success('✅ Complete profile successful');
      return response;
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ [ERROR] ====================================');
      AppLogger.error('🔢 Error Type: ${e.type}');
      AppLogger.error('📡 Error Message: ${e.message}');
      AppLogger.error('🔗 URL: ${e.requestOptions.uri}');
      AppLogger.error('📋 Request Headers:');
      e.requestOptions.headers.forEach((key, value) => AppLogger.error('  • $key: $value'));
      if (e.requestOptions.data != null) {
        AppLogger.error('📤 Request Data: ${e.requestOptions.data}');
      }
      if (e.response != null) {
        AppLogger.error('🔢 Response Status: ${e.response?.statusCode}');
        AppLogger.error('📦 Response Data: ${e.response?.data}');
      }
      AppLogger.error('📚 Stack Trace: ${e.stackTrace}');
      
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
      // Log request details similar to Postman
      AppLogger.info('🌐 [POSTMAN-STYLE REQUEST] ====================================');
      AppLogger.info('📡 Method: POST');
      AppLogger.info('🔗 URL: ${AppUrls.baseUrl}${AppUrls.completeProfile}');
      AppLogger.info('📋 Headers:');
      _dio.options.headers.forEach((key, value) => AppLogger.info('  • $key: $value'));
      
      final formData = FormData();

      // Add JSON text field 'data'
      final jsonData = jsonEncode(data);
      formData.fields.add(MapEntry('data', jsonData));

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

      // Log multipart form data details
      AppLogger.info('📤 Body (MULTIPART FORM DATA):');
      AppLogger.info('  • Content-Type: multipart/form-data');
      AppLogger.info('  • Fields:');
      AppLogger.info('    - data: (JSON string)');
      AppLogger.info('    ${const JsonEncoder.withIndent('    ').convert(data)}');
      AppLogger.info('  • Files:');
      if (bodyImage != null) {
        final fileSize = await bodyImage.length();
        AppLogger.info('    - bodyImage: ${bodyImage.path.split(Platform.pathSeparator).last} (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      }
      if (headShotImage != null) {
        final fileSize = await headShotImage.length();
        AppLogger.info('    - headShotImage: ${headShotImage.path.split(Platform.pathSeparator).last} (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      }
      if (personalityImage != null) {
        final fileSize = await personalityImage.length();
        AppLogger.info('    - personalityImage: ${personalityImage.path.split(Platform.pathSeparator).last} (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      }
      if (extraImages != null && extraImages.isNotEmpty) {
        for (int i = 0; i < extraImages.length; i++) {
          final fileSize = await extraImages[i].length();
          AppLogger.info('    - image[$i]: ${extraImages[i].path.split(Platform.pathSeparator).last} (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        }
      }

      final response = await _dio.post(AppUrls.completeProfile, data: formData);

      // Log the API response
      AppLogger.info('📡 [RESPONSE] ====================================');
      AppLogger.info('🔢 Status Code: ${response.statusCode}');
      AppLogger.info('📋 Status Message: ${response.statusMessage}');
      AppLogger.info('📤 Response Headers:');
      response.headers.forEach((name, values) => AppLogger.info('  • $name: ${values.join(', ')}'));
      AppLogger.info('📦 Response Body:');
      AppLogger.info('    ${const JsonEncoder.withIndent('    ').convert(response.data)}');
      
      AppLogger.success('✅ Complete profile (multipart) successful');
      return response;
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ [ERROR] ====================================');
      AppLogger.error('🔢 Error Type: ${e.type}');
      AppLogger.error('📡 Error Message: ${e.message}');
      AppLogger.error('🔗 URL: ${e.requestOptions.uri}');
      AppLogger.error('📋 Request Headers:');
      e.requestOptions.headers.forEach((key, value) => AppLogger.error('  • $key: $value'));
      if (e.requestOptions.data != null) {
        AppLogger.error('📤 Request Data: ${e.requestOptions.data}');
      }
      if (e.response != null) {
        AppLogger.error('🔢 Response Status: ${e.response?.statusCode}');
        AppLogger.error('📦 Response Data: ${e.response?.data}');
      }
      AppLogger.error('📚 Stack Trace: ${e.stackTrace}');
      
      final message = e.response?.data ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }

  /// Upload only the 3 specific images: bodyImage, headShotImage, and personalityImage
  /// This method handles only image upload, separate from profile data
  Future<Response> uploadSpecificImages({
    required File bodyImage,
    required File headShotImage,
    required File personalityImage,
  }) async {
    try {
      // Log request details similar to Postman
      AppLogger.info('🌐 [POSTMAN-STYLE REQUEST] ====================================');
      AppLogger.info('📡 Method: POST');
      AppLogger.info('🔗 URL: ${AppUrls.baseUrl}${AppUrls.completeProfile}');
      AppLogger.info('📋 Headers:');
      _dio.options.headers.forEach((key, value) => AppLogger.info('  • $key: $value'));
      
      final formData = FormData();

      // Add the 3 specific image fields
      final bodyImageName = bodyImage.path.split(Platform.pathSeparator).last;
      final headShotImageName = headShotImage.path.split(Platform.pathSeparator).last;
      final personalityImageName = personalityImage.path.split(Platform.pathSeparator).last;

      formData.files.add(MapEntry(
        'bodyImage',
        await MultipartFile.fromFile(bodyImage.path, filename: bodyImageName),
      ));
      formData.files.add(MapEntry(
        'headShotImage',
        await MultipartFile.fromFile(headShotImage.path, filename: headShotImageName),
      ));
      formData.files.add(MapEntry(
        'personalityImage',
        await MultipartFile.fromFile(personalityImage.path, filename: personalityImageName),
      ));

      // Log multipart form data details
      AppLogger.info('📤 Body (MULTIPART FORM DATA):');
      AppLogger.info('  • Content-Type: multipart/form-data');
      AppLogger.info('  • Files:');
      final bodyFileSize = await bodyImage.length();
      final headShotFileSize = await headShotImage.length();
      final personalityFileSize = await personalityImage.length();
      
      AppLogger.info('    - bodyImage: $bodyImageName (${(bodyFileSize / 1024).toStringAsFixed(2)} KB)');
      AppLogger.info('    - headShotImage: $headShotImageName (${(headShotFileSize / 1024).toStringAsFixed(2)} KB)');
      AppLogger.info('    - personalityImage: $personalityImageName (${(personalityFileSize / 1024).toStringAsFixed(2)} KB)');

      final response = await _dio.post(AppUrls.completeProfile, data: formData);

      // Log the API response
      AppLogger.info('📡 [RESPONSE] ====================================');
      AppLogger.info('🔢 Status Code: ${response.statusCode}');
      AppLogger.info('📋 Status Message: ${response.statusMessage}');
      AppLogger.info('📤 Response Headers:');
      response.headers.forEach((name, values) => AppLogger.info('  • $name: ${values.join(', ')}'));
      AppLogger.info('📦 Response Body:');
      AppLogger.info('    ${const JsonEncoder.withIndent('    ').convert(response.data)}');
      
      AppLogger.success('✅ 3 specific images uploaded successfully');
      return response;
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ [ERROR] ====================================');
      AppLogger.error('🔢 Error Type: ${e.type}');
      AppLogger.error('📡 Error Message: ${e.message}');
      AppLogger.error('🔗 URL: ${e.requestOptions.uri}');
      AppLogger.error('📋 Request Headers:');
      e.requestOptions.headers.forEach((key, value) => AppLogger.error('  • $key: $value'));
      if (e.requestOptions.data != null) {
        AppLogger.error('📤 Request Data: ${e.requestOptions.data}');
      }
      if (e.response != null) {
        AppLogger.error('🔢 Response Status: ${e.response?.statusCode}');
        AppLogger.error('📦 Response Data: ${e.response?.data}');
      }
      AppLogger.error('📚 Stack Trace: ${e.stackTrace}');
      
      final message = e.response?.data ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }
}
