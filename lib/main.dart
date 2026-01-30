import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const Color primaryBlue = Color(0xFF0D47A1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoluSoft',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      ),
      home: const HomePage(),
    );
  }
}

/* ===========================================================
   HOME (Selector)
=========================================================== */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String logoPath = 'assets/images/logo-solusoft.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoluSoft'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 750;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                logoPath,
                                height: 90,
                                fit: BoxFit.contain,
                                errorBuilder: (context, _, __) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Logo no encontrado.\nRevisa assets/images/logo-solusoft.jpg',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Calculadoras SoluSoft',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Elige qué deseas calcular',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _HomeCard(
                            isMobile: isMobile,
                            title: 'Calcular cerámica',
                            subtitle: 'Cajas necesarias + merma',
                            icon: Icons.grid_on_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CeramicaPage()),
                              );
                            },
                          ),
                          _HomeCard(
                            isMobile: isMobile,
                            title: 'Calcular pintura',
                            subtitle: 'Galones necesarios',
                            icon: Icons.format_paint_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PinturaPage()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '© 2025 SoluSoft SPA',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final bool isMobile;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCard({
    required this.isMobile,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = isMobile ? double.infinity : 470.0;

    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: primaryBlue.withOpacity(0.12),
                  child: Icon(icon, color: primaryBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================================================
   UTIL
=========================================================== */
double parseNum(String v) => double.parse(v.trim().replaceAll(',', '.'));

String? valPositivo(String? v, {String nombre = "Este campo"}) {
  if (v == null || v.trim().isEmpty) return "$nombre es requerido";
  final txt = v.trim().replaceAll(',', '.');
  final n = double.tryParse(txt);
  if (n == null) return "Ingresa un número válido";
  if (n <= 0) return "$nombre debe ser mayor a 0";
  return null;
}

/* ===========================================================
   CERÁMICA (Cajas + Merma con switches)
=========================================================== */
class CeramicaPage extends StatefulWidget {
  const CeramicaPage({super.key});

  @override
  State<CeramicaPage> createState() => _CeramicaPageState();
}

class _CeramicaPageState extends State<CeramicaPage> {
  final _formKey = GlobalKey<FormState>();

  final _largoCtrl = TextEditingController();
  final _anchoCtrl = TextEditingController();
  final _m2CajaCtrl = TextEditingController();

  String? _errorMsg;

  double _area = 0;
  int _cajas = 0;

  // ✅ switches merma
  bool _usarMerma10 = true; // recomendado
  bool _usarMerma15 = false; // muchos cortes

  int _cajasRecomendadas = 0;
  double _mermaActiva = 0.10;

  @override
  void dispose() {
    _largoCtrl.dispose();
    _anchoCtrl.dispose();
    _m2CajaCtrl.dispose();
    super.dispose();
  }

  void _resetResultados() {
    _area = 0;
    _cajas = 0;
    _cajasRecomendadas = 0;
  }

  double _getMerma() {
    if (_usarMerma15) return 0.15;
    if (_usarMerma10) return 0.10;
    return 0.0;
  }

  String _labelMerma(double m) {
    if (m == 0.15) return "15% merma (muchos cortes)";
    if (m == 0.10) return "10% merma (recomendada)";
    return "sin merma";
  }

  void _recalcularSiHayResultados() {
    // si ya había resultados, recalculamos con nueva merma
    if (_cajas > 0 && _area > 0) {
      final merma = _getMerma();
      final recomendadas = merma > 0 ? (_cajas * (1 + merma)).ceil() : _cajas;
      setState(() {
        _mermaActiva = merma;
        _cajasRecomendadas = recomendadas;
      });
    }
  }

  void _calcular() {
    setState(() => _errorMsg = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMsg = "Revisa los campos: no pueden ser 0 ni estar vacíos.";
        _resetResultados();
      });
      return;
    }

    try {
      final largo = parseNum(_largoCtrl.text);
      final ancho = parseNum(_anchoCtrl.text);
      final m2Caja = parseNum(_m2CajaCtrl.text);

      final area = largo * ancho;
      final cajas = (area / m2Caja).ceil();

      final merma = _getMerma();
      final recomendadas = merma > 0 ? (cajas * (1 + merma)).ceil() : cajas;

      setState(() {
        _area = area;
        _cajas = cajas;
        _mermaActiva = merma;
        _cajasRecomendadas = recomendadas;
      });
    } catch (_) {
      setState(() {
        _errorMsg = "Formato inválido. Usa números (ej: 2.5 o 2,5).";
        _resetResultados();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mermaLabel = _labelMerma(_mermaActiva);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerámica'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 750;

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Calculadora de cerámica',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),

                            // ✅ switches merma
                            Card(
                              elevation: 0,
                              color: Colors.black.withOpacity(0.03),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Merma (cortes/roturas)",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    SwitchListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text("10% merma (recomendada)"),
                                      value: _usarMerma10,
                                      onChanged: (v) {
                                        setState(() {
                                          _usarMerma10 = v;
                                          if (v) _usarMerma15 = false; // no mezclar
                                          _mermaActiva = _getMerma();
                                        });
                                        _recalcularSiHayResultados();
                                      },
                                    ),
                                    SwitchListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text("15% merma (muchos cortes)"),
                                      value: _usarMerma15,
                                      onChanged: (v) {
                                        setState(() {
                                          _usarMerma15 = v;
                                          if (v) _usarMerma10 = false; // no mezclar
                                          _mermaActiva = _getMerma();
                                        });
                                        _recalcularSiHayResultados();
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Merma activa: ${_labelMerma(_getMerma())}",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: isMobile ? double.infinity : 300,
                                  child: TextFormField(
                                    controller: _largoCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Largo (m)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => valPositivo(v, nombre: "Largo"),
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 300,
                                  child: TextFormField(
                                    controller: _anchoCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Ancho (m)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => valPositivo(v, nombre: "Ancho"),
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 300,
                                  child: TextFormField(
                                    controller: _m2CajaCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'm² por caja',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => valPositivo(v, nombre: "m² por caja"),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            ElevatedButton(
                              onPressed: _calcular,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Calcular'),
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Área: ${_area.toStringAsFixed(2)} m²",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Cajas necesarias: $_cajas",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_cajas > 0) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        border: Border.all(color: Colors.green.withOpacity(0.40)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.recommend_rounded, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Recomendable comprar: $_cajasRecomendadas cajas (incluye $mermaLabel).",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_errorMsg != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        border: Border.all(color: Colors.red.withOpacity(0.45)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMsg!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================================================
   PINTURA (REDONDEADO, SIN DECIMALES)
=========================================================== */
class PinturaPage extends StatefulWidget {
  const PinturaPage({super.key});

  @override
  State<PinturaPage> createState() => _PinturaPageState();
}

class _PinturaPageState extends State<PinturaPage> {
  final _formKey = GlobalKey<FormState>();

  final _areaCtrl = TextEditingController();
  final _coberturaCtrl = TextEditingController(text: "40");

  String? _errorMsg;

  int _galonesComprar = 0;

  @override
  void dispose() {
    _areaCtrl.dispose();
    _coberturaCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    setState(() => _errorMsg = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMsg = "Revisa los campos: no pueden ser 0 ni estar vacíos.";
        _galonesComprar = 0;
      });
      return;
    }

    try {
      final area = parseNum(_areaCtrl.text);
      final cobertura = parseNum(_coberturaCtrl.text);

      // ✅ Redondeo SIEMPRE hacia arriba (sin decimales)
      final galones = (area / cobertura).ceil();

      setState(() {
        _galonesComprar = galones;
      });
    } catch (_) {
      setState(() {
        _errorMsg = "Formato inválido. Usa números (ej: 2.5 o 2,5).";
        _galonesComprar = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pintura'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 750;

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Calculadora de pintura',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: isMobile ? double.infinity : 420,
                                  child: TextFormField(
                                    controller: _areaCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Área a pintar (m²)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => valPositivo(v, nombre: "Área (m²)"),
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 420,
                                  child: TextFormField(
                                    controller: _coberturaCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Cobertura por galón (m²)',
                                      helperText: 'Ej: 35, 40, 45 (según pintura)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => valPositivo(v, nombre: "Cobertura por galón"),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            ElevatedButton(
                              onPressed: _calcular,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Calcular'),
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.08),
                                      border: Border.all(color: Colors.green.withOpacity(0.40)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.recommend_rounded, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Recomendable comprar: $_galonesComprar galón(es)",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_errorMsg != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        border: Border.all(color: Colors.red.withOpacity(0.45)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMsg!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
