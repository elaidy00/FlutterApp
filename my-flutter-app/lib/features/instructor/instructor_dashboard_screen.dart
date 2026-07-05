import 'package:flutter/material.dart';
import '../../core/services/api_client.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  late final Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<Map<String, dynamic>> _loadDashboard() async {
    final response = await ApiClient().dio.get('/instructors/me/dashboard');
    return ApiClient.extractResponseData(response.data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(snapshot.error.toString()),
            ),
          );
        }

        final data = snapshot.data ?? <String, dynamic>{};
        final firstName = data['firstName']?.toString() ?? 'Instructor';
        final lastName = data['lastName']?.toString() ?? '';
        final totalCourses = data['totalCourses']?.toString() ?? '0';
        final totalStudents = data['totalStudents']?.toString() ?? '0';
        final totalPublicSessions = data['totalPublicSessions']?.toString() ?? '0';
        final totalPrivateSessions = data['totalPrivateSessions']?.toString() ?? '0';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Instructor dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Track your teaching activity from the main platform.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(title: 'Courses', value: totalCourses, icon: Icons.school_outlined),
                _MetricCard(title: 'Students', value: totalStudents, icon: Icons.groups_outlined),
                _MetricCard(title: 'Public sessions', value: totalPublicSessions, icon: Icons.event_outlined),
                _MetricCard(title: 'Private sessions', value: totalPrivateSessions, icon: Icons.lock_clock_outlined),
              ],
            ),
            const SizedBox(height: 20),
            Text('Welcome $firstName $lastName', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        );
      },
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
