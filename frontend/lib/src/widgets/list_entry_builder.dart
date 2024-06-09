import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vessel_map/src/managers/api_request_manager.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:vessel_map/src/models/vessel.dart';
import 'package:vessel_map/src/widgets/vessel_details_form.dart';

class ListEntryBuilder {
  final List<Vessel> vessels;
  AppLocalizations? localizations;
  final String locale = PlatformDispatcher.instance.locale.toString();

  ListEntryBuilder({required this.vessels});

  void goToMapLocation(GoogleMapController controller, Vessel vessel) {
    controller.showMarkerInfoWindow(vessel.markerId);
    controller.animateCamera(CameraUpdate.newLatLng(vessel.location));
  }

  void onDeleteClick(BuildContext context, Vessel vessel) {
    showDialog(
        context: context,
        builder: (context) {
          return PointerInterceptor(
              child: AlertDialog.adaptive(
            title: Text(localizations!.warningTitle),
            content: Text(localizations!.deletePrompt(vessel.name)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations!.cancel)),
              TextButton(
                  onPressed: () async {
                    await ApiRequestManager(context: context).delete(vessel.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(localizations!.ok)),
            ],
          ));
        });
  }

  void onSubmitEditForm(
      Map<String, dynamic> payload, BuildContext? context) async {
    await ApiRequestManager(context: context).patch(payload);
    if (context != null && context.mounted) {
      Navigator.pop(context);
    }
  }

  void onEditClick(BuildContext context, Vessel vessel) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) => PointerInterceptor(
              child: AlertDialog.adaptive(
                title: Text(localizations!.editTitle),
                content: VesselDetailsForm(
                    formKey: formKey,
                    vessel: vessel,
                    onSubmit: onSubmitEditForm),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(localizations!.cancel)),
                  TextButton(
                      onPressed: () => formKey.currentState!.save(),
                      child: Text(localizations!.submit)),
                ],
              ),
            ));
  }

  Widget? entryBuilder(BuildContext context, int index) {
    return Consumer<AppModel>(builder: (context, model, child) {
      localizations = AppLocalizations.of(context);
      final vessel = vessels[index];
      final lastUpdated =
          DateFormat.yMd(locale).add_jms().format(vessel.updated);
      final leading = Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            tooltip: localizations!.delete,
            onPressed: () => onDeleteClick(context, vessel),
            icon: const Icon(Icons.delete)),
        IconButton(
            tooltip: localizations!.edit,
            onPressed: () => onEditClick(context, vessel),
            icon: const Icon(Icons.edit)),
      ]);
      return ListTile(
          key: Key(vessel.hashCode.toString()),
          title: Text(vessel.name),
          subtitle: Text(
              localizations!.listTileText(lastUpdated, vessel.locationText)),
          leading: leading,
          onTap: () {
            final mapController = model.mapController;
            if (mapController != null) {
              goToMapLocation(mapController, vessel);
            }
          });
    });
  }
}
