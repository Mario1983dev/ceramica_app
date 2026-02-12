import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/input_utils.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool requiredField;

  /// Texto de ayuda bajo el campo (ideal para usuarios no técnicos)
  final String? helperText;

  /// Ejemplo que se muestra en gris dentro del campo
  final String? hintText;

  /// Si es true, solo permite enteros (0-9)
  final bool integerOnly;

  /// Cantidad máxima de decimales permitidos (solo aplica si integerOnly=false)
  final int decimalRange;

  final String? Function(String?)? validator;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.requiredField = true,
    this.helperText,
    this.hintText,
    this.integerOnly = false,
    this.decimalRange = 2,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final inputFormatters = <TextInputFormatter>[];

    if (integerOnly) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    } else {
      inputFormatters.add(DecimalTextInputFormatter(decimalRange: decimalRange));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integerOnly),
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          helperText: helperText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          errorMaxLines: 3,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator ?? _defaultValidator,
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (!requiredField) return null;

    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingrese un valor';

    if (integerOnly) {
      final parsed = int.tryParse(v);
      if (parsed == null) return 'Debe ser un número entero';
      if (parsed <= 0) return 'Debe ser mayor que 0';
      return null;
    }

    final parsed = double.tryParse(v.replaceAll(',', '.')) ?? 0;
    if (parsed <= 0) return 'Debe ser mayor que 0';

    return null;
  }
}
