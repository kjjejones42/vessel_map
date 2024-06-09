import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchTextBar extends StatelessWidget {
  final TextEditingController textController;
  final Function(String) onSubmit;

  const SearchTextBar(
      {super.key, required this.textController, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.all(4),
        child: TextField(
          controller: textController,
          onSubmitted: onSubmit,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: localizations!.search,
              suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    tooltip: localizations.search,
                    icon: const Icon(Icons.search),
                    onPressed: () => onSubmit(textController.text),
                  ))),
        ));
  }
}
