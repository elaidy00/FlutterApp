import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/course_provider.dart';
import '../../core/widgets/info_tile.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(courseProvider.notifier).loadCourses());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final courses = ref.watch(courseProvider);
    final selectedRole = authState.selectedRole ?? authState.user?.role;
    final roleLabel = selectedRole == AppUserRole.instructor ? 'Instructor' : 'Student';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Continue your learning journey as a $roleLabel.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Chip(label: Text(roleLabel)),
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
          children: const [
            InfoTile(icon: Icons.workspace_premium_outlined, title: 'Your progress', value: '82% complete'),
            InfoTile(icon: Icons.calendar_month_outlined, title: 'Next session', value: 'Today · 18:30'),
            InfoTile(icon: Icons.wallet_outlined, title: 'Wallet', value: '320 coins'),
          ],
        ),
        const SizedBox(height: 20),
        Text('Recommended courses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...courses.map((course) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/courseDetails', extra: course.id),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(label: Text(course.tag)),
                          const Spacer(),
                          Row(children: [const Icon(Icons.star, size: 16), const SizedBox(width: 4), Text(course.rating.toString())]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(course.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(course.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(course.instructor),
                          const Spacer(),
                          Text('${course.lessons} lessons · ${course.duration}'),
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
