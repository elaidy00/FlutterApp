import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.selectedRole,
    this.hasMultipleAssignableRoles = false,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final AppUser? user;
  final AppUserRole? selectedRole;
  final bool hasMultipleAssignableRoles;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AppUser? user,
    AppUserRole? selectedRole,
    bool? hasMultipleAssignableRoles,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
      hasMultipleAssignableRoles:
          hasMultipleAssignableRoles ?? this.hasMultipleAssignableRoles,
    );
  }

  bool needsRoleSelection() {
    return isAuthenticated && selectedRole == null && hasMultipleAssignableRoles;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({StorageService? storage, ApiClient? apiClient})
      : _storage = storage ?? const StorageService(),
        _apiClient = apiClient ?? ApiClient(),
        super(const AuthState());

  final StorageService _storage;
  final ApiClient _apiClient;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.dio.post('/accounts/login', data: {
        'emailOrUserName': email,
        'password': password,
      });

      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data ?? {});
      final data = payload['data'];
      final authData = data is Map<String, dynamic> ? data : null;

      if (authData == null || authData['token'] == null) {
        throw Exception('Authentication failed');
      }

      final roles = authData['roles'] is List ? authData['roles'].cast<String>() : <String>[];
      final role = roles.contains('Instructor') ? AppUserRole.instructor : AppUserRole.student;

      await _storage.saveAuthToken(authData['token'].toString());
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: AppUser(
          id: authData['email']?.toString() ?? email,
          name: '${authData['firstName'] ?? ''} ${authData['lastName'] ?? ''}'.trim().isNotEmpty
              ? '${authData['firstName'] ?? ''} ${authData['lastName'] ?? ''}'.trim()
              : email,
          email: authData['email']?.toString() ?? email,
          role: role,
        ),
        selectedRole: null,
        hasMultipleAssignableRoles: roles.length > 1,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.dio.post('/accounts/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'userName': email.split('@').first,
      });

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: AppUser(
          id: email,
          name: fullName,
          email: email,
          role: AppUserRole.student,
        ),
        selectedRole: null,
        hasMultipleAssignableRoles: true,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> selectRole(AppUserRole role) async {
    state = state.copyWith(selectedRole: role);
    await _storage.saveRole(role.name);
  }

  Future<void> signOut() async {
    await _storage.clearAuthToken();
    await _storage.clearRole();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
