import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/verify_email_screen.dart';
import 'features/auth/verify_2fa_screen.dart';
import 'features/auth/forget_password_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/courses/course_details_screen.dart';
import 'features/courses/course_watch_screen.dart';
import 'features/home/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final is2faRequired = authState.is2faRequired;
      final isEmailVerificationRequired = authState.isEmailVerificationRequired;
      final needsRoleSelection = authState.needsRoleSelection();

      final location = state.uri.toString();

      // 1. If 2FA is required, redirect to verify-2fa
      if (is2faRequired && !location.startsWith('/verify-2fa')) {
        return '/verify-2fa';
      }

      // 2. If email verification is required, redirect to verify-email
      if (isEmailVerificationRequired && !location.startsWith('/verify-email')) {
        return '/verify-email';
      }

      // 3. If role selection is needed, redirect to roles
      if (needsRoleSelection && !location.startsWith('/roles')) {
        return '/roles';
      }

      // 4. Auth Guard: If not authenticated, only allow auth routes
      final isAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register') ||
          location.startsWith('/forget-password') ||
          location.startsWith('/reset-password') ||
          location.startsWith('/verify-email') ||
          location.startsWith('/verify-2fa');

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 5. Log Guard: If authenticated, redirect away from auth routes to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forget-password',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/verify-2fa',
        builder: (context, state) => const Verify2FAScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id'] ?? '';
          return CourseDetailsScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course/:id/watch',
        builder: (context, state) {
          final courseId = state.pathParameters['id'] ?? '';
          return CourseWatchScreen(courseId: courseId);
        },
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final router = ref.watch(_routerProvider);
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
      routerConfig: router,
    );
  }
}
