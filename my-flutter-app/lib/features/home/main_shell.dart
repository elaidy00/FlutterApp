import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'home_feed_screen.dart';
import '../instructor/instructor_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedRole = ref.watch(authProvider).selectedRole;
    final currentRole = selectedRole ?? AppUserRole.student;
    final isDark = ref.watch(themeModeProvider);

    final pages = <Widget>[
      const HomeFeedScreen(),
      currentRole == AppUserRole.instructor
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
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        ],
      ),
    );
  }
}
