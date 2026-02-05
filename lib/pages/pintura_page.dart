import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  double _num(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String? _validaPositivo(String? value, String nombre) {
    final txt = (value ?? '').trim();
    if (txt.isEmpty) return 'Ingresa $nombre';
    final n = _num(txt);
    if (n <= 0) return '$nombre debe ser mayor a 0';
    return null;
  }

  void calcular() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      _snack('⚠️ Revisa los campos antes de calcular.');
      return;
    }

    final largo = _num(largoCtrl.text);
    final alto = _num(altoCtrl.text);
    final manos = _num(manosCtrl.text);
    final rendimiento = _num(rendimientoCtrl.text);

    area = largo * alto;
    areaTotal = area * manos;

    final areaConMerma = usarMerma ? areaTotal * 1.10 : areaTotal;
    final galonesExactos = areaConMerma / rendimiento;

    // ✅ Siempre entero
    galones = galonesExactos.ceil();

    setState(() {});
  }

  void limpiar() {
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

                      TextFormField(
                        controller: largoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => _validaPositivo(v, "Largo"),
                        decoration: const InputDecoration(
                          labelText: "Largo pared (m)",
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: altoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => _validaPositivo(v, "Alto"),
                        decoration: const InputDecoration(
                          labelText: "Alto pared (m)",
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: manosCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => _validaPositivo(v, "N° de manos"),
                        decoration: const InputDecoration(
                          labelText: "N° de manos",
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: rendimientoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => _validaPositivo(v, "Rendimiento"),
                        decoration: const InputDecoration(
                          labelText: "Rendimiento m² por galón",
                        ),
                      ),
                      const SizedBox(height: 16),

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

                      _resultado("Área pared", "${area.toStringAsFixed(2)} m²"),
                      _resultado("Área total", "${areaTotal.toStringAsFixed(2)} m²"),
                      _resultado("Galones necesarios", galones.toString()),
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
