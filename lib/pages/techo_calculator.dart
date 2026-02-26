import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../widgets/number_input.dart';
import '../widgets/result_tile.dart';

class TechoCalculator extends StatefulWidget {
  const TechoCalculator({super.key});

  @override
  State<TechoCalculator> createState() => _TechoCalculatorState();
}

enum TechoSistema { vigasOmega, cerchasCostaneras }

enum TipoTecho { unaAgua, dosAguas }

class _TechoCalculatorState extends State<TechoCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Sistema seleccionado (combo)
  TechoSistema sistema = TechoSistema.vigasOmega;
  TipoTecho tipoTecho = TipoTecho.unaAgua;

  // Inputs comunes
  final largoCtrl = TextEditingController(text: '6');
  final anchoCtrl = TextEditingController(text: '3');
  final pendienteCtrl = TextEditingController(text: '15'); // %

  // Vigas + Omega
  final sepVigasCtrl = TextEditingController(text: '0.60');
  final sepOmegaCtrl = TextEditingController(text: '0.50');

  // Cerchas + Costaneras
  final sepCerchasCtrl = TextEditingController(text: '0.60');
  final sepCostanerasCtrl = TextEditingController(text: '0.50');

  // Resultados (strings para mostrar con ResultTile)
  final List<Map<String, String>> resultados = [];

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

  @override
  void dispose() {
    largoCtrl.dispose();
    anchoCtrl.dispose();
    pendienteCtrl.dispose();
    sepVigasCtrl.dispose();
    sepOmegaCtrl.dispose();
    sepCerchasCtrl.dispose();
    sepCostanerasCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    // ✅ Valida todos los NumberInput (TextFormField)
    final ok = _formKey.currentState?.validate() ?? true;
    if (!ok) return;

    resultados.clear();

    final largo = _d(largoCtrl);
    final ancho = _d(anchoCtrl);
    final pendientePct = _d(pendienteCtrl);

    // Extra safety (por si acaso)
    if (largo <= 0 || ancho <= 0 || pendientePct < 0) {
      setState(() {
        resultados
            .add({'label': 'Error', 'value': 'Revisa los valores ingresados'});
      });
      return;
    }

    if (sistema == TechoSistema.vigasOmega) {
      _calcVigasOmega(largo, ancho, pendientePct);
    } else {
      _calcCerchasCostaneras(largo, ancho, pendientePct);
    }

    setState(() {});
  }

  int _cantidad(double largo, double sep) {
    if (sep <= 0) return 0;
    return (largo / sep).ceil() + 1;
  }

  double _pendienteReal(double corrida, double pendientePct) {
    final subida = corrida * (pendientePct / 100.0);
    return math.sqrt(corrida * corrida + subida * subida);
  }

  void _calcVigasOmega(double largo, double ancho, double pendientePct) {
    final sepVigas = _d(sepVigasCtrl);
    final sepOmega = _d(sepOmegaCtrl);

    final vigas = _cantidad(largo, sepVigas);

    final corrida = ancho; // 1 agua
    final pendienteReal = _pendienteReal(corrida, pendientePct);

    final lineasOmega = _cantidad(pendienteReal, sepOmega);
    final mlOmega = lineasOmega * largo;

    resultados.add({'label': 'Sistema', 'value': 'Vigas C + Omega'});
    resultados.add({'label': 'Vigas C (u)', 'value': '$vigas'});
    resultados.add({
      'label': 'Largo pendiente (m)',
      'value': pendienteReal.toStringAsFixed(2),
    });
    resultados.add({'label': 'Líneas Omega (u)', 'value': '$lineasOmega'});
    resultados
        .add({'label': 'Omega (ml)', 'value': mlOmega.toStringAsFixed(2)});
  }

  void _calcCerchasCostaneras(double largo, double ancho, double pendientePct) {
    final sepCerchas = _d(sepCerchasCtrl);
    final sepCost = _d(sepCostanerasCtrl);

    final cerchas = _cantidad(largo, sepCerchas);

    final corrida = (tipoTecho == TipoTecho.dosAguas) ? (ancho / 2) : ancho;
    final pendienteReal = _pendienteReal(corrida, pendientePct);

    final lineasCost = _cantidad(pendienteReal, sepCost);
    final factor = (tipoTecho == TipoTecho.dosAguas) ? 2 : 1;
    final mlCost = lineasCost * largo * factor;

    resultados.add({'label': 'Sistema', 'value': 'Cerchas + Costaneras'});
    resultados.add({'label': 'Cerchas (u)', 'value': '$cerchas'});
    resultados.add({
      'label': 'Largo pendiente (m)',
      'value': pendienteReal.toStringAsFixed(2),
    });
    resultados.add({'label': 'Líneas Costanera (u)', 'value': '$lineasCost'});
    resultados
        .add({'label': 'Costaneras (ml)', 'value': mlCost.toStringAsFixed(2)});
    if (tipoTecho == TipoTecho.dosAguas) {
      resultados
          .add({'label': 'Cumbrera (ml)', 'value': largo.toStringAsFixed(2)});
    }
  }

  String? _validateGreaterThanZero(String? v,
      {String msg = 'Debe ser mayor que 0'}) {
    final x = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (x == null) return 'Ingrese un número válido';
    if (x <= 0) return msg;
    return null;
  }

  String? _validatePendiente(String? v) {
    final x = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (x == null) return 'Ingrese un número válido';
    if (x < 0) return 'No puede ser negativa';
    return null; // permite 0
  }

  @override
  Widget build(BuildContext context) {
    final isVigas = sistema == TechoSistema.vigasOmega;

    return Scaffold(
      appBar: AppBar(title: const Text('Techo (Solo Esqueleto)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Combo sistema
              DropdownButtonFormField<TechoSistema>(
                value: sistema,
                decoration: const InputDecoration(
                  labelText: 'Sistema estructural',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TechoSistema.vigasOmega,
                    child: Text('Vigas C + Omega (ampliación)'),
                  ),
                  DropdownMenuItem(
                    value: TechoSistema.cerchasCostaneras,
                    child: Text('Cerchas + Costaneras (estructural)'),
                  ),
                ],
                onChanged: (v) => setState(() => sistema = v!),
              ),
              const SizedBox(height: 12),

              // Inputs comunes
              NumberInput(
                label: 'Largo (m)',
                controller: largoCtrl,
                validator: (v) =>
                    _validateGreaterThanZero(v, msg: 'Largo inválido'),
              ),
              const SizedBox(height: 10),
              NumberInput(
                label: 'Ancho (m)',
                controller: anchoCtrl,
                validator: (v) =>
                    _validateGreaterThanZero(v, msg: 'Ancho inválido'),
              ),
              const SizedBox(height: 10),
              NumberInput(
                label: 'Pendiente (%)',
                controller: pendienteCtrl,
                validator: _validatePendiente,
              ),
              const SizedBox(height: 12),

              // Inputs condicionales
              if (isVigas) ...[
                NumberInput(
                  label: 'Separación Vigas C (m)',
                  controller: sepVigasCtrl,
                  validator: (v) => _validateGreaterThanZero(v),
                ),
                const SizedBox(height: 10),
                NumberInput(
                  label: 'Separación Omega (m)',
                  controller: sepOmegaCtrl,
                  validator: (v) => _validateGreaterThanZero(v),
                ),
              ] else ...[
                DropdownButtonFormField<TipoTecho>(
                  value: tipoTecho,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de techo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: TipoTecho.unaAgua, child: Text('1 agua')),
                    DropdownMenuItem(
                        value: TipoTecho.dosAguas, child: Text('2 aguas')),
                  ],
                  onChanged: (v) => setState(() => tipoTecho = v!),
                ),
                const SizedBox(height: 10),
                NumberInput(
                  label: 'Separación Cerchas (m)',
                  controller: sepCerchasCtrl,
                  validator: (v) => _validateGreaterThanZero(v),
                ),
                const SizedBox(height: 10),
                NumberInput(
                  label: 'Separación Costaneras (m)',
                  controller: sepCostanerasCtrl,
                  validator: (v) => _validateGreaterThanZero(v),
                ),
              ],

              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: _calcular,
                child: const Text('Calcular'),
              ),

              const SizedBox(height: 14),

              if (resultados.isNotEmpty) ...[
                const Text(
                  'Resultados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...resultados.map(
                  (r) => ResultTile(
                    label: r['label']!,
                    value: r['value']!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
