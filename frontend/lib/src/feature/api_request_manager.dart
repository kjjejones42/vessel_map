import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiRequestManager {
  static const String _port =
      String.fromEnvironment('PORT', defaultValue: '3000');
  static const String _host =
      String.fromEnvironment('HOST', defaultValue: 'localhost');

  static final Uri _endpoint = Uri.parse('http://$_host:$_port/api');
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json'
  };

  static const String wsUri = 'ws://$_host:$_port/api';

  Future<String?> _call(
      Future<http.Response> Function(Uri,
              {Object? body, Encoding? encoding, Map<String, String>? headers})
          func,
      Object? body) async {
    var response =
        await func(_endpoint, headers: _headers, body: jsonEncode(body));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      throw HttpException(
          '$_endpoint - ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<String?> create(Map<String, dynamic> payload) async {
    return _call(http.post, payload);
  }

  Future<String?> delete(int id) async {
    return _call(http.delete, {'id': id});
  }

  Future<String?> update(Map<String, dynamic> payload) async {
    return _call(http.patch, payload);
  }
}
