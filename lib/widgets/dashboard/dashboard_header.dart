import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the dashboard header with animated accent and version badge.
class DashboardHeader extends StatelessWidget {
  /// The pulse animation controlling the gradient accent line.
  final Animation<double> pulseAnimation;

  /// Creates a [DashboardHeader].
  const DashboardHeader({super.key, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLUMBNATOR QLD',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Australian AS/NZS 3500 & QBCC Compliance Center',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF00E6FF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E6FF).withValues(alpha: 0.12),
                    const Color(0xFF00FF87).withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E6FF).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00FF87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'v3.1.0 • QLD Licensed',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Animated gradient accent line
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E6FF).withValues(alpha: pulseAnimation.value),
                    const Color(0xFF00FF87).withValues(alpha: pulseAnimation.value * 0.6),
                    const Color(0xFF00E6FF).withValues(alpha: 0.1),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
