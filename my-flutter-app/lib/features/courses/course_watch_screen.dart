import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/models/course.dart';
import '../../core/providers/course_provider.dart';

class CourseWatchScreen extends ConsumerStatefulWidget {
  const CourseWatchScreen({super.key, this.courseId});

  final String? courseId;

  @override
  ConsumerState<CourseWatchScreen> createState() => _CourseWatchScreenState();
}

class _CourseWatchScreenState extends ConsumerState<CourseWatchScreen> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCourseId = widget.courseId ?? ModalRoute.of(context)?.settings.arguments as String? ?? 'unknown';
    final course = ref.read(courseProvider).firstWhere((item) => item.id == resolvedCourseId, orElse: () => const CourseModel(
      id: 'unknown',
      title: 'Course unavailable',
      instructor: 'LearnLoop',
      description: '',
      level: 'All levels',
      duration: '0 weeks',
      price: 'Free',
      rating: 0,
      lessons: 0,
      tag: 'Course',
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Watch course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Now playing', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 4),
            Text(course.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_controller.value.isInitialized)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      setState(() {});
                    },
                    icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  Text('${_controller.value.position.inMinutes}:${(_controller.value.position.inSeconds % 60).toString().padLeft(2, '0')} / ${_controller.value.duration.inMinutes}:${(_controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
                ],
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lesson 1 · Intro to the course', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Start with the essential concept, then practice the workflow step by step.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
