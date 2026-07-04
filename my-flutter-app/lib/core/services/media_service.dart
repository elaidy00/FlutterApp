import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';

class MediaService {
  MediaService({ApiClient? apiClient, ImagePicker? imagePicker})
      : _apiClient = apiClient ?? ApiClient(),
        _imagePicker = imagePicker ?? ImagePicker();

  final ApiClient _apiClient;
  final ImagePicker _imagePicker;

  Future<String?> pickAndUploadImage({String endpoint = '/upload/community/upload'}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return null;
      }

      final file = File(pickedFile.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: pickedFile.name),
      });

      final response = await _apiClient.dio.post(endpoint, data: formData);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data ?? {});
        return data['url']?.toString() ?? data['data']?['url']?.toString();
      }
    } catch (error) {
      debugPrint('Upload failed: $error');
    }
    return null;
  }
}
