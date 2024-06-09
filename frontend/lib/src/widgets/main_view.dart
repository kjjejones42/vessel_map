import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:vessel_map/src/widgets/side_view.dart';
import 'package:vessel_map/src/widgets/google_maps_container.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  /// The layout to use on portrait / narrow screens.
  /// Hides the sidebar in a menu drawer.
  Widget portraitView(AppBar appBar, BuildContext context) {
    var minWidth = MediaQuery.of(context).size.width * .75;
    return Scaffold(
        appBar: appBar,
        body: const GoogleMapsContainer(),
        drawer: PointerInterceptor(
            child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: const Drawer(child: SideView(isInDrawer: true)))));
  }

  /// The layout to use on landscape / wide screens.
  /// Shows the sidebar on the left side of the page.
  Widget landscapeView(AppBar appBar) {
    return Scaffold(
        appBar: appBar,
        body: Row(children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const SideView()),
          const Expanded(child: GoogleMapsContainer())
        ]));
  }

  /// The layout to use if not connected to the server.
  /// Hides the map and sidebar, and only shows the appbar and a loader.
  Widget loadingView(BuildContext context, AppBar appBar) {
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

  /// The appbar that shows at the top of the app.
  AppBar appBar(BuildContext context, bool isConnected) {
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

  /// Determines whether to use the portrait view and hide the sidebar in a
  /// menu drawer.
  bool shouldUsePortraitView(BuildContext context) {
    final query = MediaQuery.of(context);
    final orientation = query.orientation == Orientation.portrait;
    return orientation || query.size.width < 1400;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      final bar = appBar(context, model.isConnected);
      if (!model.isConnected) {
        return loadingView(context, bar);
      }
      if (shouldUsePortraitView(context)) {
        return portraitView(bar, context);
      }
      return landscapeView(bar);
    });
  }
}
