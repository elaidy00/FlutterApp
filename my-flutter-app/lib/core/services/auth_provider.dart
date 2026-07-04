import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;
  String? _activeRole;
  List<String> _assignableRoles = <String>[];
  bool _is2faRequired = false;
  String? _pending2faUserEmail;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get activeRole => _activeRole;
  List<String> get assignableRoles => _assignableRoles;
  bool get is2faRequired => _is2faRequired;
  String? get pending2faUserEmail => _pending2faUserEmail;

  AuthProvider() {
    loadSession();
  }

  /// Initial load of auth session from storage
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await _secureStorage.read(key: 'authToken');
      if (token != null) {
        // Attempt to load settings or fetch profile to verify session
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        _activeRole = prefs.getString('activeRole');
        
        // Fetch current user profile
        final Response<dynamic> response = await _apiClient.dio.get('/accounts/current-user');
        if (response.statusCode == 200 && response.data != null) {
          _user = response.data['data'];
          _token = token;
          _resolveAssignableRoles();
        } else {
          await clearSession();
        }
      }
    } catch (e) {
      // If server is unreachable but token exists, we can keep the session (offline)
      // or clear it if it's explicitly unauthorized (handled by interceptor)
      debugPrint('Session restore warning: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves assignable roles based on user claims/roles
  void _resolveAssignableRoles() {
    if (_user == null) return;
    
    final rolesObj = _user!['roles'];
    if (rolesObj is List) {
      _assignableRoles = rolesObj.map((r) => r.toString()).toList();
    } else if (rolesObj is String) {
      _assignableRoles = <String>[rolesObj];
    } else {
      _assignableRoles = <String>[];
    }

    // Default to the first role if not set or invalid
    if (_assignableRoles.isNotEmpty) {
      if (_activeRole == null || !_assignableRoles.contains(_activeRole)) {
        setActiveRole(_assignableRoles.first);
      }
    } else {
      _activeRole = null;
    }
  }

  /// Handles user login
  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    _is2faRequired = false;
    _pending2faUserEmail = null;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/login',
        data: <String, String>{
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        
        // Handle 2FA Requirement
        if (response.data['is2FARequired'] == true || data?['token'] == null) {
          _is2faRequired = true;
          _pending2faUserEmail = email;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _token = data['token'];
        _user = data;
        await _secureStorage.write(key: 'authToken', value: _token);

        _resolveAssignableRoles();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Handles 2FA verification
  Future<bool> verify2FA(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/verify-2fa',
        data: <String, String?>{
          'email': _pending2faUserEmail,
          'code': code,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        _token = data['token'];
        _user = data;
        await _secureStorage.write(key: 'authToken', value: _token);

        _resolveAssignableRoles();
        _is2faRequired = false;
        _pending2faUserEmail = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Handles User Registration
  Future<bool> register(String fullName, String email, String password, int roleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/register',
        data: <String, Object>{
          'fullName': fullName,
          'email': email,
          'password': password,
          'roleId': roleId,
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sets active role (Student or Instructor)
  Future<void> setActiveRole(String role) async {
    _activeRole = role;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeRole', role);
    notifyListeners();
  }

  /// Clears local session variables and files
  Future<void> clearSession() async {
    _user = null;
    _token = null;
    _activeRole = null;
    _assignableRoles = <String>[];
    _is2faRequired = false;
    _pending2faUserEmail = null;
    await _secureStorage.delete(key: 'authToken');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeRole');
  }

  /// Triggers user logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.dio.post('/accounts/logout');
    } catch (e) {
      debugPrint('Logout request warning: $e');
    } finally {
      await clearSession();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Email Verification handler
  Future<bool> verifyEmail(String code, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/accounts/verify-email',
        data: <String, String>{
          'userId': userId,
          'token': code,
        },
      );
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
