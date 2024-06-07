import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiManager {
  static const String _port = String.fromEnvironment("PORT");
  static final Uri _endpoint = Uri.parse("http://localhost:$_port/api");
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json'
  };

  Future<String?> _call(
      Future<Response> Function(Uri,
              {Object? body, Encoding? encoding, Map<String, String>? headers})
          func,
      String body) async {      
    var response = await func(_endpoint, headers: _headers, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      throw HttpException("$_endpoint ${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  Future<String?> create(Map<String, dynamic> payload) async {
    return _call(http.post, jsonEncode(payload));
  }

  Future<String?> delete(int id) async {
    return _call(http.delete, jsonEncode({'id': id}));
  }

  Future<String?> update(Map<String, dynamic> payload) async {
    return _call(http.patch, jsonEncode(payload));
  }
}
