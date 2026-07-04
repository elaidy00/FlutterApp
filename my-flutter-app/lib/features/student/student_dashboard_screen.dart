import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = [
      ('Design Systems', 'Continue your UI foundations course', Icons.book_outlined),
      ('Growth Strategy', 'Review your latest product sprint notes', Icons.timeline_outlined),
      ('Flutter Practice', 'Practice the advanced widget composition lesson', Icons.code_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Student dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Keep momentum with your current learning plan.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _MetricCard(title: 'Completed', value: '12 lessons', icon: Icons.check_circle_outline),
            _MetricCard(title: 'Weekly goal', value: '4 sessions', icon: Icons.flag_outlined),
          ],
        ),
        const SizedBox(height: 20),
        Text('Current courses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...courses.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(child: Icon(entry.$3)),
                title: Text(entry.$1),
                subtitle: Text(entry.$2),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            )),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Icon(icon, color: theme.colorScheme.onPrimaryContainer)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
