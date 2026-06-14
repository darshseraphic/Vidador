import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _boxName = 'vidador_settings_box';

  // ==========================================
  // EXTERNAL OUTWARD ROUTING PIPELINES
  // ==========================================
  Future<void> _launchWebsiteUrl() async {
    final Uri url = Uri.parse('https://darshseraphic.github.io/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('System Error: Could not execute route handshake to $url');
    }
  }

  Future<void> _launchFeedbackUrl() async {
    final Uri url = Uri.parse('https://www.github.com/darshseraphic');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('System Error: Could not execute route handshake to $url');
    }
  }

  // ==========================================
  // SLIDING INFORMATION PANELS (UI ARCHITECTURE)
  // ==========================================
  void _showSlidingPanel(BuildContext context, String title, List<Widget> children, bool isDark) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          final panelBg = isDark ? Colors.black : Colors.white;
          final textMain = isDark ? Colors.white : Colors.black;
          final borderColor = isDark ? Colors.white : Colors.black;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(color: Colors.transparent),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: panelBg,
                        border: Border(left: BorderSide(color: borderColor, width: 1)),
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor, width: 1),
                                      ),
                                      child: Icon(Icons.arrow_back, size: 14, color: textMain),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: textMain,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.02,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: borderColor, height: 1, thickness: 1),
                            Expanded(
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(24.0),
                                children: children,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textMain,
    required Color textSub,
    required Color borderColor,
    bool trailingArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: 0.03,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSub,
                      fontSize: 10,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
                trailingArrow ? Icons.chevron_right : Icons.open_in_new,
                size: 14,
                color: textSub
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String header, String body, Color textMain, Color textSub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              color: textMain,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: textSub,
              fontSize: 11,
              height: 1.45,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.65);
    final borderColor = isDark ? Colors.white : Colors.black;
    final containerBg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'SYSTEM CONFIG MATRIX',
              style: TextStyle(
                color: textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 24),

            // SYSTEM-WIDE DARK THEME CONFIG
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: containerBg,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INTERFACE THEME',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          letterSpacing: 0.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TOGGLE VISUAL SPECTRUM MODE',
                        style: TextStyle(color: textSub, fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).state = !isDark;
                      Hive.box(_boxName).put('is_dark_mode', !isDark);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 44,
                      height: 24,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: containerBg,
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 120),
                        alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          color: textMain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: borderColor, thickness: 1, height: 32),

            // [01] USER GUIDE PANEL
            _buildMenuTile(
              title: 'USER GUIDE',
              subtitle: 'OVERVIEW OF HEALTH METRIC SYSTEMS',
              textMain: textMain,
              textSub: textSub,
              borderColor: borderColor,
              onTap: () => _showSlidingPanel(
                context,
                'USER GUIDE',
                [
                  _buildInfoSection(
                      '01 // SYSTEM ROOT ENGINE',
                      'Initializes global asynchronous reactive state loops using Riverpod. It maps runtime dependencies directly upon app activation and tracks biological metric mutations securely.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '02 // WATER QUANTIZER',
                      'Logs daily volumetric fluid intake into the local memory matrix. Uses dynamic fraction-bars mapped against a standardized 3000ml baseline quota to track hydration levels continuously.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '03 // STEPS TELEMETRY',
                      'Hardware-linked pedometer mapping for daily kinetic activity. Reads system hardware outputs through isolated streams and computes multi-tiered kinetic intensity arrays dynamically.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '04 // MEDITATION CHRONO',
                      'Focus state execution engine built with cumulative additive timers. Tracks full uninterrupted sessions and logs explicitly interrupted cycles to map cognitive endurance metrics over time.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '05 // SLEEP MATRIX',
                      'Biological rest cycle analysis tracking sleep onset and wake cycles. Compiles deep REST datasets locally to construct physical recovery history trends without exterior parsing layers.',
                      textMain, textSub
                  ),
                ],
                isDark,
              ),
            ),

            // [02] DATA SECURITY PANEL
            _buildMenuTile(
              title: 'DATA SECURITY',
              subtitle: 'LOCAL DISK SANDBOX SPECIFICATIONS',
              textMain: textMain,
              textSub: textSub,
              borderColor: borderColor,
              onTap: () => _showSlidingPanel(
                context,
                'DATA SECURITY',
                [
                  _buildInfoSection(
                      '01 // STORAGE PIPELINE (NOSQL ENGINE)',
                      'Vidador avoids slow, heavy relational SQL frameworks entirely. The application operates exclusively on a lightning-fast NoSQL key-value architecture powered by Hive databases securely written inside internal storage partitions.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '02 // BOX CONTAINER MATRIX',
                      'Data blocks for Sleep, Water, Steps, and Meditation are separated into dedicated, context-isolated data compartments called "Boxes". This creates lightweight data access pathways that protect historical databases from schema-breaking risks.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '03 // MEMORY-FIRST BUFFER PIPELINE',
                      'Data structures are loaded straight into fast active RAM buffers during bootup. Read tasks operate directly inside this memory layer with zero disk latency for instant visual updates across dashboard screens.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '04 // APPLICATION PERMISSIONS OUTLINE',
                      'The application manifest explicitly excludes background telemetry monitors and analytical scrapers. Your biometric information is physically unable to leave the system via background connection bridges.',
                      textMain, textSub
                  ),
                ],
                isDark,
              ),
            ),

            // [03] PRIVACY POLICY PANEL
            _buildMenuTile(
              title: 'PRIVACY POLICY',
              subtitle: 'REVIEW DATA HANDLING CONDITIONS',
              textMain: textMain,
              textSub: textSub,
              borderColor: borderColor,
              onTap: () => _showSlidingPanel(
                context,
                'PRIVACY POLICY',
                [
                  _buildInfoSection(
                      '01 // APPLICATION PURPOSE',
                      'Vidador Health operates as a hyper-focused minimalist biometric tracking system designed to run high-utility trackers without backend software bloat or visual clutter.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '02 // SYSTEM AUTHORSHIP',
                      'Engineered and assembled by Darshseraphic.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '03 // PURPOSE & DESIGN METHODOLOGY',
                      'Built to mitigate screen fatigue through a stark brutalist interface style, intentional whitespace, and highly structured monochrome layout mapping.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '04 // ABSOLUTE ZERO DATA ACCUMULATION',
                      'This framework operates with a strict zero-telemetry policy. There are no analytics packages, usage tracking monitors, remote crash trackers, or cloud-based data bridges written into the codebase. All health activity remains strictly contained on your local device.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '05 // AIR-GAPPED HARDWARE ISOLATION',
                      'The application runs entirely within an air-gapped system methodology. Without network permissions or server communication layers configured in its structural layer, user interactions are kept private, secure, and permanently anchored inside the isolated sandbox space of your hardware.',
                      textMain, textSub
                  ),
                  _buildInfoSection(
                      '06 // USER-OWNED STORAGE ARCHITECTURE',
                      'You retain absolute, exclusive ownership of your data files. The system cannot read, change, or access stored items outside its specific offline database context. Deleting the application instantly wipes all local cache directories from internal storage arrays forever.',
                      textMain, textSub
                  ),
                ],
                isDark,
              ),
            ),

            // [04] EXTERNAL WEBSITE LINK
            _buildMenuTile(
              title: 'PORTFOLIO',
              subtitle: 'KNOW MORE ABOUT THE DEVELOPER OF THE VIDADOR',
              textMain: textMain,
              textSub: textSub,
              borderColor: borderColor,
              trailingArrow: false,
              onTap: _launchWebsiteUrl,
            ),

            // [05] PIPELINE FEEDBACK HUB
            _buildMenuTile(
              title: 'OTHER APPS',
              subtitle: 'GITHUB PROFILE LINK INTEGATION FOR MORE APP ACCESS',
              textMain: textMain,
              textSub: textSub,
              borderColor: borderColor,
              trailingArrow: false,
              onTap: _launchFeedbackUrl,
            ),

            const SizedBox(height: 64),

            // THE SYSTEM SIGNATURE STAMP
            Center(
              child: Text(
                'BUILD BY DARSHSERPHIC',
                style: TextStyle(
                  color: textMain,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  letterSpacing: 0.12,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}