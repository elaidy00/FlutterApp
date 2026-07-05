import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    try {
      final response = await ApiClient().dio.get('/profiles/users/1');
      return ApiClient.extractResponseData(response.data);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
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

        final profile = snapshot.data ?? <String, dynamic>{};
        final fallbackName = authState.user?.name ?? 'Learner';
        final displayName = '${profile['firstName'] ?? fallbackName.split(' ').first ?? ''} ${profile['lastName'] ?? fallbackName.split(' ').skip(1).join(' ') ?? ''}'.trim();
        final email = profile['email']?.toString() ?? authState.user?.email ?? 'No email';
        final rawRoles = (profile['roles'] as List<dynamic>?)?.map((role) => role.toString()).toList() ?? <String>[];
        final roles = rawRoles.isNotEmpty ? rawRoles.join(', ') : authState.user?.role.name ?? 'Student';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U'),
                    ),
                    const SizedBox(height: 12),
                    Text(displayName.isNotEmpty ? displayName : 'Learner', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Chip(label: Text(roles)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Password & security'),
              subtitle: const Text('Manage account access and password changes'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Wallet'),
              subtitle: const Text('Review balance and transactions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}
