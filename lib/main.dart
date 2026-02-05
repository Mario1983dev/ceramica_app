import 'package:flutter/material.dart';

import 'pages/ceramica_page.dart';
import 'pages/pintura_page.dart';
import 'pages/terciado_page.dart';
import 'pages/ladrillos_page.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/* ===========================================================
   HOME
=========================================================== */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String logoPath = 'assets/images/logo-solusoft.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SoluSoft')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isMobile = c.maxWidth < 750;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      Image.asset(
                        logoPath,
                        height: 180,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          HomeCard(
                            isMobile: isMobile,
                            title: 'Cerámica',
                            subtitle: 'Cajas necesarias + merma',
                            icon: Icons.grid_on_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CeramicaPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: 'Pintura',
                            subtitle: 'Galones necesarios',
                            icon: Icons.format_paint_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PinturaPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: 'Terciado ranurado',
                            subtitle: 'Planchas necesarias + merma',
                            icon: Icons.view_quilt_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TerciadoPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: 'Ladrillos pared',
                            subtitle: 'Cantidad + mortero + merma',
                            icon: Icons.view_stream_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LadrillosPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ===========================================================
   TARJETA DEL MENÚ
=========================================================== */

class HomeCard extends StatelessWidget {
  final bool isMobile;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
