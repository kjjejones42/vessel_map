import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/api_request_manager.dart';
import 'package:vessel_map/src/feature/app_model.dart';
import 'package:vessel_map/src/feature/vessel.dart';
import 'package:websocket_universal/websocket_universal.dart';

import 'feature/item_main_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  /// WebSocket channel to receive real-time data.
  var channel = IWebSocketHandler.createClient(
      ApiRequestManager.wsUri, SocketSimpleTextProcessor());

  SocketStatus? _socketStatus;
  Timer? _updateStatusTimer;

  ThemeData createTheme(Color color, Brightness brightness) {
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: color, brightness: brightness);
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary) 
    );
  }

  List<Vessel> parseVessels(String? responseBody) {
    if (responseBody == null) return [];
    final parsed =
        (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    return parsed.map<Vessel>((json) => Vessel.fromJson(json)).toList();
  }

  // Only change the socket status from 'connected' after a 1 second Timer, to
  // prevent UI flickering from intermittent connection or routine pings.
  void _onSocketStateChange(ISocketState state) {
    switch (state.status) {
      case SocketStatus.connecting:
        _updateStatusTimer ??= Timer(const Duration(seconds: 1), () {
          if (state.status != SocketStatus.connected) {
            setState(() => _socketStatus = state.status);
          }
          _updateStatusTimer = null;
        });
      case SocketStatus.connected:
        _updateStatusTimer?.cancel();
        _updateStatusTimer = null;
        setState(() => _socketStatus = SocketStatus.connected);
      case SocketStatus.disconnected:
        setState(() => _socketStatus = SocketStatus.disconnected);
    }
  }

  @override
  void initState() {
    super.initState();
    channel.socketHandlerStateStream.listen(_onSocketStateChange);
    channel.connect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'GB')
        ],
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        restorationScopeId: 'app',
        theme: createTheme(Colors.blue, Brightness.light),
        darkTheme: createTheme(Colors.blue, Brightness.dark),
        home: StreamBuilder(
            stream: channel.incomingMessagesStream,
            builder: (context, messageSnapshot) {
              return Consumer<AppModel>(builder: (BuildContext context, AppModel model, Widget? child) {
                bool isConnected = _socketStatus == SocketStatus.connected;
                model.isConnected = isConnected;
                model.items = parseVessels(messageSnapshot.data);
                return const ItemMainView();
                });
            }));
  }

  @override
  void dispose() {
    super.dispose();
    channel.close();
  }
}
