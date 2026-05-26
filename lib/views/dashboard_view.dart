import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/kpi_grid.dart';
import '../widgets/dashboard/job_feed.dart';
import '../widgets/dashboard/ai_compliance_shortcut.dart';
import '../widgets/dashboard/regulatory_summary.dart';

/// The central dashboard of Plumbnator QLD, providing high-level KPIs,
/// compliance ratings, and quick actions.
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          DashboardHeader(pulseAnimation: _pulseAnimation),
          const SizedBox(height: 28),
          KpiGrid(
            avgScore: avgScore,
            pendingForm4s: pendingForm4s,
            totalJobs: totalJobs,
          ),
          const SizedBox(height: 36),
          _DashboardMainLayout(
            aiState: aiState,
            jobs: jobs,
          ),
        ],
      ),
    );
  }
}

class _DashboardMainLayout extends StatelessWidget {
  final AiAnalysisState aiState;
  final List<dynamic> jobs;

  const _DashboardMainLayout({
    required this.aiState,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
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
              AiComplianceShortcut(aiState: aiState),
              const SizedBox(height: 28),
              JobFeed(jobs: jobs),
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
              const RegulatorySummary(),
            ],
          ),
        ),
      ],
    );
  }
}
