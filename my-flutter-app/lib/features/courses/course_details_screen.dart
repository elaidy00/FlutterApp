import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/course_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/models/dtos/wallet_dtos.dart';

class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  Future<void> _buyCourse(BuildContext context, WidgetRef ref) async {
    final apiClient = ApiClient();
    try {
      final response = await apiClient.dio.post(
        '/wallet/buy-course',
        data: BuyCourseRequest(courseId: courseId).toJson(),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course purchased successfully!')),
        );
        ref.invalidate(courseDetailsProvider(courseId));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiClient.getErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailsProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (course) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Chip(label: Text(course.subjectName)),
                const SizedBox(height: 12),
                Text(course.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(course.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _InfoChip(label: 'Instructor', value: course.instructorName),
                  _InfoChip(label: 'Level', value: course.level),
                  _InfoChip(label: 'Price', value: '${course.price} EGP'),
                  _InfoChip(label: 'Rating', value: course.averageRating.toStringAsFixed(1)),
                ]),
                const SizedBox(height: 24),
                Text('Course Curriculum', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (course.sections?.data.isEmpty ?? true)
                  const Text('No sections available.')
                else
                  ...course.sections!.data.map((section) => ExpansionTile(
                        title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: section.lessons.map((lesson) => ListTile(
                              leading: Icon(lesson.isLocked ? Icons.lock_outline : Icons.play_circle_outline),
                              title: Text(lesson.title),
                              trailing: lesson.isPreview ? const Chip(label: Text('Preview')) : null,
                              onTap: () {
                                if (!lesson.isLocked) {
                                  context.push('/course/${course.id}/watch');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enroll in the course to unlock this lesson.')),
                                  );
                                }
                              },
                            )).toList(),
                      )),
                const SizedBox(height: 24),
                Text('About the Instructor', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: course.instructorImageUrl.isNotEmpty ? NetworkImage(course.instructorImageUrl) : null,
                      child: course.instructorImageUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.instructorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(course.instructorBio, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: course.isEnrolled || course.isOwner
                      ? FilledButton.icon(
                          onPressed: () => context.push('/course/${course.id}/watch'),
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Watch Course'),
                        )
                      : FilledButton.icon(
                          onPressed: () => _buyCourse(context, ref),
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: Text('Buy Course for ${course.price} EGP'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value', style: theme.textTheme.labelMedium),
    );
  }
}
