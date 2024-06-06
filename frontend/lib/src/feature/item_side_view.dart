import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/api_manager.dart';
import 'package:vessel_map/src/feature/item.dart';
import 'package:vessel_map/src/feature/item_details_form.dart';
import 'package:vessel_map/src/feature/list_entry_builder.dart';
import 'package:vessel_map/src/feature/map_model.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class ItemSideView extends StatefulWidget {
  final List<Vessel> items;

  const ItemSideView({super.key, required this.items});

  @override
  State<StatefulWidget> createState() {
    return ItemSideViewState();
  }
}

enum VesselSortValues {
  created,
  name,
  updated,
}

class ItemSideViewState extends State<ItemSideView> {
  String _textValue = "";
  String _searchTerm = "";
  VesselSortValues _sortFunc = VesselSortValues.created;
  List<Vessel> _filteredItems = [];
  final TextEditingController _textController = TextEditingController();

  static final Map<VesselSortValues, int Function(Vessel, Vessel)> _sortFuncs = {
    VesselSortValues.name: (a, b) => a.name.compareTo(b.name),
    VesselSortValues.updated: (a, b) => a.updated.compareTo(b.updated),
    VesselSortValues.created: (a, b) => a.id.compareTo(b.id)
  };

  void _setFilter() {
    setState(() {
      _searchTerm = _textValue.toLowerCase();
      _filterItems();
    });
  }

  void _sortItems(VesselSortValues value) {
    setState(() {
      _sortFunc = value;
      _filterItems();
    });
  }

  void _filterItems() {
    setState(() {
      var func = _sortFuncs[_sortFunc];
      _filteredItems = widget.items
          .where((x) => x.name.toLowerCase().contains(_searchTerm))
          .toList();
      _filteredItems.sort(func);
    });
  }

  void _clearFilter() {
    setState(() {
      _textController.clear();
      _textValue = "";
      _searchTerm = "";
      _filterItems();
    });
  }

  void onSubmitCreateVessel(Map<String, dynamic> payload, BuildContext? context) async {
    await ApiManager().create(payload);
    if (context!= null && context.mounted) {
      Navigator.pop(context, 'Submitted');
    }
  }

  void _addNew() {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
          child: AlertDialog.adaptive(
        title: const Text('Add New Vessel'),
        content:
            ItemDetailsForm(formKey: formKey, onSubmit: onSubmitCreateVessel),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => formKey.currentState!.save(),
              child: const Text('Submit')),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    _filterItems();
    var searchText = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all((Radius.circular((20))))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Showing results for \"$_searchTerm\""),
            IconButton(
                tooltip: "Clear",
                onPressed: _clearFilter,
                icon: const Icon(Icons.clear))
          ],
        ));
    return Column(children: [
      Flexible(
          flex: 0,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    onChanged: (value) => setState(() => _textValue = value),
                    onSubmitted: (value) => _setFilter(),
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "Search",
                        suffixIcon: IconButton(
                          tooltip: "Search",
                          icon: const Icon(Icons.search),
                          onPressed: _filterItems,
                        )),
                  )),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                          onPressed: _addNew,
                          icon: const Icon(Icons.add),
                          tooltip: "Add New")),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: PopupMenuButton(
                          onSelected: (key) => _sortItems(key as VesselSortValues),
                          tooltip: "Sort By",
                          icon: const Icon(Icons.sort),
                          itemBuilder: (context) =>
                              VesselSortValues.values.map<PopupMenuItem>((key) {
                                final name = toBeginningOfSentenceCase(key.name);
                                return PopupMenuItem(
                                    value: key, child: Text(name));
                              }).toList()))
                ],
              ))),
      (_searchTerm != "") ? searchText : const SizedBox.shrink(),
      Expanded(child: Consumer<MapModel>(
        builder: (context, model, child) {
          var listEntryBuilder =
              ListEntryBuilder(_filteredItems, model.mapController);
          return ListView.builder(
              restorationId: 'sampleItemListView',
              itemCount: _filteredItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: listEntryBuilder.itemBuilder);
        },
      ))
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
