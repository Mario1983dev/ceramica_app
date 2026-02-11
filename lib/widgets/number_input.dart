import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool requiredField;
  final String? Function(String?)? validator;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.requiredField = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          errorMaxLines: 3, // ← queda fijo aquí
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

    final parsed = double.tryParse(v.replaceAll(',', '.')) ?? 0;

    if (parsed <= 0) {
      return 'Debe ser mayor que 0';
    }

    return null;
  }
}
