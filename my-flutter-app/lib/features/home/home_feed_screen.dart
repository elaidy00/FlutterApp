import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/course_provider.dart';
import '../../core/models/dtos/course_dtos.dart';
import '../../core/widgets/info_tile.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final _searchController = TextEditingController();
  String? _selectedLevel;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchCourses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCourses() {
    ref.read(courseProvider.notifier).loadCourses(
          filter: CourseQueryFilter(
            search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
            level: _selectedLevel,
            subjectId: _selectedSubjectId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final courses = ref.watch(courseProvider);
    final roleLabel = authState.activeRole ?? 'Student';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, ${authState.user?.firstName ?? ""}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Continue your learning journey as a $roleLabel.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Chip(label: Text(roleLabel)),
          ],
        ),
        const SizedBox(height: 16),
        // Search and Filters
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _fetchCourses(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Show filter dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Filter Courses'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          decoration: const InputDecoration(labelText: 'Level'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All Levels')),
                            DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                            DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                            DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value;
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _fetchCourses();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const InfoTile(icon: Icons.workspace_premium_outlined, title: 'Your progress', value: 'Synced with your account'),
            const InfoTile(icon: Icons.calendar_month_outlined, title: 'Dashboard', value: 'Live activity overview'),
            InfoTile(icon: Icons.wallet_outlined, title: 'Role', value: roleLabel),
          ],
        ),
        const SizedBox(height: 20),
        Text('Recommended courses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No courses found.'),
            ),
          )
        else
          ...courses.map((course) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/course/${course.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(course.subjectName)),
                            const Spacer(),
                            Row(children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(course.averageRating.toStringAsFixed(1))
                            ]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(course.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(course.level, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(course.instructorName),
                            const Spacer(),
                            Text('${course.price} EGP'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}
