import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:vessel_map/src/managers/api_request_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient client;
  late ApiRequestManager manager;

  setUpAll(() {
    registerFallbackValue(ApiRequestManager.apiEndpoint);
  });

  setUp(() {
    client = MockClient();
    manager = ApiRequestManager(context: null, client: client);
  });

  group('api manager tests', () {
    test('test delete', () async {
      when(() => client.delete(any(),
              body: any(named: 'body'),
              headers: any(named: 'headers'),
              encoding: any(named: 'encoding')))
          .thenAnswer((_) async => http.Response('', 200));
      final response = await manager.delete(1);
      expect(response, isNotNull);
      expect(response, isA<String>());
    });

    test('test post', () async {
      when(() => client.post(any(),
              body: any(named: 'body'),
              headers: any(named: 'headers'),
              encoding: any(named: 'encoding')))
          .thenAnswer((_) async => http.Response('', 200));
      final payload = {
        'id': 1,
        'name': 'Enterprise',
        'latitude': 1,
        'longitude': 2
      };
      final response = await manager.post(payload);
      expect(response, isNotNull);
      expect(response, isA<String>());
    });

    test('test patch', () async {
      when(() => client.patch(any(),
              body: any(named: 'body'),
              headers: any(named: 'headers'),
              encoding: any(named: 'encoding')))
          .thenAnswer((_) async => http.Response('', 200));
      final payload = {
        'id': 1,
        'name': 'Enterprise',
        'latitude': 1,
        'longitude': 2
      };
      final response = await manager.patch(payload);
      expect(response, isNotNull);
      expect(response, isA<String>());
    });
  });
}
