import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/course_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/models/dtos/wallet_dtos.dart';

String getEnrollmentButtonLabel({
  required bool isEnrolled,
  required bool isOwner,
  required int price,
  required bool isStudent,
}) {
  if (isEnrolled || isOwner) {
    return 'Continue Learning';
  }
  if (!isStudent) {
    return 'Continue Learning';
  }
  if (price > 0) {
    return 'Buy for ${formatCoursePrice(price)}';
  }
  return 'Enroll Free';
}

String formatCoursePrice(int price) {
  if (price <= 0) {
    return 'Free';
  }
  return '\$${price.toStringAsFixed(2)}';
}

class CourseDetailsScreen extends ConsumerStatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  bool _showEnrollConfirm = false;
  bool _enrolling = false;
  int? _walletBalance;

  Future<void> _enrollCourse(BuildContext context) async {
    final apiClient = ApiClient();
    final courseAsync = ref.read(courseDetailsProvider(widget.courseId));
    if (courseAsync.hasValue && courseAsync.valueOrNull != null) {
      final course = courseAsync.valueOrNull!;
      if (course.isEnrolled || course.isOwner) {
        context.push('/course/${course.id}/watch');
        return;
      }
      if (course.price > 0) {
        setState(() {
          _showEnrollConfirm = true;
          _walletBalance = null;
        });
        try {
          final response = await apiClient.dio.get('/wallet/balance');
          if (response.statusCode == 200) {
            final data = response.data['data'] as Map<String, dynamic>? ?? {};
            setState(() {
              _walletBalance = (data['coins'] as num?)?.toInt() ?? 0;
            });
          }
        } catch (_) {
          setState(() {
            _walletBalance = null;
          });
        }
        return;
      }
      _confirmEnrollment(context, isPaid: false);
      return;
    }
  }

  Future<void> _confirmEnrollment(BuildContext context, {required bool isPaid}) async {
    final apiClient = ApiClient();
    final courseAsync = ref.read(courseDetailsProvider(widget.courseId));
    if (courseAsync.hasValue && courseAsync.valueOrNull != null) {
      final course = courseAsync.valueOrNull!;
      setState(() {
        _enrolling = true;
      });
      try {
        final response = isPaid
            ? await apiClient.dio.post(
                '/wallet/buy-course',
                data: BuyCourseRequest(courseId: course.id.toString()).toJson(),
              )
            : await apiClient.dio.post(
                '/courses/${course.id}/subscribe',
                data: {},
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isPaid ? 'Course purchased successfully!' : 'You are enrolled!'),
            ),
          );
          setState(() {
            _enrolling = false;
            _showEnrollConfirm = false;
          });
          ref.invalidate(courseDetailsProvider(widget.courseId));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiClient.getErrorMessage(e))),
        );
        setState(() {
          _enrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    final authState = ref.watch(authProvider);
    final isStudent = authState.activeRole == 'Student';

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
                  _InfoChip(label: 'Price', value: course.price > 0 ? formatCoursePrice(course.price) : 'Free'),
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
                  child: (isStudent || course.isEnrolled || course.isOwner)
                      ? FilledButton.icon(
                          onPressed: () => _enrollCourse(context),
                          icon: const Icon(Icons.play_circle_outline),
                          label: Text(getEnrollmentButtonLabel(
                            isEnrolled: course.isEnrolled,
                            isOwner: course.isOwner,
                            price: course.price,
                            isStudent: isStudent,
                          )),
                        )
                      : const SizedBox.shrink(),
                ),
                if (!_showEnrollConfirm) const SizedBox.shrink(),
                if (_showEnrollConfirm)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirm enrollment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Are you sure you want to ${course.price > 0 ? 'purchase' : 'enroll in'} ${course.title}?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (course.price > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Course price'),
                              Text(formatCoursePrice(course.price)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Your balance'),
                              Text(_walletBalance == null ? '—' : formatCoursePrice(_walletBalance!)),
                            ],
                          ),
                          if (_walletBalance != null && _walletBalance! < course.price) ...[
                            const SizedBox(height: 8),
                            Text(
                              'You do not have enough coins. Top up your wallet first.',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 12),
                          const Text('This course is free. You will get immediate access after confirming.'),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _enrolling ? null : () => setState(() => _showEnrollConfirm = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _enrolling || (course.price > 0 && _walletBalance != null && _walletBalance! < course.price)
                                  ? null
                                  : () => _confirmEnrollment(context, isPaid: course.price > 0),
                              child: _enrolling
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(course.price > 0 ? 'Yes, purchase' : 'Yes, enroll'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (!isStudent && !course.isEnrolled && !course.isOwner)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Enrollment is available for students only.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
