import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/google_maps_converter.dart';

import 'app_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<StatefulWidget> createState() {
    return MapViewState();
  }
}

class MapViewState extends State<MapView> {
  GoogleMapsMarkerConverter _converter = GoogleMapsMarkerConverter();

  void fetchIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(50, 50)),
        'assets/images/boat_marker.png');
    setState(() {
      _converter = GoogleMapsMarkerConverter(icon);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (BuildContext context, AppModel model, Widget? child) { 
      return GoogleMap(
        onMapCreated: (controller) => model.mapController = controller,
        markers: model.items.map(_converter.convert).toSet(),
        initialCameraPosition:
            const CameraPosition(target: LatLng(51.5072, 0.1276), zoom: 5));
     });
  }
}
