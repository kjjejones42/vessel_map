import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/app_model.dart';
import 'package:vessel_map/src/feature/item_side_view.dart';
import 'package:vessel_map/src/feature/map_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemMainView extends StatelessWidget {
  const ItemMainView({super.key});

  Widget _portraitView(AppBar appBar, BuildContext context) {
    var minWidth = MediaQuery.of(context).size.width * .75;
    return Scaffold(
        appBar: appBar,
        body: const MapView(),
        drawer: PointerInterceptor(
            child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child:
                    const Drawer(child: ItemSideView(showMenuButton: true)))));
  }

  Widget _landscapeView(AppBar appBar) {
    return Scaffold(
        appBar: appBar,
        body: Row(children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const ItemSideView()),
          const Expanded(child: MapView())
        ]));
  }

  Widget _loadingView(BuildContext context, AppBar appBar) {
    final color = Theme.of(context).colorScheme.primary;
    final text = AppLocalizations.of(context)!.disconnectedMessage;
    return Scaffold(
        appBar: appBar,
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          LoadingAnimationWidget.beat(color: color, size: 32),
          Padding(padding: const EdgeInsets.all(16), child: Text(text)),
        ])));
  }

  AppBar _appBar(BuildContext context, bool isConnected) {
    final localizations = AppLocalizations.of(context);
    return AppBar(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(localizations!.appTitle),
      Tooltip(
          message: isConnected
              ? localizations.connected
              : localizations.disconnected,
          child: Icon(
            Icons.circle,
            color: isConnected ? Colors.green : Colors.red,
          )),
    ]));
  }

  bool _shouldShowDrawer(BuildContext context) {
    final query = MediaQuery.of(context);
    final orientation = query.orientation == Orientation.portrait;
    return orientation || query.size.width < 1440;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      final appBar = _appBar(context, model.isConnected);
      if (!model.isConnected) {
        return _loadingView(context, appBar);
      }
      return _shouldShowDrawer(context)
          ? _portraitView(appBar, context)
          : _landscapeView(appBar);
    });
  }
}
