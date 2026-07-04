import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/course.dart';
import '../../core/providers/course_provider.dart';

class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, this.courseId});

  final String? courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedCourseId = courseId ?? ModalRoute.of(context)?.settings.arguments as String? ?? 'unknown';
    final course = ref.read(courseProvider).firstWhere((item) => item.id == resolvedCourseId, orElse: () => const CourseModel(
      id: 'unknown',
      title: 'Course unavailable',
      instructor: 'LearnLoop',
      description: 'Course details are not available right now.',
      level: 'All levels',
      duration: '0 weeks',
      price: 'Free',
      rating: 0,
      lessons: 0,
      tag: 'Course',
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Course details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(label: Text(course.tag)),
            const SizedBox(height: 12),
            Text(course.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(course.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _InfoChip(label: 'Instructor', value: course.instructor),
              _InfoChip(label: 'Level', value: course.level),
              _InfoChip(label: 'Duration', value: course.duration),
              _InfoChip(label: 'Price', value: course.price),
            ]),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What you will learn', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('• Build polished, responsive interfaces'),
                    const Text('• Apply modern architecture and state management'),
                    const Text('• Deliver practical learning experiences with confidence'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/courseWatch', extra: course.id),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch course'),
              ),
            ),
          ],
        ),
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
