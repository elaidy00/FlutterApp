import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/dtos/auth_dtos.dart';
import '../services/api_client.dart';

Map<String, dynamic> buildLoginRequest(String email, String password) => {
      'emailOrUserName': email,
      'password': password,
    };

Map<String, dynamic> buildRegisterRequest({
  required String firstName,
  required String lastName,
  required String email,
  required String userName,
  required String phoneNumber,
  required String password,
  required dynamic roleName,
  String? confirmPassword,
  int? gender,
}) {
  return {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'userName': userName,
    'phoneNumber': phoneNumber,
    'password': password,
    'confirmPassword': confirmPassword ?? password,
    'roleName': roleName,
    if (gender != null) 'gender': gender,
  };
}

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.activeRole,
    this.assignableRoles = const [],
    this.is2faRequired = false,
    this.pending2faUserEmail,
    this.isEmailVerificationRequired = false,
    this.pendingVerificationEmail,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final AuthResponseDto? user;
  final String? activeRole;
  final List<String> assignableRoles;
  final bool is2faRequired;
  final String? pending2faUserEmail;
  final bool isEmailVerificationRequired;
  final String? pendingVerificationEmail;
  final String? errorMessage;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthResponseDto? user,
    String? activeRole,
    List<String>? assignableRoles,
    bool? is2faRequired,
    String? pending2faUserEmail,
    bool? isEmailVerificationRequired,
    String? pendingVerificationEmail,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      activeRole: activeRole ?? this.activeRole,
      assignableRoles: assignableRoles ?? this.assignableRoles,
      is2faRequired: is2faRequired ?? this.is2faRequired,
      pending2faUserEmail: pending2faUserEmail ?? this.pending2faUserEmail,
      isEmailVerificationRequired:
          isEmailVerificationRequired ?? this.isEmailVerificationRequired,
      pendingVerificationEmail:
          pendingVerificationEmail ?? this.pendingVerificationEmail,
      errorMessage: errorMessage,
    );
  }

  bool needsRoleSelection() {
    return isAuthenticated && activeRole == null && assignableRoles.length > 1;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    loadSession();
  }

  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> loadSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final String? token = await _secureStorage.read(key: 'authToken');
      if (token != null && token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? savedRole = prefs.getString('activeRole');

        // Fetch current user profile to verify session
        final Response<dynamic> response =
            await _apiClient.dio.get('/accounts/current-user');

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          final userDto = AuthResponseDto.fromJson(data);

          final roles = userDto.roles;
          String? activeRole = savedRole;
          if (roles.isNotEmpty) {
            if (activeRole == null || !roles.contains(activeRole)) {
              activeRole = roles.first;
              await prefs.setString('activeRole', activeRole);
            }
          }

          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: userDto,
            activeRole: activeRole,
            assignableRoles: roles,
          );
        } else {
          await clearSession();
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('Session restore warning: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/login',
        data: buildLoginRequest(email, password),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];

        // Check if 2FA is required
        if (response.data['is2FARequired'] == true || data == null || data['token'] == null) {
          state = state.copyWith(
            isLoading: false,
            is2faRequired: true,
            pending2faUserEmail: email,
          );
          return false;
        }

        final userDto = AuthResponseDto.fromJson(data);
        await _secureStorage.write(key: 'authToken', value: userDto.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', rememberMe);

        final roles = userDto.roles;
        String? activeRole;
        if (roles.isNotEmpty) {
          activeRole = roles.first;
          await prefs.setString('activeRole', activeRole);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userDto,
          activeRole: activeRole,
          assignableRoles: roles,
        );
        return true;
      }
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> register(RegisterDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/register',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          isEmailVerificationRequired: true,
          pendingVerificationEmail: dto.email,
        );
        return true;
      }
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> verifyEmail(String email, String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/email-verification',
        data: EmailVerificationDto(email: email, token: token).toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'];
        final userDto = AuthResponseDto.fromJson(data);
        await _secureStorage.write(key: 'authToken', value: userDto.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final roles = userDto.roles;
        String? activeRole;
        if (roles.isNotEmpty) {
          activeRole = roles.first;
          await prefs.setString('activeRole', activeRole);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userDto,
          activeRole: activeRole,
          assignableRoles: roles,
          isEmailVerificationRequired: false,
          pendingVerificationEmail: null,
        );
        return true;
      }
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> resendVerificationEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/resend-verification',
        data: ResendVerificationDto(email: email).toJson(),
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 200;
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
  }

  Future<bool> verify2FA(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/verify-2fa',
        data: Verify2FADto(email: state.pending2faUserEmail, code: code).toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final userDto = AuthResponseDto.fromJson(data);
        await _secureStorage.write(key: 'authToken', value: userDto.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final roles = userDto.roles;
        String? activeRole;
        if (roles.isNotEmpty) {
          activeRole = roles.first;
          await prefs.setString('activeRole', activeRole);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userDto,
          activeRole: activeRole,
          assignableRoles: roles,
          is2faRequired: false,
          pending2faUserEmail: null,
        );
        return true;
      }
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> resend2FA() async {
    if (state.pending2faUserEmail == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/resend-2fa',
        data: ResendVerificationDto(email: state.pending2faUserEmail!).toJson(),
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 200;
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
  }

  Future<bool> googleLogin(String idToken) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/google-login',
        data: GoogleLoginDto(idToken: idToken).toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];

        if (response.data['is2FARequired'] == true || data == null || data['token'] == null) {
          state = state.copyWith(
            isLoading: false,
            is2faRequired: true,
            pending2faUserEmail: data?['email'],
          );
          return false;
        }

        final userDto = AuthResponseDto.fromJson(data);
        await _secureStorage.write(key: 'authToken', value: userDto.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final roles = userDto.roles;
        String? activeRole;
        if (roles.isNotEmpty) {
          activeRole = roles.first;
          await prefs.setString('activeRole', activeRole);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userDto,
          activeRole: activeRole,
          assignableRoles: roles,
        );
        return true;
      }
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> forgetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/forgetpassword',
        data: ForgetPasswordDto(email: email).toJson(),
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
  }

  Future<bool> resetPassword(ResetPasswordDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/resetpassword',
        data: dto.toJson(),
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      final message = _apiClient.getErrorMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      rethrow;
    }
  }

  Future<void> setActiveRole(String role) async {
    if (!state.assignableRoles.contains(role)) return;
    state = state.copyWith(activeRole: role);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeRole', role);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'authToken');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeRole');
    state = const AuthState();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.dio.post('/accounts/revoke-token');
    } catch (e) {
      debugPrint('Logout request warning: $e');
    } finally {
      await clearSession();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
