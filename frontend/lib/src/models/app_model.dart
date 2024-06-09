import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vessel_map/src/models/vessel.dart';

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

  List<Vessel> _vessels = [];

  UnmodifiableListView<Vessel> get vessels => UnmodifiableListView(_vessels);

  set vessels(List<Vessel> vessels) {
    if (!listEquals(vessels, _vessels)) {
      Future.delayed(Duration.zero, () {
        _vessels = vessels;
        notifyListeners();
      });
    }
  }
}
