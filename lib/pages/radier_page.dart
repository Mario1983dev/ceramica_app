import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ceramica_app/core/input_utils.dart';

int _ceilToInt(double x) => x.isNaN || x.isInfinite ? 0 : x.ceil();

class RadierPage extends StatefulWidget {
  const RadierPage({super.key});

  @override
  State<RadierPage> createState() => _RadierPageState();
}

class _RadierPageState extends State<RadierPage> {
  final _formKey = GlobalKey<FormState>();

  final _largoCtrl = TextEditingController();
  final _anchoCtrl = TextEditingController();

  int _espesorCm = 10;
  int _cementoKgPorM3 = 300;
  double _pesoSacoKg = 25.0;

  double? _areaM2;
  double? _volumenM3;
  double? _cementoKg;
  int? _sacos;

  void _limpiar() {
    _formKey.currentState?.reset();
    _largoCtrl.clear();
    _anchoCtrl.clear();

    setState(() {
      _espesorCm = 10;
      _cementoKgPorM3 = 300;
      _pesoSacoKg = 25.0;
      _areaM2 = null;
      _volumenM3 = null;
      _cementoKg = null;
      _sacos = null;
    });
  }

  void _calcular() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final largo = InputUtils.toDouble(_largoCtrl.text);
    final ancho = InputUtils.toDouble(_anchoCtrl.text);
    final espesorM = _espesorCm / 100.0;

    final area = largo * ancho;
    final volumen = area * espesorM;

    final cementoKg = volumen * _cementoKgPorM3;
    final sacos = _ceilToInt(cementoKg / _pesoSacoKg);

    setState(() {
      _areaM2 = area;
      _volumenM3 = volumen;
      _cementoKg = cementoKg;
      _sacos = sacos;
    });
  }

  String _tituloUso(int kgPorM3) {
    if (kgPorM3 == 250) return 'Uso liviano';
    if (kgPorM3 == 300) return 'Uso normal (recomendado)';
    return 'Alta resistencia';
  }

  List<String> _bulletsUso(int kgPorM3) {
    if (kgPorM3 == 250) {
      return [
        'Patios y terrazas',
        'Solo tránsito peatonal',
        'Bodegas livianas',
        'No recomendado para autos',
      ];
    }

    if (kgPorM3 == 300) {
      return [
        'Uso doméstico general',
        'Patios y vivienda',
        'Entrada de autos livianos',
        'Buena relación costo/resistencia',
      ];
    }

    return [
      'Tránsito frecuente de vehículos',
      'Camionetas o cargas pesadas',
      'Estacionamientos exigentes',
      'Mayor duración',
    ];
  }

  String _notaEspesor(int espesor) {
    if (espesor == 10) {
      return 'Adecuado para patios y uso doméstico.';
    }
    if (espesor == 15) {
      return 'Recomendado para entrada de autos.';
    }
    return 'Mayor firmeza para cargas altas.';
  }

  Widget _bullet(String text) {
    final advertencia = text.toLowerCase().startsWith('no recomendado');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(advertencia ? '⚠️ ' : '✅ '),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: advertencia ? Colors.red[700] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _largoCtrl.dispose();
    _anchoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderRadius: BorderRadius.circular(14));

    return Scaffold(
      appBar: AppBar(title: const Text('Radier (Cemento)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Ingresa las dimensiones del radier.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _largoCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Largo (m)',
                      border: inputBorder,
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Ancho (m)',
                      border: inputBorder,
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

            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Espesor del radier',
                border: inputBorder,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _espesorCm,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 10, child: Text('10 cm (patio/casa)')),
                    DropdownMenuItem(
                        value: 15, child: Text('15 cm (autos livianos)')),
                    DropdownMenuItem(
                        value: 20, child: Text('20 cm (alta carga)')),
                  ],
                  onChanged: (v) => setState(() => _espesorCm = v ?? 10),
                ),
              ),
            ),

            const SizedBox(height: 14),

            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Resistencia del hormigón (cemento por m³)',
                border: inputBorder,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _cementoKgPorM3,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 250, child: Text('Liviano – 250 kg/m³')),
                    DropdownMenuItem(
                        value: 300,
                        child: Text('Normal – 300 kg/m³ (recomendado)')),
                    DropdownMenuItem(
                        value: 350, child: Text('Alta – 350 kg/m³')),
                  ],
                  onChanged: (v) => setState(() => _cementoKgPorM3 = v ?? 300),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tituloUso(_cementoKgPorM3),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._bulletsUso(_cementoKgPorM3).map(_bullet),
                    const SizedBox(height: 6),
                    Text(
                      _notaEspesor(_espesorCm),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

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
                OutlinedButton.icon(
                  onPressed: _limpiar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpiar'),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (_volumenM3 != null)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Área: ${_areaM2!.toStringAsFixed(2)} m²'),
                      Text('Volumen: ${_volumenM3!.toStringAsFixed(3)} m³'),
                      Text('Cemento: ${_cementoKg!.toStringAsFixed(1)} kg'),
                      const SizedBox(height: 6),
                      Text(
                        'Sacos necesarios: $_sacos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
