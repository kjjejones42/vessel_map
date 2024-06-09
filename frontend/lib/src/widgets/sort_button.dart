import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum SortKeys {
  /// Sort by datetime created. Earliest first.
  created,

  /// Sort alphabetically by vessel name.
  name,

  /// Sort by datetime updated. Latest first.
  updated,
}

class SortButton extends StatelessWidget {
  final Function(SortKeys) onChange;

  const SortButton({super.key, required this.onChange});

  /// Converts each SortKey option to an item in the sort menu.
  List<PopupMenuEntry<SortKeys>> sortMenuItemBuilder(BuildContext context) {
    return SortKeys.values.map<PopupMenuItem<SortKeys>>((key) {
      final sortOptionName = toBeginningOfSentenceCase(key.name);
      return PopupMenuItem(value: key, child: Text(sortOptionName));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.all(4),
        child: PopupMenuButton<SortKeys>(
            onSelected: onChange,
            tooltip: localizations!.sortTooltip,
            icon: const Icon(Icons.sort),
            itemBuilder: sortMenuItemBuilder));
  }
}
