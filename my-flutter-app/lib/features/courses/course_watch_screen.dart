import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/providers/course_provider.dart';
import '../../core/models/dtos/course_dtos.dart';
import '../../core/services/api_client.dart';

class CourseWatchScreen extends ConsumerStatefulWidget {
  const CourseWatchScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseWatchScreen> createState() => _CourseWatchScreenState();
}

class _CourseWatchScreenState extends ConsumerState<CourseWatchScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  LessonResponseDto? _selectedLesson;
  final ApiClient _apiClient = ApiClient();

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _playLesson(LessonResponseDto lesson) async {
    if (_selectedLesson?.id == lesson.id) return;

    setState(() {
      _selectedLesson = lesson;
    });

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;

    final videoUrl = lesson.hlsVideoUrl.isNotEmpty ? lesson.hlsVideoUrl : lesson.videoUrl;
    if (videoUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoPlayerController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: controller,
            autoPlay: true,
            looping: false,
            aspectRatio: 16 / 9,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  Future<void> _completeLesson(String lessonId) async {
    try {
      final response = await _apiClient.dio.post('/courses/lessons/$lessonId/complete');
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson marked as completed!')),
        );
        ref.invalidate(courseDetailsProvider(widget.courseId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_apiClient.getErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Course')),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (course) {
          // Select first lesson if none selected
          if (_selectedLesson == null && (course.sections?.data.isNotEmpty ?? false)) {
            final firstSection = course.sections!.data.first;
            if (firstSection.lessons.isNotEmpty) {
              Future.microtask(() => _playLesson(firstSection.lessons.first));
            }
          }

          return Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
              ),
              if (_selectedLesson != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedLesson!.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _completeLesson(_selectedLesson!.id),
                        icon: const Icon(Icons.check),
                        label: const Text('Complete'),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Lessons'),
                          Tab(text: 'Summary'),
                          Tab(text: 'Notes'),
                          Tab(text: 'Transcript'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Lessons Tab
                            ListView(
                              children: course.sections?.data.map((section) => ExpansionTile(
                                    title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    initiallyExpanded: true,
                                    children: section.lessons.map((lesson) => ListTile(
                                          leading: Icon(
                                            _selectedLesson?.id == lesson.id
                                                ? Icons.play_circle_filled
                                                : Icons.play_circle_outline,
                                            color: _selectedLesson?.id == lesson.id
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                          ),
                                          title: Text(lesson.title),
                                          onTap: () => _playLesson(lesson),
                                        )).toList(),
                                  )).toList() ??
                                  [],
                            ),
                            // Summary Tab
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  _selectedLesson?.videoSummary.isNotEmpty ?? false
                                      ? _selectedLesson!.videoSummary
                                      : 'No summary available for this lesson.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            // Notes Tab
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  _selectedLesson?.videoNotes.isNotEmpty ?? false
                                      ? _selectedLesson!.videoNotes
                                      : 'No notes available for this lesson.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            // Transcript Tab
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  _selectedLesson?.videoTranscript.isNotEmpty ?? false
                                      ? _selectedLesson!.videoTranscript
                                      : 'No transcript available for this lesson.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
