import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kApiBaseUrl = 'https://learnloopapi.runasp.net/api';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  void _debugPrintBody(String label, Object? value) {
    if (value == null) {
      debugPrint('$label: null');
      return;
    }

    if (value is String) {
      debugPrint('$label: $value');
      return;
    }

    try {
      debugPrint('$label: ${jsonEncode(value)}');
    } catch (_) {
      debugPrint('$label: $value');
    }
  }

  String _extractAspNetErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = responseData['errors'];
      if (errors is Map) {
        return errors.values
            .expand((value) => value is List ? value : <dynamic>[value])
            .whereType<String>()
            .join(' | ');
      }
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    return 'No ASP.NET Core error message provided.';
  }

  final Dio dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String baseUrl = _resolveBaseUrl();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue =
      <Map<String, dynamic>>[];

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return kApiBaseUrl;
    }
    if (Platform.isAndroid) {
      return kApiBaseUrl;
    }
    if (Platform.isIOS) {
      return kApiBaseUrl;
    }
    return kApiBaseUrl;
  }

  ApiClient._internal() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);
    dio.options.headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
          final String? token = await _secureStorage.read(key: 'authToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint(
              '➡️ ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
          if (options.data != null) {
            debugPrint('➡️ Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          debugPrint(
              '⬅️ ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}');
          debugPrint('⬅️ Body: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final RequestOptions requestOptions = error.requestOptions;
          final String requestUrl =
              '${requestOptions.baseUrl}${requestOptions.path}';

          debugPrint('❌ Request URL: $requestUrl');
          _debugPrintBody('❌ Request Body', requestOptions.data);
          debugPrint(
              '❌ Response Status: ${error.response?.statusCode ?? 'N/A'}');
          _debugPrintBody('❌ Raw response body', error.response?.data);

          final dynamic responseData = error.response?.data;
          if (responseData is Map) {
            final dynamic errors = responseData['errors'];
            if (errors is Map) {
              debugPrint('❌ ModelState validation errors: ${jsonEncode(errors)}');
            } else if (errors != null) {
              debugPrint('❌ ModelState validation errors: $errors');
            }
          }

          debugPrint(
              '❌ ASP.NET Core error message: ${_extractAspNetErrorMessage(responseData)}');
          debugPrint('❌ Dio error: ${error.message}');

          if (requestOptions.path.contains('/accounts/refresh-token')) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            if (!_isRefreshing) {
              _isRefreshing = true;

              try {
                final Map<String, dynamic>? refreshResponse =
                    await refreshAccessToken();
                if (refreshResponse != null) {
                  final newToken = refreshResponse['token'];
                  await _secureStorage.write(key: 'authToken', value: newToken);

                  requestOptions.headers['Authorization'] = 'Bearer $newToken';

                  for (final Map<String, dynamic> queuedRequest
                      in _failedRequestsQueue) {
                    final Response<dynamic> response = await dio.request(
                      queuedRequest['path'],
                      options: queuedRequest['options'],
                      data: queuedRequest['data'],
                      queryParameters: queuedRequest['queryParameters'],
                    );
                    queuedRequest['handler'].resolve(response);
                  }
                  _failedRequestsQueue.clear();

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
                await logoutAndClearTokens();
                return handler.next(error);
              }
            } else {
              final CompleterResponseHandler responseCompleter =
                  CompleterResponseHandler(
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

  Future<Map<String, dynamic>?> refreshAccessToken() async {
    try {
      final Dio refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
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
        return data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> logoutAndClearTokens() async {
    await _secureStorage.delete(key: 'authToken');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeRole');
  }

  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
    dio.options.baseUrl = newUrl;
  }

  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['errors'] != null) {
        final errors = error.response?.data['errors'];
        if (errors is Map) {
          final String messages = errors.values
              .expand((e) => e is List ? e : <dynamic>[e])
              .join(' ');
          if (messages.isNotEmpty) return messages;
        }
      }
      if (error.response?.data != null &&
          error.response?.data['message'] != null) {
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

class CompleterResponseHandler {
  final ErrorInterceptorHandler handler;
  final RequestOptions requestOptions;

  CompleterResponseHandler(
      {required this.handler, required this.requestOptions});

  void resolve(Response response) {
    handler.resolve(response);
  }

  void reject(DioException error) {
    handler.next(error);
  }
}
