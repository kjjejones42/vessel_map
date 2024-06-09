import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/managers/api_request_manager.dart';
import 'package:vessel_map/src/managers/theme_manager.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:vessel_map/src/models/vessel.dart';
import 'package:vessel_map/src/widgets/main_view.dart';
import 'package:websocket_universal/websocket_universal.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  /// WebSocket channel to receive real-time data.
  var channel = IWebSocketHandler.createClient(
      ApiRequestManager.websocketUri.toString(), SocketSimpleTextProcessor());

  SocketStatus? socketStatus;
  Timer? updateSocketStatusTimer;

  /// Parse JSON message from websocket to list of Vessel objects
  List<Vessel> parseVessels(String? responseBody) {
    if (responseBody == null) return [];
    final parsed =
        (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    return parsed.map<Vessel>((json) => Vessel.fromJson(json)).toList();
  }

  // Only change the socket status from 'connected' after a 1 second Timer, to
  // prevent UI flickering from intermittent connection or routine pings.
  void updateSocketStatus(ISocketState state) {
    switch (state.status) {
      case SocketStatus.connecting:
        updateSocketStatusTimer ??= Timer(const Duration(seconds: 1), () {
          if (state.status != SocketStatus.connected) {
            setState(() => socketStatus = state.status);
          }
          updateSocketStatusTimer = null;
        });
      case SocketStatus.connected:
        updateSocketStatusTimer?.cancel();
        updateSocketStatusTimer = null;
        setState(() => socketStatus = SocketStatus.connected);
      case SocketStatus.disconnected:
        setState(() => socketStatus = SocketStatus.disconnected);
    }
  }

  @override
  void initState() {
    super.initState();
    channel.socketHandlerStateStream.listen(updateSocketStatus);
    channel.connect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Make localisation delegates available
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      // Generate title from localisation resources
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      restorationScopeId: 'app',
      // Declare app themes
      theme: ThemeManager.createTheme(Brightness.light),
      darkTheme: ThemeManager.createTheme(Brightness.dark),
      // Wrap app in Streambuilder to listen to changes from websocket
      home: StreamBuilder(
          stream: channel.incomingMessagesStream,
          builder: (context, messageSnapshot) {
            return Consumer<AppModel>(
                builder: (BuildContext context, AppModel model, Widget? child) {
              // Update model on change
              model.isConnected = socketStatus == SocketStatus.connected;
              model.vessels = parseVessels(messageSnapshot.data);
              return const MainView();
            });
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    channel.close();
  }
}
