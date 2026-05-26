import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Scanning feedback loader.
class ScanningProgressIndicator extends StatelessWidget {
  const ScanningProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          const LinearProgressIndicator(
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E6FF)),
          ),
          const SizedBox(height: 12),
          Text(
            'Grok Vision processing compliance parameters against AS/NZS 3500 with extreme accuracy...',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
