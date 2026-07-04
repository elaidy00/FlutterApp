import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../services/api_client.dart';

class CourseNotifier extends StateNotifier<List<CourseModel>> {
  CourseNotifier({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const []);

  final ApiClient _apiClient;

  Future<void> loadCourses() async {
    try {
      final response = await _apiClient.dio.get('/courses');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data ?? {});
      final data = payload['data'];
      if (data is List) {
        state = data
            .whereType<Map<String, dynamic>>()
            .map(CourseModel.fromApi)
            .toList();
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        state = (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(CourseModel.fromApi)
            .toList();
      }
    } catch (_) {
      rethrow;
    }
  }
}

final courseProvider = StateNotifierProvider<CourseNotifier, List<CourseModel>>(
  (ref) => CourseNotifier(),
);
