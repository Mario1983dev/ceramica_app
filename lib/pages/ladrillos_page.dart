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

  // Ladrillo (cm)
  final _largoLadrilloCtrl = TextEditingController();
  final _altoLadrilloCtrl = TextEditingController();

  // Junta mortero (mm)
  final _juntaMmCtrl = TextEditingController(text: '10');

  bool _usarMerma10 = true;

  // Resultados
  double _areaMuro = 0;
  int _ladrillosSinMerma = 0;
  int _ladrillosConMerma = 0;

  @override
  void dispose() {
    _largoMuroCtrl.dispose();
    _altoMuroCtrl.dispose();
    _largoLadrilloCtrl.dispose();
    _altoLadrilloCtrl.dispose();
    _juntaMmCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() {
        _areaMuro = 0;
        _ladrillosSinMerma = 0;
        _ladrillosConMerma = 0;
      });
      return;
    }
    final largoMuro = InputUtils.toDouble(_largoMuroCtrl.text);
    final altoMuro = InputUtils.toDouble(_altoMuroCtrl.text);

    final largoLadrilloCm = InputUtils.toDouble(_largoLadrilloCtrl.text);
    final altoLadrilloCm = InputUtils.toDouble(_altoLadrilloCtrl.text);

    final juntaMm = InputUtils.toDouble(_juntaMmCtrl.text);

    // Área del muro
    final areaMuro = largoMuro * altoMuro;

    // Convertimos ladrillo a metros y sumamos la junta (mortero)
    // cm -> m : /100
    // mm -> m : /1000
    final juntaM = juntaMm / 1000.0;
    final largoModulo = (largoLadrilloCm / 100.0) + juntaM;
    final altoModulo = (altoLadrilloCm / 100.0) + juntaM;

    // Área "ocupada" por cada ladrillo + junta
    final areaPorLadrillo = largoModulo * altoModulo;

    final ladrillosBase = areaMuro / areaPorLadrillo;
    final sinMerma = ladrillosBase.isFinite ? ladrillosBase.ceil() : 0;

    final merma = _usarMerma10 ? 0.10 : 0.0;
    final conMerma = ((areaMuro * (1 + merma)) / areaPorLadrillo).ceil();

    setState(() {
      _areaMuro = areaMuro;
      _ladrillosSinMerma = max(0, sinMerma);
      _ladrillosConMerma = max(0, conMerma);
    });
  }

  void _limpiar() {
    _formKey.currentState?.reset();

    _largoMuroCtrl.clear();
    _altoMuroCtrl.clear();
    _largoLadrilloCtrl.clear();
    _altoLadrilloCtrl.clear();
    _juntaMmCtrl.text = '10';

    setState(() {
      _usarMerma10 = true;
      _areaMuro = 0;
      _ladrillosSinMerma = 0;
      _ladrillosConMerma = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ladrillos pared'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Calcula ladrillos necesarios (incluye junta/mortero y merma)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Muro
                        const Text('Muro',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        if (isNarrow) ...[
                          NumberInput(
                            controller: _largoMuroCtrl,
                            label: 'Largo muro',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Largo muro',
                              maxValue: 2000,
                            ),
                          ),
                          NumberInput(
                            controller: _altoMuroCtrl,
                            label: 'Alto muro',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Alto muro',
                              maxValue: 2000,
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NumberInput(
                                  controller: _largoMuroCtrl,
                                  label: 'Largo muro',
                                  suffix: 'm',
                                  validator: (v) =>
                                      InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Largo muro',
                                    maxValue: 2000,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NumberInput(
                                  controller: _altoMuroCtrl,
                                  label: 'Alto muro',
                                  suffix: 'm',
                                  validator: (v) =>
                                      InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Alto muro',
                                    maxValue: 2000,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Ladrillo
                        const Text('Ladrillo',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        if (isNarrow) ...[
                          NumberInput(
                            controller: _largoLadrilloCtrl,
                            label: 'Largo ladrillo',
                            suffix: 'cm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Largo ladrillo',
                              maxValue: 1000,
                            ),
                          ),
                          NumberInput(
                            controller: _altoLadrilloCtrl,
                            label: 'Alto ladrillo',
                            suffix: 'cm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Alto ladrillo',
                              maxValue: 1000,
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NumberInput(
                                  controller: _largoLadrilloCtrl,
                                  label: 'Largo ladrillo',
                                  suffix: 'cm',
                                  validator: (v) =>
                                      InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Largo ladrillo',
                                    maxValue: 1000,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NumberInput(
                                  controller: _altoLadrilloCtrl,
                                  label: 'Alto ladrillo',
                                  suffix: 'cm',
                                  validator: (v) =>
                                      InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Alto ladrillo',
                                    maxValue: 1000,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Junta
                        NumberInput(
                          controller: _juntaMmCtrl,
                          label: 'Junta mortero',
                          suffix: 'mm',
                          validator: (v) {
                            final raw = (v ?? '').trim();
                            if (raw.isEmpty) return 'Junta mortero es obligatorio';

                            final n = InputUtils.toDouble(raw);
                            if (n <= 0) {
                              return '⚠️ Junta debe ser mayor a 0 (ej: 10 mm)';
                            }
                            if (n > 30) {
                              return '⚠️ Junta muy grande (ej: 10 mm aprox)';
                            }
                            return null;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 12),
                          child: Text(
                            'Ej: 10 mm (puedes cambiarlo)',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),

                        // Merma
                        SwitchListTile(
                          value: _usarMerma10,
                          onChanged: (v) => setState(() => _usarMerma10 = v),
                          title: const Text('Agregar merma 10% (recomendado)'),
                        ),

                        const SizedBox(height: 14),

                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _calcular,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calcular'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _limpiar,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Limpiar'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Resultados (✅ usando ResultTile)
                        ResultTile(
                          label: 'Área muro (m²)',
                          value: _areaMuro == 0 ? '-' : _areaMuro.toStringAsFixed(2),
                        ),
                        ResultTile(
                          label: 'Ladrillos sin merma',
                          value: _ladrillosSinMerma == 0 ? '-' : '$_ladrillosSinMerma',
                        ),
                        ResultTile(
                          label: _usarMerma10
                              ? 'Recomendable comprar (con merma 10%)'
                              : 'Ladrillos con merma',
                          value: _ladrillosConMerma == 0 ? '-' : '$_ladrillosConMerma',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
