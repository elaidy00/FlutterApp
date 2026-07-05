import 'package:flutter/material.dart';
import '../../core/services/api_client.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late final Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<Map<String, dynamic>> _loadDashboard() async {
    final response = await ApiClient().dio.get('/students/me/dashboard');
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
        final firstName = data['firstName']?.toString() ?? 'Learner';
        final lastName = data['lastName']?.toString() ?? '';
        final walletCoins = data['walletCoins']?.toString() ?? '0';
        final enrolledCoursesCount = data['enrolledCoursesCount']?.toString() ?? '0';
        final publicSessionsCount = data['publicSessionsCount']?.toString() ?? '0';
        final privateBookingsCount = data['privateBookingsCount']?.toString() ?? '0';
        final pendingRequestsCount = data['pendingRequestsCount']?.toString() ?? '0';
        final awaitingSlotSelectionCount = data['awaitingSlotSelectionCount']?.toString() ?? '0';
        final recentCourses = (data['recentCourses'] as List<dynamic>?) ?? <dynamic>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Student dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Welcome $firstName $lastName. Your activity is synced from the main platform.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(title: 'Wallet', value: '$walletCoins coins', icon: Icons.account_balance_wallet_outlined),
                _MetricCard(title: 'Enrolled', value: '$enrolledCoursesCount courses', icon: Icons.check_circle_outline),
                _MetricCard(title: 'Public sessions', value: publicSessionsCount, icon: Icons.event_outlined),
                _MetricCard(title: 'Private bookings', value: privateBookingsCount, icon: Icons.lock_clock_outlined),
              ],
            ),
            const SizedBox(height: 20),
            Text('Active items', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _StatusCard(title: 'Pending requests', value: pendingRequestsCount, icon: Icons.pending_actions_outlined),
            const SizedBox(height: 8),
            _StatusCard(title: 'Awaiting slot selection', value: awaitingSlotSelectionCount, icon: Icons.schedule_outlined),
            const SizedBox(height: 20),
            Text('Recent courses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...recentCourses.map((entry) {
              final course = entry is Map<String, dynamic> ? entry : <String, dynamic>{};
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.book_outlined)),
                  title: Text(course['title']?.toString() ?? 'Course'),
                  subtitle: Text(course['description']?.toString() ?? 'Updated from the existing learning platform'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ),
              );
            }).toList(),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: theme.colorScheme.secondaryContainer, child: Icon(icon, color: theme.colorScheme.onSecondaryContainer)),
        title: Text(title),
        trailing: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
