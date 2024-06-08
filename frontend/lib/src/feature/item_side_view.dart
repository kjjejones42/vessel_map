import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/api_request_manager.dart';
import 'package:vessel_map/src/feature/vessel.dart';
import 'package:vessel_map/src/feature/item_details_form.dart';
import 'package:vessel_map/src/feature/list_entry_builder.dart';
import 'package:vessel_map/src/feature/app_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemSideView extends StatefulWidget {
  final bool showMenuButton;

  const ItemSideView({super.key, this.showMenuButton = false});

  @override
  State<StatefulWidget> createState() => ItemSideViewState();
}

enum VesselSortKeys {
  created,
  name,
  updated,
}

class ItemSideViewState extends State<ItemSideView> {
  String _textValue = '';
  String _searchTerm = '';
  VesselSortKeys _currentSortFunc = VesselSortKeys.created;
  List<Vessel> _filteredItems = [];
  final TextEditingController _textController = TextEditingController();

  static final Map<VesselSortKeys, int Function(Vessel, Vessel)> _sortFuncs = {
    VesselSortKeys.name: (a, b) => a.name.compareTo(b.name),
    VesselSortKeys.updated: (a, b) => b.updated.compareTo(a.updated),
    VesselSortKeys.created: (a, b) => a.id.compareTo(b.id)
  };

  AppLocalizations? localizations;

  void _setFilter(List<Vessel> items) {
    _searchTerm = _textValue.toLowerCase();
    final filteredItems = _filterItems(items);
    setState(() {
      _filteredItems = filteredItems;
    });
  }

  void _sortItems(List<Vessel> items, VesselSortKeys value) {
    _currentSortFunc = value;
    final filteredItems = _filterItems(items);
    setState(() {
      _filteredItems = filteredItems;
    });
  }

  List<Vessel> _filterItems(List<Vessel> items) {
    var func = _sortFuncs[_currentSortFunc];
    var filteredItems =
        items.where((x) => x.name.toLowerCase().contains(_searchTerm)).toList();
    filteredItems.sort(func);
    return filteredItems;
  }

  void _clearFilter(List<Vessel> items) {
    _textController.clear();
    _textValue = '';
    _searchTerm = '';
    final filteredItems = _filterItems(items);
    setState(() {
      _filteredItems = filteredItems;
    });
  }

  void onSubmitCreateVessel(
      Map<String, dynamic> payload, BuildContext? context) async {
    await ApiRequestManager().create(payload);
    if (context != null && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _addNew() {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
          child: AlertDialog.adaptive(
        title: Text(localizations!.createTitle),
        content:
            ItemDetailsForm(formKey: formKey, onSubmit: onSubmitCreateVessel),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations!.cancel)),
          TextButton(
              onPressed: () => formKey.currentState!.save(),
              child: Text(localizations!.submit)),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (BuildContext context, AppModel model, Widget? child) {
      final items = model.items;
      _filteredItems = _filterItems(items);
      localizations = AppLocalizations.of(context);
      var searchText = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.all((Radius.circular((20))))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  overflow: TextOverflow.ellipsis,
                  localizations!.searchText(_searchTerm)),
              IconButton(
                  tooltip: localizations!.clear,
                  onPressed: () => _clearFilter(items),
                  icon: const Icon(Icons.clear))
            ],
          ));
      return Column(children: [
        Flexible(
            flex: 0,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    widget.showMenuButton
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.menu)))
                        : const SizedBox.shrink(),
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      onChanged: (value) => setState(() => _textValue = value),
                      onSubmitted: (value) => _setFilter(items),
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: localizations!.search,
                          suffixIcon: IconButton(
                            tooltip: localizations!.search,
                            icon: const Icon(Icons.search),
                            onPressed: () => _setFilter(items),
                          )),
                    )),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                            onPressed: _addNew,
                            icon: const Icon(Icons.add),
                            tooltip: localizations!.addTooltip)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: PopupMenuButton(
                            onSelected: (key) =>
                                _sortItems(items, key as VesselSortKeys),
                            tooltip: localizations!.sortTooltip,
                            icon: const Icon(Icons.sort),
                            itemBuilder: (context) =>
                                VesselSortKeys.values.map<PopupMenuItem>((key) {
                                  final name =
                                      toBeginningOfSentenceCase(key.name);
                                  return PopupMenuItem(
                                      value: key, child: Text(name));
                                }).toList()))
                  ],
                ))),
        (_searchTerm != '') ? searchText : const SizedBox.shrink(),
        Expanded(
            child: ListView.builder(
                restorationId: 'sampleItemListView',
                itemCount: _filteredItems.length,
                padding: EdgeInsets.zero,
                itemBuilder:
                    ListEntryBuilder(items: _filteredItems).itemBuilder))
      ]);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
