import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/course_dtos.dart';
import '../services/api_client.dart';

class CourseNotifier extends StateNotifier<List<CourseOverviewDto>> {
  CourseNotifier() : super(const []);

  final ApiClient _apiClient = ApiClient();

  Future<void> loadCourses({CourseQueryFilter filter = const CourseQueryFilter()}) async {
    try {
      final response = await _apiClient.dio.get(
        '/courses',
        queryParameters: filter.toQueryParams(),
      );
      final payload = response.data;
      final data = payload['data'];
      if (data is List) {
        state = data
            .map((item) => CourseOverviewDto.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        state = (data['data'] as List)
            .map((item) => CourseOverviewDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      rethrow;
    }
  }
}

final courseProvider = StateNotifierProvider<CourseNotifier, List<CourseOverviewDto>>(
  (ref) => CourseNotifier(),
);

final courseDetailsProvider = FutureProvider.family<CourseResponseDto, String>((ref, courseId) async {
  final apiClient = ApiClient();
  final response = await apiClient.dio.get('/courses/$courseId');
  final payload = response.data;
  final data = payload['data'];
  return CourseResponseDto.fromJson(data as Map<String, dynamic>);
});
