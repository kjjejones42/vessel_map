import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vessel {
  final int id;
  final String name;
  final LatLng location;
  final DateTime updated;
  const Vessel(this.id, this.name, this.location, this.updated);

  String get locationText => '${location.latitude}°N, ${location.longitude}°W';

  MarkerId get markerId => MarkerId(hashCode.toString());

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
        json['id'] as int,
        json['name'] as String,
        LatLng(json['latitude'] as double, json['longitude'] as double),
        DateTime.parse(json['updated_at']).toLocal());
  }

  @override
  int get hashCode => Object.hash(id, name, location, updated);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != Vessel) return false;
    return hashCode == other.hashCode;
  }
}
