import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vessel_map/src/feature/item.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'feature/item_main_view.dart';


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    return MyAppState();
  }

}

class MyAppState extends State<MyApp> {

  
  static const String _port = String.fromEnvironment("PORT");

  final channel = WebSocketChannel.connect(Uri.parse("ws://localhost:$_port/api"));

  List<Vessel> parseVessels(String? responseBody) {
    if (responseBody == null) return [];
    final parsed = (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    return parsed.map<Vessel>((json) => Vessel.fromJson(json)).toList(); 
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  default:
                    return StreamBuilder(
                      stream: channel.stream, 
                      builder: (context, snapshot) {
                        return ItemMainView(items: parseVessels(snapshot.data));
                });
                }
              },
            );
          },
        );
  }

  @override
  void dispose() {
    super.dispose();
    channel.sink.close();
  }

}