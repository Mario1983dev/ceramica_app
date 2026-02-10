import 'package:flutter/services.dart';

class InputUtils {
  // Convierte "1,25" -> 1.25 y maneja vacíos
  static double toDouble(String? s) {
    final t = (s ?? '').trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  // Validación estándar: requerido + > 0
  static String? requiredPositive(
    String? value, {
    String fieldName = 'Este campo',
    double? maxValue,
  }) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '$fieldName es obligatorio';

    final v = toDouble(raw);
    if (v <= 0) return '$fieldName debe ser mayor a 0';

    if (maxValue != null && v > maxValue) {
      return '$fieldName no puede ser mayor a $maxValue';
    }

    return null;
  }

  // Para enteros (ej: cajas, galones, sacos, planchas)
  static String? requiredIntPositive(
    String? value, {
    String fieldName = 'Este campo',
    int? maxValue,
  }) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '$fieldName es obligatorio';

    final v = int.tryParse(raw);
    if (v == null) return '$fieldName debe ser un número entero';
    if (v <= 0) return '$fieldName debe ser mayor a 0';

    if (maxValue != null && v > maxValue) {
      return '$fieldName no puede ser mayor a $maxValue';
    }

    return null;
  }
}

// Permite números con coma o punto y limita decimales
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permite vacío
    if (text.isEmpty) return newValue;

    // Rechaza caracteres inválidos (solo dígitos, coma, punto)
    final valid = RegExp(r'^[0-9]*[.,]?[0-9]*$');
    if (!valid.hasMatch(text)) return oldValue;

    // Limita decimales
    final parts = text.split(RegExp(r'[.,]'));
    if (parts.length == 2 && parts[1].length > decimalRange) return oldValue;

    return newValue;
  }
}
