import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/app_strings.dart';

import 'ceramica_page.dart';
import 'pintura_page.dart';
import 'terciado_page.dart';
import 'ladrillos_page.dart';
import 'radier_page.dart';

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
              padding: const EdgeInsets.all(AppConstants.padding),
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
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: const Text(
                            'SoluSoft',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          HomeCard(
                            isMobile: isMobile,
                            title: AppStrings.ceramicaTitle,
                            subtitle: AppStrings.ceramicaSubtitle,
                            icon: Icons.grid_on_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CeramicaPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: AppStrings.pinturaTitle,
                            subtitle: AppStrings.pinturaSubtitle,
                            icon: Icons.format_paint_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PinturaPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: AppStrings.terciadoTitle,
                            subtitle: AppStrings.terciadoSubtitle,
                            icon: Icons.view_quilt_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TerciadoPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: AppStrings.ladrillosTitle,
                            subtitle: AppStrings.ladrillosSubtitle,
                            icon: Icons.view_stream_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LadrillosPage(),
                                ),
                              );
                            },
                          ),
                          HomeCard(
                            isMobile: isMobile,
                            title: AppStrings.radierTitle,
                            subtitle: AppStrings.radierSubtitle,
                            icon: Icons.foundation_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RadierPage(),
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
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12), // ✅ sin withOpacity
                  child: Icon(icon, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
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
