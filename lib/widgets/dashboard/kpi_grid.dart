import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_card.dart';

/// Builds a responsive grid of high-fidelity glassmorphic KPI cards.
class KpiGrid extends StatelessWidget {
  /// The average compliance score across all jobs.
  final double avgScore;
  /// The number of jobs that have not submitted a Form 4.
  final int pendingForm4s;
  /// The total number of active jobs.
  final int totalJobs;

  /// Creates a [KpiGrid].
  const KpiGrid({
    super.key,
    required this.avgScore,
    required this.pendingForm4s,
    required this.totalJobs,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 3.2 : 1.7,
      children: [
        _StatCard(
          title: 'Avg Compliance',
          value: '${(avgScore * 100).toStringAsFixed(0)}%',
          subtitle: 'AS/NZS 3500 Standard',
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF00FF87),
        ),
        _StatCard(
          title: 'Pending Form 4s',
          value: '$pendingForm4s',
          subtitle: '10-Day Lodgement Limit',
          icon: Icons.assignment_late_outlined,
          color: const Color(0xFFFF416C),
        ),
        _StatCard(
          title: 'Active Jobs Logs',
          value: '$totalJobs',
          subtitle: 'Active Registered Sites',
          icon: Icons.plumbing_outlined,
          color: const Color(0xFF00E6FF),
        ),
      ],
    );
  }
}

/// A single stat card used within the [KpiGrid].
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withValues(alpha: 0.2),
      backgroundGradient: [
        color.withValues(alpha: 0.06),
        Colors.white.withValues(alpha: 0.01),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
