import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/services/api_client.dart';

void main() {
  group('ApiClient payload parsing', () {
    test('extracts nested data from the standard API envelope', () {
      final payload = <String, dynamic>{
        'message': 'ok',
        'data': <String, dynamic>{
          'token': 'abc123',
          'roles': <String>['Student'],
        },
      };

      final extracted = ApiClient.extractResponseData(payload);

      expect(extracted['token'], 'abc123');
      expect(extracted['roles'], contains('Student'));
    });

    test('returns an empty map when the payload has no usable data', () {
      expect(ApiClient.extractResponseData(null), isEmpty);
      expect(ApiClient.extractResponseData(<String, dynamic>{'data': null}), isEmpty);
    });
  });
}
