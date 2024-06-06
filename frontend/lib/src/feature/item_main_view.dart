import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:vessel_map/src/feature/item_side_view.dart';
import 'package:vessel_map/src/feature/map_view.dart';

import 'item.dart';

class ItemMainView extends StatelessWidget {
  const ItemMainView({
    super.key,
    required this.items,
  });

  static const routeName = '/';

  final List<Vessel> items;

  Widget _portraitView(BuildContext context) {
    var minWidth = MediaQuery.of(context).size.width * .75;
    var menuIcon = Padding(padding: const EdgeInsets.fromLTRB(8, 8, 0, 0), child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.menu)));
    return Scaffold(
      appBar: _appBar,
      body: MapView(items: items),
      drawer: PointerInterceptor(child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth), 
        child: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              menuIcon,
              Expanded(child: ItemSideView(items: items)),
          ],))
      ))
    );
  }

  Widget _landscapeView() {
    return Scaffold(
        appBar: _appBar,
        body: Row(children: [
          Flexible(flex: 1, child: ItemSideView(items: items)),
          Expanded(flex: 2, child: MapView(items: items))
        ]));
  }

  AppBar get _appBar => AppBar(title: const Text('Sample Items'));

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return switch (orientation) {
      Orientation.landscape => _landscapeView(),
      Orientation.portrait => _portraitView(context)
    };
  }
}
