import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vessel_map/src/feature/vessel.dart';

class AppModel extends ChangeNotifier {

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  set isConnected(bool isConnected) {
    if (_isConnected != isConnected) {
      Future.delayed(Duration.zero, () {
        _isConnected = isConnected;
        notifyListeners();
      });
    }
  }

  GoogleMapController? _mapController;

  GoogleMapController? get mapController => _mapController;

  set mapController(GoogleMapController? mapController) {
    if (_mapController != mapController) {
      Future.delayed(Duration.zero, () {
        _mapController = mapController;
        notifyListeners();
      });
    }
  }

  List<Vessel> _items = [];

  List<Vessel> get items => _items;

  set items(List<Vessel> items) {
    if (!listEquals(items, _items)) {
      Future.delayed(Duration.zero, () {
        _items = items;
        notifyListeners();
      });
    }
  }
  

}