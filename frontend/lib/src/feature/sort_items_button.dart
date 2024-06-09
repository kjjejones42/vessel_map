import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum VesselSortKeys {
  created,
  name,
  updated,
}

class SortItemsButton extends StatelessWidget {
  final Function(VesselSortKeys) onChange;

  const SortItemsButton({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.all(4),
        child: PopupMenuButton(
            onSelected: (key) => onChange(key as VesselSortKeys),
            tooltip: localizations!.sortTooltip,
            icon: const Icon(Icons.sort),
            itemBuilder: (context) =>
                VesselSortKeys.values.map<PopupMenuItem>((key) {
                  final name = toBeginningOfSentenceCase(key.name);
                  return PopupMenuItem(value: key, child: Text(name));
                }).toList()));
  }
}
