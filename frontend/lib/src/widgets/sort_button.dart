import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum SortKeys {
  created,
  name,
  updated,
}

class SortButton extends StatelessWidget {
  final Function(SortKeys) onChange;

  const SortButton({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.all(4),
        child: PopupMenuButton(
            onSelected: (key) => onChange(key as SortKeys),
            tooltip: localizations!.sortTooltip,
            icon: const Icon(Icons.sort),
            itemBuilder: (context) => SortKeys.values.map<PopupMenuItem>((key) {
                  final name = toBeginningOfSentenceCase(key.name);
                  return PopupMenuItem(value: key, child: Text(name));
                }).toList()));
  }
}
