import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:vessel_map/src/feature/api_manager.dart';
import 'package:vessel_map/src/feature/item.dart';
import 'package:vessel_map/src/feature/item_details_form.dart';

class ListEntryBuilder {
  final List<Vessel> _items;
  final GoogleMapController? _controller;

  ListEntryBuilder(this._items, this._controller);

  void goToMapLocation(GoogleMapController controller, Vessel item) {
    controller.showMarkerInfoWindow(item.markerId);
    controller.animateCamera(CameraUpdate.zoomTo(10));
    controller.animateCamera(CameraUpdate.newLatLng(item.location));
  }

  void onDeleteClick(BuildContext context, Vessel item) {
    showDialog(
        context: context,
        builder: (context) => PointerInterceptor(
                child: AlertDialog.adaptive(
              title: const Text("Warning"),
              content: Text(
                  "This will delete all data for \"${item.name}\". Do you want to proceed?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      ApiManager().delete(item.id);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK')),
              ],
            )));
  }

  void onSubmitEditForm(Map<String, dynamic> payload, BuildContext? context) async {
    await ApiManager().update(payload);
    if (context != null && context.mounted) {
      Navigator.pop(context, 'Submitted');
    }
  }

  void onEditClick(BuildContext context, Vessel item) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) => PointerInterceptor(
              child: AlertDialog.adaptive(
                title: const Text('Edit Vessel Details'),
                content: ItemDetailsForm(
                    formKey: formKey, item: item, onSubmit: onSubmitEditForm),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => formKey.currentState!.save(),
                      child: const Text('Submit')),
                ],
              ),
            ));
  }

  Widget? itemBuilder(BuildContext context, int index) {
    final item = _items[index];
    return ListTile(
        key: Key(item.name),
        title: Text(item.name),
        subtitle: Text(item.locationText),
        leading: const CircleAvatar(
          foregroundImage: AssetImage('assets/images/boat.png'),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip: "Edit",
              onPressed: () => onEditClick(context, item),
              icon: const Icon(Icons.edit)),
          IconButton(
              tooltip: "Delete",
              onPressed: () => onDeleteClick(context, item),
              icon: const Icon(Icons.delete))
        ]),
        onTap: () {
          if (_controller != null) {
            goToMapLocation(_controller, item);
          }
        });
  }
}
