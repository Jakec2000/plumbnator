import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Page heading for the AI Compliance view.
class ComplianceHeading extends StatelessWidget {
  const ComplianceHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI VISION COMPLIANCE CHECKER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Multimodal installation scanning (AS/NZS 3500 & PCA Standards)',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
