import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vessel_map/src/models/vessel.dart';

/// Models the overall state of the app and notifies listeners on change to trigger
/// UI update.
class AppModel extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  set isConnected(bool isConnected) {
    if (_isConnected != isConnected) {
      _setAndNotifyListeners(() {
        _isConnected = isConnected;
      });
    }
  }

  GoogleMapController? _mapController;

  GoogleMapController? get mapController => _mapController;

  set mapController(GoogleMapController? mapController) {
    if (_mapController != mapController) {
      _setAndNotifyListeners(() {
        _mapController = mapController;
      });
    }
  }

  List<Vessel> _vessels = [];

  UnmodifiableListView<Vessel> get vessels => UnmodifiableListView(_vessels);

  set vessels(List<Vessel> vessels) {
    if (!listEquals(vessels, _vessels)) {
      _setAndNotifyListeners(() {
        _vessels = vessels;
      });
    }
  }

  // Only notify listeners after the current build is complete, to avoid infinite
  // rendering loops.
  void _setAndNotifyListeners(Function setter) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setter();
      notifyListeners();
    });
  }
}
