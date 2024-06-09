import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vessel_map/src/feature/add_item_button.dart';
import 'package:vessel_map/src/feature/search_text_bar.dart';
import 'package:vessel_map/src/feature/sort_items_button.dart';
import 'package:vessel_map/src/feature/vessel.dart';
import 'package:vessel_map/src/feature/list_entry_builder.dart';
import 'package:vessel_map/src/feature/app_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemSideView extends StatefulWidget {
  final bool showMenuButton;
  const ItemSideView({super.key, this.showMenuButton = false});

  @override
  State<StatefulWidget> createState() => ItemSideViewState();
}

class ItemSideViewState extends State<ItemSideView> {
  String _searchTerm = '';
  VesselSortKeys _currentSortFunc = VesselSortKeys.created;
  final TextEditingController _textController = TextEditingController();

  static final Map<VesselSortKeys, int Function(Vessel, Vessel)> _sortFuncs = {
    VesselSortKeys.name: (a, b) => a.name.compareTo(b.name),
    VesselSortKeys.updated: (a, b) => b.updated.compareTo(a.updated),
    VesselSortKeys.created: (a, b) => a.id.compareTo(b.id)
  };

  AppLocalizations? localizations;

  void _setFilter(String value) {
    setState(() {
      _searchTerm = value.toLowerCase();
    });
  }

  void _sortItems(VesselSortKeys value) {
    setState(() {
      _currentSortFunc = value;
    });
  }

  void _clearFilter() {
    setState(() {
      _textController.clear();
      _searchTerm = '';
    });
  }

  List<Vessel> _filterItems(List<Vessel> items) {
    var func = _sortFuncs[_currentSortFunc];
    var filteredItems =
        items.where((x) => x.name.toLowerCase().contains(_searchTerm)).toList();
    filteredItems.sort(func);
    return filteredItems;
  }

  Widget searchTextChip() => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputChip(
        label: Text(localizations!.searchText(_searchTerm)),
        deleteButtonTooltipMessage: localizations!.clear,
        onDeleted: _clearFilter,
      ));

  Widget nonDrawerSearchBar() => Flexible(
      flex: 0,
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                  child: SearchTextBar(
                      textController: _textController, onSubmit: _setFilter)),
              Flexible(
                  flex: 0,
                  child: Row(children: [
                    const AddItemButton(),
                    SortItemsButton(onChange: _sortItems)
                  ]))
            ],
          )));

  Widget drawerSearchBar() => Flexible(
      flex: 0,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.menu))),
                Expanded(child: Container()),
                Row(children: [
                  const AddItemButton(),
                  SortItemsButton(onChange: _sortItems)
                ])
              ],
            )),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: SearchTextBar(
                        textController: _textController, onSubmit: _setFilter)),
              ],
            ))
      ]));

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (BuildContext context, AppModel model, Widget? child) {
      final filteredItems = _filterItems(model.items);
      localizations = AppLocalizations.of(context);
      return Column(children: [
        (widget.showMenuButton) ? drawerSearchBar() : nonDrawerSearchBar(),
        (_searchTerm != '') ? searchTextChip() : const SizedBox.shrink(),
        Expanded(
            child: filteredItems.isEmpty
                ? Text(localizations!.noResults)
                : ListView.builder(
                    restorationId: 'vesselListView',
                    itemCount: filteredItems.length,
                    padding: EdgeInsets.zero,
                    itemBuilder:
                        ListEntryBuilder(items: filteredItems).itemBuilder))
      ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }
}
