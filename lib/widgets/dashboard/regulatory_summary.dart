import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_card.dart';

/// A card summarizing vital Queensland regulations.
class RegulatorySummary extends StatelessWidget {
  /// Creates a [RegulatorySummary].
  const RegulatorySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RegulationBullet(
            icon: Icons.thermostat_outlined,
            title: 'AS/NZS 3500.4 Tempering',
            desc:
                'Hot water must be stored at min 60°C to prevent bacteria, but delivered to sanitary outlets at max 50°C (45°C in schools/nursing homes).',
          ),
          const Divider(color: Colors.white12, height: 24),
          _RegulationBullet(
            icon: Icons.trending_down_outlined,
            title: 'AS/NZS 3500.2 Drainage Grade',
            desc:
                'DN100 main sanitary lines require a minimum 1.65% gradient (1:60 grade). DN80 lines require 2.50% gradient (1:40).',
          ),
          const Divider(color: Colors.white12, height: 24),
          _RegulationBullet(
            icon: Icons.timer_outlined,
            title: 'QBCC Form 4 Submission Limit',
            desc:
                'Licensed contractors MUST submit Form 4 Notifiable Work within 10 business days of completion, under the Plumbing Act.',
          ),
        ],
      ),
    );
  }
}

/// Helper widget for rendering a single bullet under regulatory cards.
class _RegulationBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _RegulationBullet({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E6FF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
