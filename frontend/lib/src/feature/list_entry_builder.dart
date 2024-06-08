import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/api_request_manager.dart';
import 'package:vessel_map/src/feature/app_model.dart';
import 'package:vessel_map/src/feature/vessel.dart';
import 'package:vessel_map/src/feature/item_details_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListEntryBuilder {
  final List<Vessel> items;
  AppLocalizations? localizations;
  final String locale = PlatformDispatcher.instance.locale.toString();

  ListEntryBuilder({required this.items});

  void goToMapLocation(GoogleMapController controller, Vessel item) {
    controller.showMarkerInfoWindow(item.markerId);
    controller.animateCamera(CameraUpdate.newLatLng(item.location));
  }

  void onDeleteClick(BuildContext context, Vessel item) {
    showDialog(
        context: context,
        builder: (context) {
          return PointerInterceptor(
              child: AlertDialog.adaptive(
            title: Text(localizations!.warningTitle),
            content: Text(localizations!.deletePrompt(item.name)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations!.cancel)),
              TextButton(
                  onPressed: () async {
                    await ApiRequestManager().delete(item.id);
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
    await ApiRequestManager().update(payload);
    if (context != null && context.mounted) {
      Navigator.pop(context);
    }
  }

  void onEditClick(BuildContext context, Vessel item) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) => PointerInterceptor(
              child: AlertDialog.adaptive(
                title: Text(localizations!.editTitle),
                content: ItemDetailsForm(
                    formKey: formKey, item: item, onSubmit: onSubmitEditForm),
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

  String circleAvatarText(String name) {
    return switch (name.length) {
      0 => '',
      1 => name[0].toUpperCase(),
      _ => name[0].toUpperCase() + name[1].toLowerCase()
    };
  }

  Widget? itemBuilder(BuildContext context, int index) {
    return Consumer<AppModel>(builder: (context, model, child) {
      localizations = AppLocalizations.of(context);
      final item = items[index];
      final lastUpdated = DateFormat.yMd(locale).add_jms().format(item.updated);
      return ListTile(
          key: Key(item.hashCode.toString()),
          title: Text(item.name),
          subtitle:
              Text('Updated: $lastUpdated\nLocation: ${item.locationText}'),
          leading: CircleAvatar(child: Text(circleAvatarText(item.name))),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                tooltip: localizations!.edit,
                onPressed: () => onEditClick(context, item),
                icon: const Icon(Icons.edit)),
            IconButton(
                tooltip: localizations!.delete,
                onPressed: () => onDeleteClick(context, item),
                icon: const Icon(Icons.delete))
          ]),
          onTap: () {
            final mapController = model.mapController;
            if (mapController != null) {
              goToMapLocation(mapController, item);
            }
          });
    });
  }
}
