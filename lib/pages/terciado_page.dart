import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_constants.dart';
import 'package:ceramica_app/core/input_utils.dart';

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
    if (!ok) return;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terciado ranurado'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),

                        // Área a cubrir
                        const Text('Área a cubrir', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _largoCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  DecimalTextInputFormatter(decimalRange: 2),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Largo (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: 'Largo',
                                  maxValue: 2000,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _anchoCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  DecimalTextInputFormatter(decimalRange: 2),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Ancho (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: 'Ancho',
                                  maxValue: 2000,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Plancha
                        const Text('Medidas de la plancha', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _largoPlanchaCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  DecimalTextInputFormatter(decimalRange: 2),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Largo plancha (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: 'Largo plancha',
                                  maxValue: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _anchoPlanchaCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  DecimalTextInputFormatter(decimalRange: 2),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Ancho plancha (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: 'Ancho plancha',
                                  maxValue: 10,
                                ),
                              ),
                            ),
                          ],
                        ),

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

                        // Resultados
                        _ResultadoTile(
                          label: 'Área total (m²)',
                          value: _area == 0 ? '-' : _area.toStringAsFixed(2),
                        ),
                        _ResultadoTile(
                          label: 'Área por plancha (m²)',
                          value: _areaPlancha == 0 ? '-' : _areaPlancha.toStringAsFixed(2),
                        ),
                        _ResultadoTile(
                          label: 'Planchas sin merma',
                          value: _planchasSinMerma == 0 ? '-' : '$_planchasSinMerma',
                        ),
                        _ResultadoTile(
                          label: _usarMerma10
                              ? 'Recomendable comprar (con merma 10%)'
                              : 'Planchas con merma',
                          value: _planchasConMerma == 0 ? '-' : '$_planchasConMerma',
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

class _ResultadoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ResultadoTile({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
