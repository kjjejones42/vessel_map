import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vessel_map/src/models/vessel.dart';

/// Form which allows the user to enter / edit vessel details. This is reused for
/// both the Edit and Delete dialog boxes.
class VesselDetailsForm extends StatefulWidget {
  /// If specified, the form's default input values are set to the vessel properties.
  final Vessel? vessel;
  final GlobalKey<FormState> formKey;
  final void Function(Map<String, Object>, BuildContext?) onSubmit;
  const VesselDetailsForm(
      {super.key, required this.formKey, this.vessel, required this.onSubmit});

  @override
  State<StatefulWidget> createState() => VesselDetailsFormState();
}

class VesselDetailsFormState extends State<VesselDetailsForm> {
  late GlobalKey<FormState> formKey;
  final nameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  AppLocalizations? localizations;

  /// Validates the name field on submit.
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return localizations!.fieldRequired;
    }
    return null;
  }

  /// Validates the latitude and longitude fields on submit,
  /// then calls a specific validator for each field
  String? doubleValidator(String? value, String? Function(double) validator) {
    if (value == null || value.isEmpty) return localizations!.fieldRequired;
    double? number = double.tryParse(value);
    if (number == null) return localizations!.doubleValidation;
    return validator(number);
  }

  /// Validates the latitude field.
  String? latitudeValidator(double value) {
    if (value < -90 || value > 90) {
      return localizations!.latitudeValidation;
    }
    return null;
  }

  /// Validates the longitude field.
  String? longitudeValidator(double value) {
    if (value < -180 || value > 180) {
      return localizations!.longitudeValidation;
    }
    return null;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      var payload = {
        'name': nameController.text,
        'latitude': double.parse(latitudeController.text),
        'longitude': double.parse(longitudeController.text),
      };
      var vessel = widget.vessel;
      if (vessel != null) {
        payload['id'] = vessel.id;
      }
      widget.onSubmit(payload, formKey.currentContext);
    }
  }

  @override
  void initState() {
    super.initState();
    formKey = widget.formKey;
    var vessel = widget.vessel;
    if (vessel != null) {
      nameController.text = vessel.name;
      latitudeController.text = vessel.location.latitude.toString();
      longitudeController.text = vessel.location.longitude.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    return PointerInterceptor(
        child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      onSaved: (_) => submitForm(),
                      controller: nameController,
                      validator: nameValidator,
                      decoration: InputDecoration(
                          label: Text(localizations!.formNameTooltip),
                          border: const OutlineInputBorder()),
                    )),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: latitudeController,
                      validator: (value) =>
                          doubleValidator(value, latitudeValidator),
                      decoration: InputDecoration(
                          label: Text(localizations!.formLatitudeTooltip),
                          border: const OutlineInputBorder()),
                    )),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: longitudeController,
                      validator: (value) =>
                          doubleValidator(value, longitudeValidator),
                      decoration: InputDecoration(
                          label: Text(localizations!.formLongitudeTooltip),
                          border: const OutlineInputBorder()),
                    )),
              ],
            )));
  }
}
