import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vessel {
  final int id;
  final String name;
  final LatLng location;
  final DateTime updated;
  const Vessel(this.id, this.name, this.location, this.updated);

  /// The lat/lng of the vessel, in a human readable format.
  String get locationText => '${location.latitude}°N, ${location.longitude}°W';

  /// Unique Google Maps MarkerId for this vessel.
  MarkerId get markerId => MarkerId(hashCode.toString());

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
        json['id'] as int,
        json['name'] as String,
        LatLng(json['latitude'] as double, json['longitude'] as double),
        DateTime.parse(json['updated_at']).toLocal());
  }

  /// Convert to Google Maps Marker for map display.
  Marker toMarker(BitmapDescriptor icon) {
    return Marker(
      markerId: markerId,
      position: location,
      infoWindow: InfoWindow(title: name, snippet: locationText),
      icon: icon,
    );
  }

  /// Overriden hashcode implementation ensures vessel equality is calculated from
  /// properties and not identity. This is important when the app needs to determine
  /// whether to update the UI.
  @override
  int get hashCode => Object.hash(id, name, location, updated);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != Vessel) return false;
    return hashCode == other.hashCode;
  }
}
