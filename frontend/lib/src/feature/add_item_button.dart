import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vessel_map/src/feature/api_request_manager.dart';
import 'package:vessel_map/src/feature/item_details_form.dart';

class AddItemButton extends StatelessWidget {
  const AddItemButton({super.key});

  void onSubmitCreateVessel(
      Map<String, dynamic> payload, BuildContext? context) async {
    await ApiRequestManager().create(payload);
    if (context != null && context.mounted) {
      Navigator.pop(context);
    }
  }

  void addNew(BuildContext context, localizations) {
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
    final localizations = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.all(4),
        child: IconButton(
            onPressed: () => addNew(context, localizations),
            icon: const Icon(Icons.add),
            tooltip: localizations!.addTooltip));
  }
}
