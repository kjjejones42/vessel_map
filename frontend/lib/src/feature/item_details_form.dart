import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:vessel_map/src/feature/vessel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemDetailsForm extends StatefulWidget {
  final Vessel? item;
  final GlobalKey<FormState> formKey;
  final void Function(Map<String, Object>, BuildContext?)? onSubmit;
  const ItemDetailsForm(
      {super.key, required this.formKey, this.item, this.onSubmit});

  @override
  State<StatefulWidget> createState() {
    return ItemDetailsFormState();
  }
}

class ItemDetailsFormState extends State<ItemDetailsForm> {
  late GlobalKey<FormState> _formKey;
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  AppLocalizations? localizations;

  String? _doubleValidator(String? value, String? Function(double) validator) {
    if (value == null || value.isEmpty) return localizations!.fieldRequired;
    double? num = double.tryParse(value);
    if (num == null) return localizations!.doubleValidation;
    return validator(num);
  }

  String? _latitudeValidator(double value) {
    if (value < -90 || value > 90) {
      return localizations!.latitudeValidation;
    }
    return null;
  }

  String? _longitudeValidator(double value) {
    if (value < -180 || value > 180) {
      return localizations!.longitudeValidation;
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var payload = {
        'name': _nameController.text,
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
      };
      var item = widget.item;
      if (item != null) {
        payload['id'] = item.id;
      }

      widget.onSubmit!(payload, _formKey.currentContext);
    }
  }

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey;
    var item = widget.item;
    if (item != null) {
      _nameController.text = item.name;
      _latitudeController.text = item.location.latitude.toString();
      _longitudeController.text = item.location.longitude.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    return PointerInterceptor(
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      onSaved: (_) => _submitForm(),
                      controller: _nameController,
                      validator: (value) => (value == null || value.isEmpty)
                          ? localizations!.fieldRequired
                          : null,
                      decoration: InputDecoration(
                          label: Text(localizations!.formNameTooltip),
                          border: const OutlineInputBorder()),
                    )),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: _latitudeController,
                      validator: (value) =>
                          _doubleValidator(value, _latitudeValidator),
                      decoration: InputDecoration(
                          label: Text(localizations!.formLatitudeTooltip),
                          border: const OutlineInputBorder()),
                    )),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: _longitudeController,
                      validator: (value) =>
                          _doubleValidator(value, _longitudeValidator),
                      decoration: InputDecoration(
                          label: Text(localizations!.formLongitudeTooltip),
                          border: const OutlineInputBorder()),
                    )),
              ],
            )));
  }
}
