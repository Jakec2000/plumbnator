import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_card.dart';

/// Custom error presentation card.
class ComplianceErrorMessage extends StatelessWidget {
  final String message;

  const ComplianceErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('error_widget'),
      padding: const EdgeInsets.only(top: 24.0),
      child: GlassCard(
        borderColor: const Color(0xFFFF416C).withValues(alpha: 0.3),
        backgroundGradient: [
          const Color(0xFFFF416C).withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.01),
        ],
        child: Row(
          children: [
            const Icon(Icons.error_outline_sharp, color: Color(0xFFFF416C), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Warning',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFFFF416C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
