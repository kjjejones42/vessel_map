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
  final bool showMenuButton;
  const SideView({super.key, this.showMenuButton = false});

  @override
  State<StatefulWidget> createState() => SideViewState();
}

class SideViewState extends State<SideView> {
  String searchTerm = '';
  SortKeys currentSortFunc = SortKeys.created;
  final TextEditingController textController = TextEditingController();

  static final Map<SortKeys, int Function(Vessel, Vessel)> sortingFunctions = {
    SortKeys.name: (a, b) => a.name.compareTo(b.name),
    SortKeys.updated: (a, b) => b.updated.compareTo(a.updated),
    SortKeys.created: (a, b) => a.id.compareTo(b.id)
  };

  AppLocalizations? localizations;

  void setFilter(String value) {
    setState(() {
      searchTerm = value.toLowerCase();
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
      searchTerm = '';
    });
  }

  List<Vessel> filter(List<Vessel> vessels) {
    var func = sortingFunctions[currentSortFunc];
    var entries = vessels
        .where((x) => x.name.toLowerCase().contains(searchTerm))
        .toList();
    entries.sort(func);
    return entries;
  }

  Widget searchTextChip() => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputChip(
        label: Text(localizations!.searchText(searchTerm)),
        deleteButtonTooltipMessage: localizations!.clear,
        onDeleted: clearFilter,
      ));

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
      final entries = filter(model.vessels);
      localizations = AppLocalizations.of(context);
      return Column(children: [
        (widget.showMenuButton) ? drawerSearchBar() : nonDrawerSearchBar(),
        (searchTerm != '') ? searchTextChip() : const SizedBox.shrink(),
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
