import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/input_utils.dart';
import '../widgets/number_input.dart';
import '../widgets/result_tile.dart';

class PinturaPage extends StatefulWidget {
  const PinturaPage({super.key});

  @override
  State<PinturaPage> createState() => _PinturaPageState();
}

class _PinturaPageState extends State<PinturaPage> {
  final _formKey = GlobalKey<FormState>();

  final largoCtrl = TextEditingController();
  final altoCtrl = TextEditingController();
  final manosCtrl = TextEditingController(text: '2');
  final rendimientoCtrl = TextEditingController(text: '35');

  bool usarMerma = true;

  double? area;
  double? areaTotal;
  int? galones;

  void _calcular() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() {
        area = null;
        areaTotal = null;
        galones = null;
      });
      return;
    }

    final largo = InputUtils.toDouble(largoCtrl.text);
    final alto = InputUtils.toDouble(altoCtrl.text);
    final manos = InputUtils.toDouble(manosCtrl.text);
    final rendimiento = InputUtils.toDouble(rendimientoCtrl.text);

    final a = largo * alto;
    final aTotal = a * manos;

    final aConMerma = usarMerma ? aTotal * 1.10 : aTotal;
    final galonesExactos = aConMerma / rendimiento;

    final g = galonesExactos.isFinite ? galonesExactos.ceil() : 0;

    setState(() {
      area = a;
      areaTotal = aTotal;
      galones = g;
    });
  }

  void _limpiar() {
    _formKey.currentState?.reset();

    largoCtrl.clear();
    altoCtrl.clear();
    manosCtrl.text = '2';
    rendimientoCtrl.text = '35';

    setState(() {
      usarMerma = true;
      area = null;
      areaTotal = null;
      galones = null;
    });
  }

  @override
  void dispose() {
    largoCtrl.dispose();
    altoCtrl.dispose();
    manosCtrl.dispose();
    rendimientoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pintura'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Calcula cuántos galones necesitas para pintar una pared.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 14),

            if (isNarrow) ...[
              NumberInput(
                controller: largoCtrl,
                label: 'Largo de la pared',
                suffix: 'm',
                hintText: 'Ej: 4',
                validator: (v) => InputUtils.requiredPositive(
                  v,
                  fieldName: 'Largo',
                  maxValue: 2000,
                ),
              ),
              NumberInput(
                controller: altoCtrl,
                label: 'Alto de la pared',
                suffix: 'm',
                hintText: 'Ej: 2,4',
                validator: (v) => InputUtils.requiredPositive(
                  v,
                  fieldName: 'Alto',
                  maxValue: 2000,
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NumberInput(
                      controller: largoCtrl,
                      label: 'Largo de la pared',
                      suffix: 'm',
                      hintText: 'Ej: 4',
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
                      controller: altoCtrl,
                      label: 'Alto de la pared',
                      suffix: 'm',
                      hintText: 'Ej: 2,4',
                      validator: (v) => InputUtils.requiredPositive(
                        v,
                        fieldName: 'Alto',
                        maxValue: 2000,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            NumberInput(
              controller: manosCtrl,
              label: 'N° de manos (capas)',
              hintText: 'Ej: 2',
              helperText: 'Si das 2 manos, la pintura se calcula para 2 capas.',
              validator: (v) => InputUtils.requiredPositive(
                v,
                fieldName: 'N° de manos',
                maxValue: 10,
              ),
              decimalRange: 1,
            ),

            NumberInput(
              controller: rendimientoCtrl,
              label: 'Rendimiento de la pintura',
              suffix: 'm²/galón',
              hintText: 'Ej: 35',
              helperText:
                  'Míralo en el tarro (por ejemplo: 35 m² por galón, depende de la marca).',
              validator: (v) => InputUtils.requiredPositive(
                v,
                fieldName: 'Rendimiento',
                maxValue: 1000,
              ),
              decimalRange: 1,
            ),

            const SizedBox(height: 6),

            SwitchListTile(
              title: const Text('Agregar merma 10% (recomendado)'),
              subtitle: const Text('Para pérdidas, retoques y absorción del muro.'),
              value: usarMerma,
              onChanged: (v) => setState(() => usarMerma = v),
            ),

            const SizedBox(height: 10),

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

            ResultTile(
              label: 'Área (m²)',
              value: area == null ? '-' : area!.toStringAsFixed(2),
            ),
            ResultTile(
              label: 'Área total (m²)',
              value: areaTotal == null ? '-' : areaTotal!.toStringAsFixed(2),
            ),
            ResultTile(
              label: 'Galones necesarios',
              value: galones == null ? '-' : '$galones',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
