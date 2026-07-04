import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../../features/home/home_feed_screen.dart';
import '../../features/student/student_dashboard_screen.dart';
import '../../features/instructor/instructor_dashboard_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeModeProvider);
    final role = authState.selectedRole ?? AppUserRole.student;

    final pages = <Widget>[
      const HomeFeedScreen(),
      role == AppUserRole.instructor
          ? const InstructorDashboardScreen()
          : const StudentDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnLoop'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        ],
      ),
    );
  }
}
