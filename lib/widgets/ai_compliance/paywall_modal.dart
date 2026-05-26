import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_providers.dart';

/// Interactive gold upgrade subscription modal sheet.
class PaywallModal {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        bool isLoading = false;
        bool isSuccess = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0F1D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 20),
                    // Gold Crown Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFFFD700), size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'UPGRADE TO PLUMBNATOR GOLD',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock unlimited AS/NZS 3500 & PCA compliance audits',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(height: 24),

                    // Plan details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.01),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Commercial License Plan',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                              ),
                              Text(
                                '\$29.90 / mo',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 20),
                          _buildPlanBenefit('Unlimited Visual AI Auditing Scans'),
                          _buildPlanBenefit('High-Resolution As-Constructed PDF plans'),
                          _buildPlanBenefit('AS 2845.3 Backflow tests & Form 9 registry'),
                          _buildPlanBenefit('Offline Local database automatic synchronization'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Secure pay shield banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, color: Colors.white30, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Secure SSL payment verified by JobFlow Pay',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isSuccess)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🎉 PLUMBNATOR GOLD ACTIVATED!',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF87),
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setModalState(() {
                                    isLoading = true;
                                  });
                                  // Secure mock billing wait
                                  await Future.delayed(const Duration(milliseconds: 1500));
                                  await ref.read(aiAnalysisProvider.notifier).upgradeToGold();
                                  setModalState(() {
                                    isLoading = false;
                                    isSuccess = true;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 1000));
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFFFFD700),
                                      content: Text(
                                        '🎉 Plumbnator Gold subscription activated successfully! Welcome to premium!',
                                        style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Text(
                                  'Authorize & Unlock Plumbnator Gold',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildPlanBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFFFFD700), size: 14),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
        ],
      ),
    );
  }
}
