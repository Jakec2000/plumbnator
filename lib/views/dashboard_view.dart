import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';

/// The central dashboard of Plumbnator QLD, providing high-level KPIs,
/// compliance ratings, and quick actions.
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    final aiState = ref.watch(aiAnalysisProvider);
    final totalJobs = jobs.length;
    final avgScore = totalJobs == 0
        ? 0.0
        : jobs.map((e) => e.complianceScore).reduce((a, b) => a + b) / totalJobs;
    final pendingForm4s = jobs.where((e) => !e.form4Submitted).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildKpiGrid(context, avgScore, pendingForm4s, totalJobs),
          const SizedBox(height: 32),
          _buildMainLayout(context, ref, aiState, jobs),
        ],
      ),
    );
  }

  /// Builds the dashboard header with welcome text and current state.
  Widget _buildHeader(BuildContext context) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          'Australian AS/NZS 3500 & QBCC Compliance Center',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF00E6FF),
          ),
        ),
      ],
    );
  }

  /// Builds a responsive grid of high-fidelity glassmorphic KPI cards.
  Widget _buildKpiGrid(
    BuildContext context,
    double avgScore,
    int pendingForm4s,
    int totalJobs,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 3.2 : 1.7,
      children: [
        _buildStatCard(
          title: 'Avg Compliance',
          value: '${(avgScore * 100).toStringAsFixed(0)}%',
          subtitle: 'AS/NZS 3500 Standard',
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF00FF87),
        ),
        _buildStatCard(
          title: 'Pending Form 4s',
          value: '$pendingForm4s',
          subtitle: '10-Day Lodgement Limit',
          icon: Icons.assignment_late_outlined,
          color: const Color(0xFFFF416C),
        ),
        _buildStatCard(
          title: 'Active Jobs Logs',
          value: '$totalJobs',
          subtitle: 'Active Registered Sites',
          icon: Icons.plumbing_outlined,
          color: const Color(0xFF00E6FF),
        ),
      ],
    );
  }

  /// Builds a single stat card in the dashboard grid.
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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

  /// Builds the main layout showing recent jobs and compliance feeds.
  Widget _buildMainLayout(BuildContext context, WidgetRef ref, AiAnalysisState aiState, dynamic jobs) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isMobile ? 0 : 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vibrant and stunning AI Compliance check card shortcut
              GestureDetector(
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
                          border: Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.3)),
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
              ),
              const SizedBox(height: 28),
              Text(
                'Recent Active Sites',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...jobs.map<Widget>((job) => _buildJobItem(job)).toList(),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) const SizedBox(height: 32),
              Text(
                'QLD Regulatory Brief',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildRegulatorySummary(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a beautifully stylized job element for the jobs feed.
  Widget _buildJobItem(dynamic job) {
    final isCompliant = job.complianceScore >= 0.8;
    final statusColor = job.form4Submitted
        ? const Color(0xFF00FF87)
        : job.isOverdue
            ? const Color(0xFFFF416C)
            : const Color(0xFFFFD200);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderColor: statusColor.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withValues(alpha: 0.1),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Icon(
                job.form4Submitted
                    ? Icons.done_all
                    : job.isOverdue
                        ? Icons.gavel_outlined
                        : Icons.pending_actions,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.address,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C))
                        .withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '${(job.complianceScore * 100).toStringAsFixed(0)}% Match',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card summarizing vital Queensland regulations.
  Widget _buildRegulatorySummary() {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRegulationBullet(
            icon: Icons.thermostat_outlined,
            title: 'AS/NZS 3500.4 Tempering',
            desc: 'Hot water must be stored at min 60°C to prevent bacteria, but delivered to sanitary outlets at max 50°C (45°C in schools/nursing homes).',
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildRegulationBullet(
            icon: Icons.trending_down_outlined,
            title: 'AS/NZS 3500.2 Drainage Grade',
            desc: 'DN100 main sanitary lines require a minimum 1.65% gradient (1:60 grade). DN80 lines require 2.50% gradient (1:40).',
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildRegulationBullet(
            icon: Icons.timer_outlined,
            title: 'QBCC Form 4 Submission Limit',
            desc: 'Licensed contractors MUST submit Form 4 Notifiable Work within 10 business days of completion, under the Plumbing Act.',
          ),
        ],
      ),
    );
  }

  /// Helper widget for rendering a single bullet under regulatory cards.
  Widget _buildRegulationBullet({
    required IconData icon,
    required String title,
    required String desc,
  }) {
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
