import 'package:flutter/material.dart';

class TabiquePage extends StatefulWidget {
  const TabiquePage({super.key});

  @override
  State<TabiquePage> createState() => _TabiquePageState();
}

class _TabiquePageState extends State<TabiquePage> {
  final _formKey = GlobalKey<FormState>();

  // Inputs
  final _largoCtrl = TextEditingController(text: '3.0');
  final _altoCtrl = TextEditingController(text: '2.4');

  double _separacion = 0.40; // 0.40 o 0.60 típicos
  String _estructura = 'Metalcon'; // o 'Madera'
  bool _dobleExtremos = false; // opcional

  // Resultados (solo estructura)
  int _piesDerechos = 0; // unidades
  double _soleraMl = 0; // metros lineales (superior + inferior)
  double _montanteMl = 0; // metros lineales total de montantes (n * alto)
  double _totalEstructuraMl = 0;

  double _parseDouble(String s) {
    final normalized = s.replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0.0;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final largo = _parseDouble(_largoCtrl.text);
    final alto = _parseDouble(_altoCtrl.text);

    // 1) Pies derechos (montantes):
    // cantidad = ceil(largo / separacion) + 1  (uno al inicio y uno al final)
    var pd = (largo / _separacion).ceil() + 1;

    // opcional: doble montante en extremos (sumamos 2 unidades)
    if (_dobleExtremos) {
      pd += 2;
    }

    // 2) Soleras: superior + inferior => 2 * largo
    final solera = largo * 2;

    // 3) Metros lineales de montante total
    final montanteMl = pd * alto;

    // 4) Total ML estructura
    final totalMl = solera + montanteMl;

    setState(() {
      _piesDerechos = pd;
      _soleraMl = solera;
      _montanteMl = montanteMl;
      _totalEstructuraMl = totalMl;
    });
  }

  @override
  void dispose() {
    _largoCtrl.dispose();
    _altoCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabiques (Estructura)'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Datos del tabique',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),

                      // Largo / Alto
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _largoCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: _dec('Largo (m)', hint: 'Ej: 3.0'),
                              validator: (v) {
                                final n = _parseDouble(v ?? '');
                                if (n <= 0) return 'Ingresa un largo válido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _altoCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: _dec('Alto (m)', hint: 'Ej: 2.4'),
                              validator: (v) {
                                final n = _parseDouble(v ?? '');
                                if (n <= 0) return 'Ingresa un alto válido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Estructura
                      DropdownButtonFormField<String>(
                        value: _estructura,
                        decoration: _dec('Estructura'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Metalcon', child: Text('Metalcon')),
                          DropdownMenuItem(
                              value: 'Madera', child: Text('Madera')),
                        ],
                        onChanged: (v) =>
                            setState(() => _estructura = v ?? 'Metalcon'),
                      ),
                      const SizedBox(height: 12),

                      // Separación
                      DropdownButtonFormField<double>(
                        value: _separacion,
                        decoration: _dec('Separación pies derechos'),
                        items: const [
                          DropdownMenuItem(value: 0.40, child: Text('40 cm')),
                          DropdownMenuItem(value: 0.60, child: Text('60 cm')),
                        ],
                        onChanged: (v) =>
                            setState(() => _separacion = v ?? 0.40),
                      ),
                      const SizedBox(height: 12),

                      // Doble extremos (opcional)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title:
                            const Text('Doble montante en extremos (opcional)'),
                        value: _dobleExtremos,
                        onChanged: (v) => setState(() => _dobleExtremos = v),
                      ),

                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _calcular,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Calcular'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Resultados (solo estructura)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _resultRow('Estructura', _estructura),
                    _resultRow(
                      'Pies derechos (unidades)',
                      _piesDerechos == 0 ? '—' : '$_piesDerechos',
                    ),
                    _resultRow(
                      'Soleras (ml)',
                      _soleraMl == 0 ? '—' : _soleraMl.toStringAsFixed(2),
                    ),
                    _resultRow(
                      'Montantes total (ml)',
                      _montanteMl == 0 ? '—' : _montanteMl.toStringAsFixed(2),
                    ),
                    _resultRow(
                      'Total estructura (ml)',
                      _totalEstructuraMl == 0
                          ? '—'
                          : _totalEstructuraMl.toStringAsFixed(2),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Nota: aquí NO se considera revestimiento (volcanita/OSB), ni tornillos/cinta/pasta, '
                      'ni descuentos por puertas/ventanas. Luego podemos agregar esos extras como opción.',
                      style: TextStyle(color: Colors.black.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
