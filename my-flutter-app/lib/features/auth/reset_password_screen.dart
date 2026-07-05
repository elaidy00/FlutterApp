import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/dtos/auth_dtos.dart';
import '../../core/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key, required this.email, required this.token});

  final String email;
  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
            const SizedBox(height: 12),
            TextField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  final dto = ResetPasswordDto(
                    email: email,
                    token: token,
                    newPassword: passwordController.text,
                    confirmNewPassword: confirmPasswordController.text,
                  );
                  await ref.read(authProvider.notifier).resetPassword(dto);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text('Update password'),
            ),
          ],
        ),
      ),
    );
  }
}
