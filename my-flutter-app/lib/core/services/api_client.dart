import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  String baseUrl = _resolveBaseUrl();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue = <Map<String, dynamic>>[];

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5086/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5086/api';
    }
    if (Platform.isIOS) {
      return 'http://localhost:5086/api';
    }
    return 'http://localhost:5086/api';
  }

  ApiClient._internal() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          // Retrieve token from secure storage
          final String? token = await _secureStorage.read(key: 'authToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final RequestOptions requestOptions = error.requestOptions;

          // Prevent infinite loops on refresh-token endpoint failures
          if (requestOptions.path.contains('/accounts/refresh-token')) {
            return handler.next(error);
          }

          // Trigger token refresh on 401 Unauthorized
          if (error.response?.statusCode == 401) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              
              try {
                final Map<String, dynamic>? refreshResponse = await refreshAccessToken();
                if (refreshResponse != null) {
                  final newToken = refreshResponse['token'];
                  await _secureStorage.write(key: 'authToken', value: newToken);

                  // Update header for current request and retry
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  
                  // Retry all failed requests in the queue
                  for (final Map<String, dynamic> queuedRequest in _failedRequestsQueue) {
                    final Response<dynamic> response = await dio.request(
                      queuedRequest['path'],
                      options: queuedRequest['options'],
                      data: queuedRequest['data'],
                      queryParameters: queuedRequest['queryParameters'],
                    );
                    queuedRequest['handler'].resolve(response);
                  }
                  _failedRequestsQueue.clear();

                  // Retry the original request that failed
                  final Response<dynamic> retryResponse = await dio.request(
                    requestOptions.path,
                    options: Options(
                      method: requestOptions.method,
                      headers: requestOptions.headers,
                    ),
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                  );
                  
                  _isRefreshing = false;
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                _failedRequestsQueue.clear();
                _isRefreshing = false;
                // Clear authentication state and notify auth provider (logout)
                await logoutAndClearTokens();
                return handler.next(error);
              }
            } else {
              // If already refreshing, queue the request details to retry later
              final CompleterResponseHandler responseCompleter = CompleterResponseHandler(
                handler: handler,
                requestOptions: requestOptions,
              );
              _failedRequestsQueue.add(<String, dynamic>{
                'path': requestOptions.path,
                'options': Options(
                  method: requestOptions.method,
                  headers: requestOptions.headers,
                ),
                'data': requestOptions.data,
                'queryParameters': requestOptions.queryParameters,
                'handler': responseCompleter,
              });
              return;
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Refreshes access token by calling the refresh-token endpoint
  Future<Map<String, dynamic>?> refreshAccessToken() async {
    try {
      // Create separate Dio instance to avoid interceptor recursion
      final Dio refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      
      // The API uses HttpOnly cookies for refresh tokens. 
      // In Flutter, cookies are stored in a cookie jar or managed natively.
      // We pass the withCredentials equivalent or custom headers if required.
      final Response<dynamic> response = await refreshDio.get(
        '/accounts/refresh-token',
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        return data as Map<String, dynamic>;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Clear token storage on authorization loss
  Future<void> logoutAndClearTokens() async {
    await _secureStorage.delete(key: 'authToken');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeRole');
    // Dispatch a notification or global event here if needed
  }

  /// Dynamic Base URL setup for Emulators vs Web
  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
    dio.options.baseUrl = newUrl;
  }

  /// Standardizes API errors into user-friendly messages
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['errors'] != null) {
        final errors = error.response?.data['errors'];
        if (errors is Map) {
          final String messages = errors.values.expand((e) => e is List ? e : <dynamic>[e]).join(' ');
          if (messages.isNotEmpty) return messages;
        }
      }
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.receiveTimeout:
          return 'Server took too long to respond. Please try again.';
        case DioExceptionType.badResponse:
          return 'Server error (Status: ${error.response?.statusCode}).';
        default:
          return 'Connection failed. Please check your network connection.';
      }
    }
    return error?.toString() ?? 'An unexpected error occurred.';
  }
}

/// Custom completion handler to resume requests that were paused during token refresh
class CompleterResponseHandler {
  final ErrorInterceptorHandler handler;
  final RequestOptions requestOptions;

  CompleterResponseHandler({required this.handler, required this.requestOptions});

  void resolve(Response response) {
    handler.resolve(response);
  }

  void reject(DioException error) {
    handler.next(error);
  }
}
