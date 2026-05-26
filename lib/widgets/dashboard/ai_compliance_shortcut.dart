import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_providers.dart';
import '../glass_card.dart';

/// Vibrant and stunning AI Compliance check card shortcut.
class AiComplianceShortcut extends ConsumerWidget {
  /// The AI analysis state model.
  final AiAnalysisState aiState;

  /// Creates an [AiComplianceShortcut].
  const AiComplianceShortcut({
    super.key,
    required this.aiState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(navProvider.notifier).setIndex(1),
      child: GlassCard(
        borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.4),
        backgroundGradient: [
          const Color(0xFF00E6FF).withValues(alpha: 0.09),
          const Color(0xFF00FF87).withValues(alpha: 0.01),
        ],
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E6FF).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF00E6FF).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Color(0xFF00E6FF),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Compliance Audit Scanner',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verify water lines, stacks, tanks, or drainage runs dynamically against AS/NZS 3500.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daily Remaining: ${aiState.dailyRemaining} / 5 analyses',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: aiState.canAnalyze
                          ? const Color(0xFF00FF87)
                          : const Color(0xFFFF416C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}
