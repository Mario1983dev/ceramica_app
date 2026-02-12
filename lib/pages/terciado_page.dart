import 'dart:math';
import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/input_utils.dart';
import '../widgets/number_input.dart';
import '../widgets/result_tile.dart';

class TerciadoPage extends StatefulWidget {
  const TerciadoPage({super.key});

  @override
  State<TerciadoPage> createState() => _TerciadoPageState();
}

class _TerciadoPageState extends State<TerciadoPage> {
  final _formKey = GlobalKey<FormState>();

  // Área a cubrir (m)
  final _largoCtrl = TextEditingController();
  final _anchoCtrl = TextEditingController();

  // Plancha (m) - por defecto estándar 2.44 x 1.22
  final _largoPlanchaCtrl = TextEditingController(text: '2.44');
  final _anchoPlanchaCtrl = TextEditingController(text: '1.22');

  bool _usarMerma10 = true;

  // Resultados
  double _area = 0;
  double _areaPlancha = 0;
  int _planchasSinMerma = 0;
  int _planchasConMerma = 0;

  @override
  void dispose() {
    _largoCtrl.dispose();
    _anchoCtrl.dispose();
    _largoPlanchaCtrl.dispose();
    _anchoPlanchaCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() {
        _area = 0;
        _areaPlancha = 0;
        _planchasSinMerma = 0;
        _planchasConMerma = 0;
      });
      return;
    }
    final largo = InputUtils.toDouble(_largoCtrl.text);
    final ancho = InputUtils.toDouble(_anchoCtrl.text);

    final largoP = InputUtils.toDouble(_largoPlanchaCtrl.text);
    final anchoP = InputUtils.toDouble(_anchoPlanchaCtrl.text);

    final area = largo * ancho;
    final areaPlancha = largoP * anchoP;

    final base = area / areaPlancha;
    final sinMerma = base.isFinite ? base.ceil() : 0;

    final merma = _usarMerma10 ? 0.10 : 0.0;
    final conMerma = ((area * (1 + merma)) / areaPlancha).ceil();

    setState(() {
      _area = area;
      _areaPlancha = areaPlancha;
      _planchasSinMerma = max(0, sinMerma);
      _planchasConMerma = max(0, conMerma);
    });
  }

  void _limpiar() {
    _formKey.currentState?.reset();

    _largoCtrl.clear();
    _anchoCtrl.clear();
    _largoPlanchaCtrl.text = '2.44';
    _anchoPlanchaCtrl.text = '1.22';

    setState(() {
      _usarMerma10 = true;
      _area = 0;
      _areaPlancha = 0;
      _planchasSinMerma = 0;
      _planchasConMerma = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terciado ranurado'),
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
                          'Calcula planchas necesarias (con merma opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Área a cubrir
                        const Text('Área a cubrir',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        if (isNarrow) ...[
                          NumberInput(
                            controller: _largoCtrl,
                            label: 'Largo',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Largo',
                              maxValue: 2000,
                            ),
                          ),
                          NumberInput(
                            controller: _anchoCtrl,
                            label: 'Ancho',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Ancho',
                              maxValue: 2000,
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NumberInput(
                                  controller: _largoCtrl,
                                  label: 'Largo',
                                  suffix: 'm',
                                  validator: (v) => InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Largo',
                                    maxValue: 2000,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NumberInput(
                                  controller: _anchoCtrl,
                                  label: 'Ancho',
                                  suffix: 'm',
                                  validator: (v) => InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Ancho',
                                    maxValue: 2000,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Plancha
                        const Text('Medidas de la plancha',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        if (isNarrow) ...[
                          NumberInput(
                            controller: _largoPlanchaCtrl,
                            label: 'Largo plancha',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Largo plancha',
                              maxValue: 10,
                            ),
                          ),
                          NumberInput(
                            controller: _anchoPlanchaCtrl,
                            label: 'Ancho plancha',
                            suffix: 'm',
                            validator: (v) => InputUtils.requiredPositive(
                              v,
                              fieldName: 'Ancho plancha',
                              maxValue: 10,
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NumberInput(
                                  controller: _largoPlanchaCtrl,
                                  label: 'Largo plancha',
                                  suffix: 'm',
                                  validator: (v) => InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Largo plancha',
                                    maxValue: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NumberInput(
                                  controller: _anchoPlanchaCtrl,
                                  label: 'Ancho plancha',
                                  suffix: 'm',
                                  validator: (v) => InputUtils.requiredPositive(
                                    v,
                                    fieldName: 'Ancho plancha',
                                    maxValue: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

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
                          label: 'Área total (m²)',
                          value: _area == 0 ? '-' : _area.toStringAsFixed(2),
                        ),
                        ResultTile(
                          label: 'Área por plancha (m²)',
                          value: _areaPlancha == 0
                              ? '-'
                              : _areaPlancha.toStringAsFixed(2),
                        ),
                        ResultTile(
                          label: 'Planchas sin merma',
                          value: _planchasSinMerma == 0
                              ? '-'
                              : '$_planchasSinMerma',
                        ),
                        ResultTile(
                          label: _usarMerma10
                              ? 'Recomendable comprar (con merma 10%)'
                              : 'Planchas con merma',
                          value: _planchasConMerma == 0
                              ? '-'
                              : '$_planchasConMerma',
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
