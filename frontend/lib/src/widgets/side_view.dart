import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vessel_map/src/models/app_model.dart';
import 'package:vessel_map/src/models/vessel.dart';
import 'package:vessel_map/src/widgets/add_button.dart';
import 'package:vessel_map/src/widgets/list_entry_builder.dart';
import 'package:vessel_map/src/widgets/search_text_bar.dart';
import 'package:vessel_map/src/widgets/sort_button.dart';

class SideView extends StatefulWidget {
  /// Whether to use the menu drawer layout or not.
  final bool isInDrawer;
  const SideView({super.key, this.isInDrawer = false});

  @override
  State<StatefulWidget> createState() => SideViewState();
}

class SideViewState extends State<SideView> {
  /// The text by which the entries are currently filtered.
  String filterTerm = '';

  /// The current sorting function for the entries.
  SortKeys currentSortFunc = SortKeys.created;

  final TextEditingController textController = TextEditingController();

  /// The functions used to sort the entries list.
  static final Map<SortKeys, int Function(Vessel, Vessel)> sortingFunctions = {
    SortKeys.name: (a, b) => a.name.compareTo(b.name),
    SortKeys.updated: (a, b) => b.updated.compareTo(a.updated),
    SortKeys.created: (a, b) => a.id.compareTo(b.id)
  };

  AppLocalizations? localizations;

  void setFilter(String value) {
    setState(() {
      filterTerm = value.toLowerCase();
    });
  }

  void sort(SortKeys value) {
    setState(() {
      currentSortFunc = value;
    });
  }

  void clearFilter() {
    setState(() {
      textController.clear();
      filterTerm = '';
    });
  }

  /// Filters and sorts the supplied lists by the chosen filter term and
  /// sorting function. Returns the processed list.
  List<Vessel> filterAndSort(List<Vessel> vessels) {
    var func = sortingFunctions[currentSortFunc];
    var entries = vessels
        .where((x) => x.name.toLowerCase().contains(filterTerm))
        .toList();
    entries.sort(func);
    return entries;
  }

  /// The chip to show when the entries are filtered. Includes a icon to
  /// clear the filter.
  Widget searchTextChip() => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputChip(
        label: Text(localizations!.searchText(filterTerm)),
        deleteButtonTooltipMessage: localizations!.clear,
        onDeleted: clearFilter,
      ));

  /// The layout to use if not a menu drawer.
  Widget nonDrawerSearchBar() => Flexible(
      flex: 0,
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                  child: SearchTextBar(
                      textController: textController, onSubmit: setFilter)),
              Flexible(
                  flex: 0,
                  child: Row(children: [
                    const AddButton(),
                    SortButton(onChange: sort)
                  ]))
            ],
          )));

  /// The layout to use if in a menu drawer. Includes a button to close the menu.
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
                Row(children: [const AddButton(), SortButton(onChange: sort)])
              ],
            )),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: SearchTextBar(
                        textController: textController, onSubmit: setFilter)),
              ],
            ))
      ]));

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (BuildContext context, AppModel model, Widget? child) {
      final entries = filterAndSort(model.vessels);
      localizations = AppLocalizations.of(context);
      return Column(children: [
        (widget.isInDrawer) ? drawerSearchBar() : nonDrawerSearchBar(),
        (filterTerm != '') ? searchTextChip() : const SizedBox.shrink(),
        Expanded(
            child: entries.isEmpty
                ? Text(localizations!.noResults)
                : ListView.builder(
                    restorationId: 'vesselListView',
                    itemCount: entries.length,
                    padding: EdgeInsets.zero,
                    itemBuilder:
                        ListEntryBuilder(vessels: entries).entryBuilder))
      ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }
}
