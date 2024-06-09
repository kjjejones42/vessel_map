import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';

class ApiRequestManager {
  static const Map<String, String> headers = {
    'Content-Type': 'application/json'
  };

  static final int port = kReleaseMode ? Uri.base.port : 3000;

  static final Uri apiEndpoint = Uri(
      scheme: Uri.base.scheme, host: Uri.base.host, port: port, path: '/api');

  static final Uri websocketUri = Uri(
      // Use 'wss' if using 'https', 'ws' otherwise, to avoid mixed content.
      scheme: (Uri.base.scheme == 'https') ? 'wss' : 'ws',
      host: Uri.base.host,
      port: port,
      path: '/api');

  BuildContext? context;

  ApiRequestManager({required this.context});

  /// Displays the error to the user as a snackbar.
  void _showError(BuildContext context, Response response) {
    final errorColor = Theme.of(context).colorScheme.error;
    final errorMessage = AppLocalizations.of(context)!.httpErrorMessage(
        response.statusCode, Uri.base, response.reasonPhrase ?? response.body);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: errorColor, content: Text(errorMessage)));
  }

  /// Provides standard functionality for all request methods.
  Future<String?> _call(
      Future<http.Response> Function(Uri,
              {Object? body, Encoding? encoding, Map<String, String>? headers})
          func,
      Object? body) async {
    final jsonBody = jsonEncode(body);
    final response = await func(apiEndpoint, headers: headers, body: jsonBody);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final buildContext = context;
      if (buildContext != null && buildContext.mounted) {
        _showError(buildContext, response);
      }
      throw HttpException(
          '${response.statusCode}: "${response.reasonPhrase ?? response.body}',
          uri: apiEndpoint);
    }
    return response.body;
  }

  /// Execute a post request to the server.
  Future<String?> post(Map<String, dynamic> payload) async {
    return _call(http.post, payload);
  }

  /// Execute a delete request to the server.
  Future<String?> delete(int id) async {
    return _call(http.delete, {'id': id});
  }

  /// Execute a patch request to the server.
  Future<String?> patch(Map<String, dynamic> payload) async {
    return _call(http.patch, payload);
  }
}
