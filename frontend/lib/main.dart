import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

import 'src/app.dart';

void initialiseApp() async {
  runApp(
      ChangeNotifierProvider(create: (_) => AppModel(), child: const MyApp()));
}

void main() async {
  // Google Maps requires that the API key be hardcoded into the <script> tag URI on index.html,
  // the below code loads the key from the environment variables, sends it to the main page,
  // then continues to load the full app once the Maps script is loaded.

  if (kIsWeb && js.context['googleMapsLoaded'] != true) {
    var apiKey = const String.fromEnvironment('APIKEY');
    html.document
        .addEventListener('google-maps-loaded', (event) => initialiseApp());
    html.document.dispatchEvent(
        html.CustomEvent('google-maps-api-key-loaded', detail: apiKey));
  } else {
    initialiseApp();
  }
}
