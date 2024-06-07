import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/map_model.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'src/app.dart';

void init() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ChangeNotifierProvider(create: (_) => MapModel(), child: const MyApp()));
}

void main() async {
  
  if (kIsWeb) {
    html.document.addEventListener('google-maps-loaded', (event) => init());
    var apiKey = const String.fromEnvironment('APIKEY');
    html.document.dispatchEvent(html.CustomEvent("google-maps-api-key-loaded", detail: apiKey));
  } else {
    init();
  }
}
