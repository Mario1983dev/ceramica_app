import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart'; // para usar primaryBlue

class CeramicaPage extends StatefulWidget {
  const CeramicaPage({super.key});

  @override
  State<CeramicaPage> createState() => _CeramicaPageState();
}

class _CeramicaPageState extends State<CeramicaPage> {
  final _formKey = GlobalKey<FormState>();

  // Medidas del área
  final _largoCtrl = TextEditingController();
  final _anchoCtrl = TextEditingController();

  // Caja (m2 por caja)
  final _m2CajaCtrl = TextEditingController();

  // Merma
  bool _usarMerma10 = true;

  // Resultados
  double _area = 0;
  int _cajasSinMerma = 0;
  int _cajasConMerma = 0;

  // Helpers
  double _parseNum(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  @override
  void dispose() {
    _largoCtrl.dispose();
    _anchoCtrl.dispose();
    _m2CajaCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final largo = _parseNum(_largoCtrl.text);
    final ancho = _parseNum(_anchoCtrl.text);
    final m2Caja = _parseNum(_m2CajaCtrl.text);

    final area = largo * ancho;
    final cajasBase = (area / m2Caja);

    final cajasSinMerma = cajasBase.isFinite ? cajasBase.ceil() : 0;

    final merma = _usarMerma10 ? 0.10 : 0.0;
    final cajasConMerma = ((area * (1 + merma)) / m2Caja).ceil();

    setState(() {
      _area = area;
      _cajasSinMerma = max(0, cajasSinMerma);
      _cajasConMerma = max(0, cajasConMerma);
    });
  }

  void _limpiar() {
    _largoCtrl.clear();
    _anchoCtrl.clear();
    _m2CajaCtrl.clear();
    setState(() {
      _area = 0;
      _cajasSinMerma = 0;
      _cajasConMerma = 0;
      _usarMerma10 = true;
    });
  }

  String? _validaMayorCero(String? v, String nombre) {
    final n = _parseNum(v ?? '');
    if (n <= 0) return '⚠️ $nombre debe ser mayor a 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerámica'),
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
                          'Calcula cajas necesarias (con merma opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Largo / Ancho
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _largoCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Largo (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Largo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _anchoCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Ancho (m)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _validaMayorCero(v, 'Ancho'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // m2 por caja
                        TextFormField(
                          controller: _m2CajaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'm² por caja',
                            helperText: 'Ej: 1.44 (depende del formato de cerámica)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => _validaMayorCero(v, 'm² por caja'),
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
                        _ResultadoTile(label: 'Área (m²)', value: _area == 0 ? '-' : _area.toStringAsFixed(2)),
                        _ResultadoTile(label: 'Cajas sin merma', value: _cajasSinMerma == 0 ? '-' : '$_cajasSinMerma'),
                        _ResultadoTile(
                          label: _usarMerma10 ? 'Recomendable comprar (con merma 10%)' : 'Cajas con merma',
                          value: _cajasConMerma == 0 ? '-' : '$_cajasConMerma',
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
