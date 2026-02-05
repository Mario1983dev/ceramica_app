import 'package:flutter/material.dart';

class PinturaPage extends StatefulWidget {
  const PinturaPage({super.key});

  @override
  State<PinturaPage> createState() => _PinturaPageState();
}

class _PinturaPageState extends State<PinturaPage> {
  final largoCtrl = TextEditingController();
  final altoCtrl = TextEditingController();
  final manosCtrl = TextEditingController(text: "2");
  final rendimientoCtrl = TextEditingController(text: "35");

  bool usarMerma = true;

  double area = 0;
  double areaTotal = 0;
  int galones = 0;

  double _num(String s) =>
      double.tryParse(s.replaceAll(',', '.')) ?? 0;

  void calcular() {
    final largo = _num(largoCtrl.text);
    final alto = _num(altoCtrl.text);
    final manos = _num(manosCtrl.text);
    final rendimiento = _num(rendimientoCtrl.text);

    if (largo <= 0 ||
        alto <= 0 ||
        manos <= 0 ||
        rendimiento <= 0) {
      return;
    }

    area = largo * alto;
    areaTotal = area * manos;

    double areaConMerma =
        usarMerma ? areaTotal * 1.10 : areaTotal;

    double galonesExactos =
        areaConMerma / rendimiento;

    // ✅ Siempre entero
    galones = galonesExactos.ceil();

    setState(() {});
  }

  void limpiar() {
    largoCtrl.clear();
    altoCtrl.clear();
    manosCtrl.text = "2";
    rendimientoCtrl.text = "35";

    area = 0;
    areaTotal = 0;
    galones = 0;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pintura")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Calcula galones necesarios",
                      style: TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: largoCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Largo pared (m)"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: altoCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Alto pared (m)"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: manosCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "N° de manos"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: rendimientoCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                          labelText:
                              "Rendimiento m² por galón"),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text(
                          "Agregar merma 10%"),
                      value: usarMerma,
                      onChanged: (v) =>
                          setState(() => usarMerma = v),
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

                    _resultado(
                        "Área pared",
                        "${area.toStringAsFixed(2)} m²"),
                    _resultado(
                        "Área total",
                        "${areaTotal.toStringAsFixed(2)} m²"),
                    _resultado(
                        "Galones necesarios",
                        galones.toString()),
                  ],
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
      margin: const EdgeInsets.symmetric(
          vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
