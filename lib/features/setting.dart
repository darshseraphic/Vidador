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

  // LOCAL MICRO-STATE FOR DROPDOWN EXPANSILE BLOCKS
  bool _isPrivacyPolicyExpanded = false;
  bool _isDataPrivacyExpanded = false;

  // CORE LINK HANDSHAKE ENGINE
  Future<void> _launchWebsiteUrl() async {
    final Uri url = Uri.parse('https://vidador.lovable.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('System Error: Could not execute route handshake to $url');
    }
  }

  Future<void> _launchFeedbackUrl() async {
    final Uri url = Uri.parse('https://vidador.lovable.app/feedback');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('System Error: Could not execute route handshake to $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF888888) : const Color(0xFF404040);
    final borderColor = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5);
    final expandedContainerBg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            Text(
              'SYSTEM CONFIG MATRIX',
              style: TextStyle(
                color: textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 24),

            // [01] INTERFACE THEME switcher BINARY
            GestureDetector(
              onTap: () {
                ref.read(themeProvider.notifier).state = !isDark;
                Hive.box(_boxName).put('is_dark_mode', !isDark);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INTERFACE THEME',
                          style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TOGGLE VISUAL SPECTRUM MODE',
                          style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.02),
                        ),
                      ],
                    ),
                    Text(
                      isDark ? '[ PURE DARK ]' : '[ PURE LIGHT ]',
                      style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.04),
                    ),
                  ],
                ),
              ),
            ),

            // [02] PRIVACY POLICY EXPAND Drawer
            GestureDetector(
              onTap: () => setState(() => _isPrivacyPolicyExpanded = !_isPrivacyPolicyExpanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: _isPrivacyPolicyExpanded ? 0 : 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIVACY POLICY',
                          style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'REVIEW DATA HANDLING CONDITIONS',
                          style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.02),
                        ),
                      ],
                    ),
                    Icon(
                      _isPrivacyPolicyExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: textSub,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            if (_isPrivacyPolicyExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: expandedContainerBg,
                  border: Border(
                    left: BorderSide(color: borderColor, width: 0.8),
                    right: BorderSide(color: borderColor, width: 0.8),
                    bottom: BorderSide(color: borderColor, width: 0.8),
                  ),
                ),
                child: Text(
                  'VIDADOR HEALTH OPERATES UNDER DISCIPLINED USER BOUNDARIES. NO METRIC QUANTIFIERS OR SLEEP INTERNALS LOGGED ARE BROADCAST TO REMOTE NETWORKS. DATA INTERACTION RULES COMPLY DIRECTLY WITH OFF-GRID PRIVACY STATUTES.',
                  style: TextStyle(color: textSub, fontSize: 9, height: 1.6, fontWeight: FontWeight.w600, letterSpacing: 0.01),
                ),
              ),

            // [03] DATA PRIVACY COMPARTMENT
            GestureDetector(
              onTap: () => setState(() => _isDataPrivacyExpanded = !_isDataPrivacyExpanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: _isDataPrivacyExpanded ? 0 : 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATA PRIVACY',
                          style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LOCAL DISK SANDBOX SPECIFICATIONS',
                          style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.02),
                        ),
                      ],
                    ),
                    Icon(
                      _isDataPrivacyExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: textSub,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            if (_isDataPrivacyExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: expandedContainerBg,
                  border: Border(
                    left: BorderSide(color: borderColor, width: 0.8),
                    right: BorderSide(color: borderColor, width: 0.8),
                    bottom: BorderSide(color: borderColor, width: 0.8),
                  ),
                ),
                child: Text(
                  'ALL BIOMETRIC LOG DATA IS ISOLATED WITHIN THE LOCAL DEVICE PERSISTENCE SANDBOX ARRAY. ERASING THE VIDADOR ENVIRONMENT PERMANENTLY DESTROYS AND PURGES ALL HIVE ARCHIVE REGISTRIES INSTANTLY.',
                  style: TextStyle(color: textSub, fontSize: 9, height: 1.6, fontWeight: FontWeight.w600, letterSpacing: 0.01),
                ),
              ),

            // [04] EXTERNAL WEBSITE BRIDGE
            GestureDetector(
              onTap: _launchWebsiteUrl,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEBSITE',
                          style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ACCESS THE OUTWARD PROJECT GATEWAY',
                          style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.02),
                        ),
                      ],
                    ),
                    Icon(Icons.open_in_new, color: textSub, size: 14),
                  ],
                ),
              ),
            ),

            // [05] PIPELINE ANOMALY FEEDBACK BRIDGE
            GestureDetector(
              onTap: _launchFeedbackUrl,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FEEDBACK',
                          style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'REPORT SYSTEM METRIC ANOMALIES',
                          style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.02),
                        ),
                      ],
                    ),
                    Icon(Icons.open_in_new, color: textSub, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 64),

            // THE SYSTEM SIGNATURE STAMP STAYS FIRM AT THE VERTEX BASE
            Center(
              child: Text(
                'BUILD BY DARSHSERPHIC',
                style: TextStyle(
                  color: textSub.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
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