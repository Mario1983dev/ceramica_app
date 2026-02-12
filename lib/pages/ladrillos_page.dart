import 'dart:math';
import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/input_utils.dart';
import '../widgets/number_input.dart';
import '../widgets/result_tile.dart';

class LadrillosPage extends StatefulWidget {
  const LadrillosPage({super.key});

  @override
  State<LadrillosPage> createState() => _LadrillosPageState();
}

class _LadrillosPageState extends State<LadrillosPage> {
  final _formKey = GlobalKey<FormState>();

  // Muro (m)
  final _largoMuroCtrl = TextEditingController();
  final _altoMuroCtrl = TextEditingController();

  // Ladrillo (cm) - valores por defecto editables
  // (Puedes cambiarlos según el ladrillo real)
  final _largoLadrilloCtrl = TextEditingController(text: '20');
  final _altoLadrilloCtrl = TextEditingController(text: '7');

  // Junta (mm)
  final _juntaMmCtrl = TextEditingController(text: '10');

  bool _usarMerma10 = true;

  int _ladrillosSinMerma = 0;
  int _ladrillosConMerma = 0;

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final largoMuro = InputUtils.toDouble(_largoMuroCtrl.text); // m
    final altoMuro = InputUtils.toDouble(_altoMuroCtrl.text); // m

    final largoLadrilloCm = InputUtils.toDouble(_largoLadrilloCtrl.text); // cm
    final altoLadrilloCm = InputUtils.toDouble(_altoLadrilloCtrl.text); // cm
    final juntaMm = InputUtils.toDouble(_juntaMmCtrl.text); // mm

    final areaMuro = largoMuro * altoMuro;

    // Pasamos a metros y sumamos junta
    // mm -> cm: /10, luego cm -> m: /100  => (cm + mm/10)/100
    final largoModuloM = (largoLadrilloCm + juntaMm / 10) / 100;
    final altoModuloM = (altoLadrilloCm + juntaMm / 10) / 100;

    final areaModulo = largoModuloM * altoModuloM;
    if (areaModulo <= 0) return;

    final sinMerma = (areaMuro / areaModulo).ceil();
    final conMerma = _usarMerma10 ? (sinMerma * 1.10).ceil() : sinMerma;

    setState(() {
      _ladrillosSinMerma = max(0, sinMerma);
      _ladrillosConMerma = max(0, conMerma);
    });
  }

  void _limpiar() {
    _formKey.currentState?.reset();

    _largoMuroCtrl.clear();
    _altoMuroCtrl.clear();

    // mantenemos valores por defecto para ayudar al usuario
    _largoLadrilloCtrl.text = '20';
    _altoLadrilloCtrl.text = '7';
    _juntaMmCtrl.text = '10';

    setState(() {
      _ladrillosSinMerma = 0;
      _ladrillosConMerma = 0;
      _usarMerma10 = true;
    });
  }

  @override
  void dispose() {
    _largoMuroCtrl.dispose();
    _altoMuroCtrl.dispose();
    _largoLadrilloCtrl.dispose();
    _altoLadrilloCtrl.dispose();
    _juntaMmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cálculo de Ladrillos')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Dimensiones del muro', style: _sectionTitleStyle),
                const SizedBox(height: 8),

                NumberInput(
                  controller: _largoMuroCtrl,
                  label: 'Largo del muro',
                  suffix: 'm',
                  hintText: 'Ej: 4.2',
                  validator: (v) => InputUtils.requiredPositive(
                    v,
                    fieldName: 'Largo del muro',
                    maxValue: AppConstants.maxInputValue,
                  ),
                ),

                NumberInput(
                  controller: _altoMuroCtrl,
                  label: 'Alto del muro',
                  suffix: 'm',
                  hintText: 'Ej: 2.4',
                  validator: (v) => InputUtils.requiredPositive(
                    v,
                    fieldName: 'Alto del muro',
                    maxValue: AppConstants.maxInputValue,
                  ),
                ),

                const SizedBox(height: 14),
                const Text('Medidas del ladrillo', style: _sectionTitleStyle),
                const SizedBox(height: 8),

                NumberInput(
                  controller: _largoLadrilloCtrl,
                  label: 'Largo del ladrillo',
                  suffix: 'cm',
                  integerOnly: true,
                  hintText: 'Ej: 20',
                  helperText: 'Mide tu ladrillo real si es distinto.',
                  validator: (v) => InputUtils.requiredPositive(
                    v,
                    fieldName: 'Largo del ladrillo',
                    maxValue: 60,
                  ),
                ),

                NumberInput(
                  controller: _altoLadrilloCtrl,
                  label: 'Alto del ladrillo',
                  suffix: 'cm',
                  integerOnly: true,
                  hintText: 'Ej: 7',
                  helperText: 'Altura del ladrillo (sin mortero).',
                  validator: (v) => InputUtils.requiredPositive(
                    v,
                    fieldName: 'Alto del ladrillo',
                    maxValue: 40,
                  ),
                ),

                NumberInput(
                  controller: _juntaMmCtrl,
                  label: 'Junta de mortero',
                  suffix: 'mm',
                  integerOnly: true,
                  hintText: 'Ej: 10',
                  helperText:
                      'Separación típica entre ladrillos. Si no sabes, deja 10 mm.',
                  validator: (v) => InputUtils.requiredPositive(
                    v,
                    fieldName: 'Junta de mortero',
                    maxValue: 30,
                  ),
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  value: _usarMerma10,
                  onChanged: (v) => setState(() => _usarMerma10 = v),
                  title: const Text('Agregar merma 10% (recomendado)'),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calcular,
                        child: const Text('Calcular'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _limpiar,
                        child: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ResultTile(
                  label: 'Ladrillos necesarios (sin merma)',
                  value: _ladrillosSinMerma == 0 ? '-' : '$_ladrillosSinMerma',
                ),

                ResultTile(
                  label: _usarMerma10 ? 'Recomendable comprar' : 'Total',
                  value: _ladrillosConMerma == 0 ? '-' : '$_ladrillosConMerma',
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
