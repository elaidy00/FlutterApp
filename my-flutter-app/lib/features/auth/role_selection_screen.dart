import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/auth_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final roles = authState.assignableRoles;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AuthCard(
            title: 'Choose your path',
            subtitle: 'Select the experience that fits you best and continue.',
            child: Column(
              children: [
                if (roles.contains('Student')) ...[
                  _RoleOptionCard(
                    title: 'Student',
                    subtitle: 'Discover courses, manage progress, and keep learning.',
                    icon: Icons.school_outlined,
                    onTap: () async {
                      await ref.read(authProvider.notifier).setActiveRole('Student');
                      if (context.mounted) context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                if (roles.contains('Instructor')) ...[
                  _RoleOptionCard(
                    title: 'Instructor',
                    subtitle: 'Create sessions, shape curriculum, and support learners.',
                    icon: Icons.co_present_outlined,
                    onTap: () async {
                      await ref.read(authProvider.notifier).setActiveRole('Instructor');
                      if (context.mounted) context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                if (roles.contains('Admin') || roles.contains('SuperAdmin')) ...[
                  _RoleOptionCard(
                    title: 'Admin',
                    subtitle: 'Manage platform, users, subjects, and payments.',
                    icon: Icons.admin_panel_settings_outlined,
                    onTap: () async {
                      final role = roles.contains('SuperAdmin') ? 'SuperAdmin' : 'Admin';
                      await ref.read(authProvider.notifier).setActiveRole(role);
                      if (context.mounted) context.go('/home');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
