import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

Map<String, Object> buildLoginRequest(String email, String password) {
  return <String, Object>{
    'emailOrUserName': email,
    'password': password,
  };
}

Map<String, Object> buildRegisterRequest({
  required String firstName,
  required String lastName,
  required String email,
  required String userName,
  required String phoneNumber,
  required String password,
  required Object roleName,
}) {
  return <String, Object>{
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'userName': userName,
    'phoneNumber': phoneNumber,
    'password': password,
    'confirmPassword': password,
    'roleName': roleName,
  };
}

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
    return isAuthenticated &&
        selectedRole == null &&
        hasMultipleAssignableRoles;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({StorageService? storage, ApiClient? apiClient})
      : _storage = storage ?? const StorageService(),
        _apiClient = apiClient ?? ApiClient(),
        super(const AuthState()) {
    _restoreSession();
  }

  final StorageService _storage;
  final ApiClient _apiClient;

  Future<void> _restoreSession() async {
    final token = await _storage.readAuthToken();
    final roleName = await _storage.readRole();
    if (token == null || token.isEmpty) {
      return;
    }

    final role = roleName == AppUserRole.instructor.name
        ? AppUserRole.instructor
        : AppUserRole.student;

    state = state.copyWith(
      isAuthenticated: true,
      selectedRole: role,
      user: AppUser(
        id: 'saved-user',
        name: 'Saved user',
        email: 'saved-user',
        role: role,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.dio.post(
        '/accounts/login',
        data: buildLoginRequest(email, password),
      );

      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data ?? {});
      final data = payload['data'];
      final authData = data is Map<String, dynamic> ? data : null;

      if (authData == null || authData['token'] == null) {
        throw Exception('Authentication failed');
      }

      final roles = authData['roles'] is List
          ? authData['roles'].cast<String>()
          : <String>[];
      final role = roles.contains('Instructor') || roles.contains('Instructor')
          ? AppUserRole.instructor
          : AppUserRole.student;

      await _storage.saveAuthToken(authData['token'].toString());
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: AppUser(
          id: authData['email']?.toString() ?? email,
          name: '${authData['firstName'] ?? ''} ${authData['lastName'] ?? ''}'
                  .trim()
                  .isNotEmpty
              ? '${authData['firstName'] ?? ''} ${authData['lastName'] ?? ''}'
                  .trim()
              : email,
          email: authData['email']?.toString() ?? email,
          role: role,
        ),
        selectedRole: roles.length > 1 ? null : role,
        hasMultipleAssignableRoles: roles.length > 1,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Login error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await _apiClient.dio.post(
        '/accounts/register',
        data: buildRegisterRequest(
          firstName: firstName,
          lastName: lastName,
          email: email,
          userName: email.split('@').first,
          phoneNumber: '',
          password: password,
          roleName: 'Student',
        ),
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        selectedRole: null,
        hasMultipleAssignableRoles: false,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Register error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
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
