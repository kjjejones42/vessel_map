import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:vessel_map/src/models/vessel.dart';

class GoogleMapsContainer extends StatefulWidget {
  const GoogleMapsContainer({super.key});

  @override
  State<StatefulWidget> createState() => GoogleMapsContainerState();
}

class GoogleMapsContainerState extends State<GoogleMapsContainer> {
  BitmapDescriptor? icon;

  /// Initial map position. Could be updated to use current device location, if
  /// client wants to request that permission.
  static const initialPosition = LatLng(51.5072, 0.1276);

  /// Fetch the custom map marker image from assets, then trigger rerender.
  void fetchIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(50, 50)),
        'assets/images/boat_marker.png');
    setState(() {
      this.icon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchIcon();
  }

  /// Converts vessels to Google Map markers.
  Set<Marker> markers(List<Vessel> vessels) {
    final icon = this.icon;
    if (icon == null) return {};
    return vessels.map((vessel) => vessel.toMarker(icon)).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (BuildContext context, AppModel model, Widget? child) {
      return GoogleMap(
          // Once the MapController is created, add it to the model for use in the
          // list view.
          onMapCreated: (controller) => model.mapController = controller,
          markers: markers(model.vessels),
          initialCameraPosition:
              const CameraPosition(target: initialPosition, zoom: 5));
    });
  }
}
