import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

/// Manage student/instructor e-wallet balances and transactions.
class WalletProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  double _balance = 0.0;
  List<dynamic> _transactions = <dynamic>[];
  bool _isLoading = false;

  /// Gets the current wallet balance.
  double get balance => _balance;
  /// Gets list of wallet transactions.
  List<dynamic> get transactions => _transactions;
  /// Returns true if an operations is loading.
  bool get isLoading => _isLoading;

  /// Refreshes the student coin balance.
  Future<void> fetchStudentBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>('/wallet/balance');
      if (response.statusCode == 200 && response.data != null) {
        _balance = (response.data['coins'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      debugPrint('Failed to fetch student balance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the instructor coin balance.
  Future<void> fetchInstructorBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>('/wallet/instructor/balance');
      if (response.statusCode == 200 && response.data != null) {
        _balance = (response.data['coins'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      debugPrint('Failed to fetch instructor balance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches transaction log history.
  Future<void> fetchTransactions({String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String path = type != null ? '/wallet/transactions?type=$type' : '/wallet/transactions';
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(path);
      if (response.statusCode == 200 && response.data != null) {
        _transactions = response.data as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to fetch transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches instructor paginated transaction log history.
  Future<void> fetchInstructorTransactions({int page = 1, int size = 10, String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String path = '/wallet/instructor/transactions?pageNumber=$page&pageSize=$size';
      if (type != null) {
        path += '&type=$type';
      }
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(path);
      if (response.statusCode == 200 && response.data != null) {
        _transactions = response.data['data'] as List<dynamic>? ?? <dynamic>[];
      }
    } catch (e) {
      debugPrint('Failed to fetch instructor transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates top-up payment checkout session.
  Future<String?> initiateStripeTopUp(double amount, int coins) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '/wallet/top-up',
        data: <String, dynamic>{
          'amount': amount,
          'coins': coins,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['sessionId'] as String?;
      }
    } catch (e) {
      debugPrint('Stripe top-up initiation failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Uploads manual payment screenshot (Vodafone Cash/Manual).
  Future<bool> uploadManualPayment(int coins, double amount, String senderPhone, File screenshot) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String fileName = screenshot.path.split('/').last;
      final FormData formData = FormData.fromMap(<String, dynamic>{
        'coins': coins,
        'amount': amount,
        'senderPhoneNumber': senderPhone,
        'screenshot': await MultipartFile.fromFile(screenshot.path, filename: fileName),
      });

      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '/wallet/manual-payment',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Manual payment submission failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits withdrawal refund request (Instructors).
  Future<bool> requestRefund(int coins, String paymentMethod, String targetAccount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '/wallet/refund-request',
        data: <String, dynamic>{
          'coins': coins,
          'paymentMethod': paymentMethod,
          'targetAccount': targetAccount,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Refund withdrawal request failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
