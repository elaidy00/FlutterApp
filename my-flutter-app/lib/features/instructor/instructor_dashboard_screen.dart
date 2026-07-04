import 'package:flutter/material.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = [
      ('Design Systems', '24 learners enrolled', Icons.palette_outlined),
      ('Product Leadership', '12 live sessions scheduled', Icons.groups_outlined),
      ('Flutter Masterclass', '48 students active', Icons.code_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Instructor dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Monitor your courses and learner engagement from one place.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _MetricCard(title: 'Live learners', value: '86', icon: Icons.groups_outlined),
            _MetricCard(title: 'Revenue', value: '240 coins', icon: Icons.monetization_on_outlined),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('Active courses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            FilledButton.tonal(onPressed: () {}, child: const Text('View all')),
          ],
        ),
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
            CircleAvatar(backgroundColor: theme.colorScheme.tertiaryContainer, child: Icon(icon, color: theme.colorScheme.onTertiaryContainer)),
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
