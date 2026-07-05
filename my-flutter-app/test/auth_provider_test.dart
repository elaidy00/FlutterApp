import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/providers/auth_provider.dart';

void main() {
  group('buildRegisterRequest', () {
    test('uses the backend enum payload shape for registration', () {
      final request = buildRegisterRequest(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        userName: 'ada',
        phoneNumber: '123456789',
        password: 'Password123!',
        roleName: 'Student',
      );

      expect(request['roleName'], 'Student');
      expect(request['confirmPassword'], 'Password123!');
    });
  });
}
