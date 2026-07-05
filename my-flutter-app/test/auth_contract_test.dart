import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/providers/auth_provider.dart';

void main() {
  group('Auth payload helpers', () {
    test('login payload uses the backend emailOrUserName contract', () {
      final payload = buildLoginRequest('student@learnloop.com', 'Password123!');

      expect(payload, {
        'emailOrUserName': 'student@learnloop.com',
        'password': 'Password123!',
      });
    });

    test('register payload uses the backend contract and roleName', () {
      final payload = buildRegisterRequest(
        firstName: 'Ava',
        lastName: 'Carter',
        email: 'ava@learnloop.com',
        userName: 'ava',
        phoneNumber: '',
        password: 'Password123!',
        roleName: 3,
      );

      expect(payload['firstName'], 'Ava');
      expect(payload['lastName'], 'Carter');
      expect(payload['email'], 'ava@learnloop.com');
      expect(payload['userName'], 'ava');
      expect(payload['phoneNumber'], '');
      expect(payload['password'], 'Password123!');
      expect(payload['confirmPassword'], 'Password123!');
      expect(payload['roleName'], 3);
    });
  });
}
