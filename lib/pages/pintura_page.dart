import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/input_utils.dart';
import '../widgets/number_input.dart';

class PinturaPage extends StatefulWidget {
  const PinturaPage({super.key});

  @override
  State<PinturaPage> createState() => _PinturaPageState();
}

class _PinturaPageState extends State<PinturaPage> {
  final _formKey = GlobalKey<FormState>();

  final largoCtrl = TextEditingController();
  final altoCtrl = TextEditingController();
  final manosCtrl = TextEditingController(text: "2");
  final rendimientoCtrl = TextEditingController(text: "35");

  bool usarMerma = true;

  double area = 0;
  double areaTotal = 0;
  int galones = 0;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void calcular() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      _snack('⚠️ Revisa los campos antes de calcular.');
      return;
    }

    final largo = InputUtils.toDouble(largoCtrl.text);
    final alto = InputUtils.toDouble(altoCtrl.text);

    // manos y rendimiento pueden llevar decimales (por si alguien pone 2.5, etc.)
    final manos = InputUtils.toDouble(manosCtrl.text);
    final rendimiento = InputUtils.toDouble(rendimientoCtrl.text);

    area = largo * alto;
    areaTotal = area * manos;

    final areaConMerma = usarMerma ? areaTotal * 1.10 : areaTotal;
    final galonesExactos = areaConMerma / rendimiento;

    // ✅ Siempre entero hacia arriba
    galones = galonesExactos.isFinite ? galonesExactos.ceil() : 0;

    setState(() {});
  }

  void limpiar() {
    _formKey.currentState?.reset();

    largoCtrl.clear();
    altoCtrl.clear();
    manosCtrl.text = "2";
    rendimientoCtrl.text = "35";

    usarMerma = true;

    area = 0;
    areaTotal = 0;
    galones = 0;

    setState(() {});
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
        title: const Text("Pintura"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Calcula galones necesarios",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (isNarrow) ...[
                        NumberInput(
                          controller: largoCtrl,
                          label: "Largo pared",
                          suffix: "m",
                          validator: (v) => InputUtils.requiredPositive(
                            v,
                            fieldName: "Largo",
                            maxValue: 2000,
                          ),
                        ),
                        NumberInput(
                          controller: altoCtrl,
                          label: "Alto pared",
                          suffix: "m",
                          validator: (v) => InputUtils.requiredPositive(
                            v,
                            fieldName: "Alto",
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
                                label: "Largo pared",
                                suffix: "m",
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: "Largo",
                                  maxValue: 2000,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NumberInput(
                                controller: altoCtrl,
                                label: "Alto pared",
                                suffix: "m",
                                validator: (v) => InputUtils.requiredPositive(
                                  v,
                                  fieldName: "Alto",
                                  maxValue: 2000,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      NumberInput(
                        controller: manosCtrl,
                        label: "N° de manos",
                        validator: (v) => InputUtils.requiredPositive(
                          v,
                          fieldName: "N° de manos",
                          maxValue: 100,
                        ),
                      ),

                      NumberInput(
                        controller: rendimientoCtrl,
                        label: "Rendimiento",
                        suffix: "m²/galón",
                        validator: (v) => InputUtils.requiredPositive(
                          v,
                          fieldName: "Rendimiento",
                          maxValue: 1000,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SwitchListTile(
                        title: const Text("Agregar merma 10%"),
                        value: usarMerma,
                        onChanged: (v) => setState(() => usarMerma = v),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: calcular,
                        child: const Text("Calcular"),
                      ),
                      const SizedBox(height: 6),

                      OutlinedButton(
                        onPressed: limpiar,
                        child: const Text("Limpiar"),
                      ),

                      const SizedBox(height: 20),

                      _resultado("Área pared", area == 0 ? "-" : "${area.toStringAsFixed(2)} m²"),
                      _resultado("Área total", areaTotal == 0 ? "-" : "${areaTotal.toStringAsFixed(2)} m²"),
                      _resultado("Galones necesarios", galones == 0 ? "-" : galones.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultado(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
