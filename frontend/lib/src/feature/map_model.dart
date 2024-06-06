import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapModel extends ChangeNotifier {

  GoogleMapController? _mapController;

  GoogleMapController? get mapController => _mapController;

  set mapController(GoogleMapController? mapController) {
    _mapController = mapController;
    notifyListeners();
  }

}