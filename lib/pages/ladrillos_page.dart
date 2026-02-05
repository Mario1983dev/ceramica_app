import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart'; // primaryBlue

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

  double _parseNum(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  String? _validaMayorCero(String? v, String nombre) {
    final n = _parseNum(v ?? '');
    if (n <= 0) return '⚠️ $nombre debe ser mayor a 0';
    return null;
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

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final largoMuro = _parseNum(_largoMuroCtrl.text);
    final altoMuro = _parseNum(_altoMuroCtrl.text);

    final largoLadrilloCm = _parseNum(_largoLadrilloCtrl.text);
    final altoLadrilloCm = _parseNum(_altoLadrilloCtrl.text);

    final juntaMm = _parseNum(_juntaMmCtrl.text);
    if (juntaMm < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ La junta (mm) no puede ser negativa')),
      );
      return;
    }

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

    if (areaPorLadrillo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Revisa medidas del ladrillo/junta')),
      );
      return;
    }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ladrillos pared'),
        backgroundColor: primaryBlue,
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
                          'Calcula ladrillos necesarios (incluye junta/mortero y merma)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),

                        // Muro
                        const Text('Muro', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _largoMuroCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Largo muro (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Largo muro'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _altoMuroCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Alto muro (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Alto muro'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Ladrillo
                        const Text('Ladrillo', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _largoLadrilloCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Largo ladrillo (cm)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Largo ladrillo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _altoLadrilloCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Alto ladrillo (cm)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Alto ladrillo'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Junta
                        TextFormField(
                          controller: _juntaMmCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Junta mortero (mm)',
                            helperText: 'Ej: 10 mm (puedes cambiarlo)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final n = _parseNum(v ?? '');
                            if (n < 0) return '⚠️ Junta no puede ser negativa';
                            if (n == 0) return '⚠️ Junta no puede ser 0 (usa 10 mm aprox)';
                            return null;
                          },
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
                          label: 'Área muro (m²)',
                          value: _areaMuro == 0 ? '-' : _areaMuro.toStringAsFixed(2),
                        ),
                        _ResultadoTile(
                          label: 'Ladrillos sin merma',
                          value: _ladrillosSinMerma == 0 ? '-' : '$_ladrillosSinMerma',
                        ),
                        _ResultadoTile(
                          label: _usarMerma10 ? 'Recomendable comprar (con merma 10%)' : 'Ladrillos con merma',
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
