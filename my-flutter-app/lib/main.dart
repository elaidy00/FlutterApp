import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/courses/course_details_screen.dart';
import 'features/courses/course_watch_screen.dart';
import 'features/home/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/roles', builder: (context, state) => const RoleSelectionScreen()),
    GoRoute(path: '/home', builder: (context, state) => const MainShell()),
    GoRoute(
      path: '/courseDetails',
      builder: (context, state) {
        final courseId = state.extra as String? ?? 'c1';
        return CourseDetailsScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/courseWatch',
      builder: (context, state) {
        final courseId = state.extra as String? ?? 'c1';
        return CourseWatchScreen(courseId: courseId);
      },
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LearnLoop',
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        colorScheme: colorScheme.copyWith(
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
      ),
      routerConfig: _router,
    );
  }
}
