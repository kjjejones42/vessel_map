import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vessel_map/src/feature/item.dart';

class GoogleMapsMarkerConverter {
  BitmapDescriptor icon;

  GoogleMapsMarkerConverter([this.icon = BitmapDescriptor.defaultMarker]);

  Marker convert(Vessel item, [Function? onTap]) {
    return Marker(
      markerId: item.markerId,
      position: item.location,
      infoWindow: InfoWindow(title: item.name, snippet: item.locationText),
      icon: icon,
    );
  }
}
