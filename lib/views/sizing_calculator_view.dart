import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';

/// Hydraulic sanitary drainage sizing calculator view based on AS/NZS 3500.2.
class SizingCalculatorView extends ConsumerWidget {
  const SizingCalculatorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sizingProvider);
    final notifier = ref.read(sizingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCalculatorGrid(context, state, notifier),
        ],
      ),
    );
  }

  /// Page heading.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HYDRAULIC DRAINAGE SIZER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Automated AS/NZS 3500.2 sanitary drainage loading compliance engine',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Renders a two-column responsive calculator layout.
  Widget _buildCalculatorGrid(
    BuildContext context,
    SizingState state,
    SizingNotifier notifier,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isMobile ? 0 : 4,
          child: Column(
            children: [
              _buildFixtureSelector(state, notifier),
              const SizedBox(height: 20),
              _buildTrenchControls(state, notifier),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 3,
          child: Column(
            children: [
              if (isMobile) const SizedBox(height: 24),
              _buildSizingReport(state),
            ],
          ),
        ),
      ],
    );
  }

  /// Card with list of plumbing fixtures.
  Widget _buildFixtureSelector(SizingState state, SizingNotifier notifier) {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sanitary Fixture Inventory',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Add fixtures to calculate total discharge loading unit value.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ...state.fixtureCounts.keys.map((fixture) {
            final count = state.fixtureCounts[fixture] ?? 0;
            return _buildFixtureRow(fixture, count, notifier);
          }),
        ],
      ),
    );
  }

  /// Singular fixture row item with plus/minus increments.
  Widget _buildFixtureRow(String fixture, int count, SizingNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fixture,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => notifier.updateFixtureCount(fixture, count - 1),
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E6FF)),
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => notifier.updateFixtureCount(fixture, count + 1),
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E6FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Controls for trench length and gradients.
  Widget _buildTrenchControls(SizingState state, SizingNotifier notifier) {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trench Specifications',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Trench Run Length: ${state.runLength.toStringAsFixed(1)} m',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          Slider(
            value: state.runLength,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            activeColor: const Color(0xFF00E6FF),
            inactiveColor: Colors.white12,
            onChanged: notifier.updateRunLength,
          ),
          const SizedBox(height: 12),
          Text(
            'Installation Gradient (Slope): ${state.gradePercentage.toStringAsFixed(2)}%',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          Slider(
            value: state.gradePercentage,
            min: 0.5,
            max: 5.0,
            divisions: 45,
            activeColor: const Color(0xFF00E6FF),
            inactiveColor: Colors.white12,
            onChanged: notifier.updateGradePercentage,
          ),
        ],
      ),
    );
  }

  /// Detailed sizing calculation output.
  Widget _buildSizingReport(SizingState state) {
    final minGrade = state.minimumCompliantGrade;
    final isGradeCompliant = state.gradePercentage >= minGrade;
    final alertColor = isGradeCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C);

    return GlassCard(
      borderColor: alertColor.withOpacity(0.2),
      backgroundGradient: [
        alertColor.withOpacity(0.05),
        Colors.white.withOpacity(0.01),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HYDRAULIC REPORT',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: alertColor),
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildReportItem('Total Fixture Units', '${state.totalFixtureUnits} FU'),
          _buildReportItem('Required Min Pipe Size', 'DN ${state.minimumPipeSize}'),
          _buildReportItem('AS/NZS 3500.2 Min Grade', '${minGrade.toStringAsFixed(2)}% (1:${(100 / minGrade).toStringAsFixed(0)})'),
          _buildReportItem('Calculated Total Fall', '${state.requiredFallMm.toStringAsFixed(1)} mm'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: alertColor.withOpacity(0.1),
              border: Border.all(color: alertColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(isGradeCompliant ? Icons.check_circle_outline : Icons.warning_amber_outlined, color: alertColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isGradeCompliant
                        ? 'Gradient matches AS/NZS 3500.2 sanitary drainage guidelines.'
                        : 'Warning: Gradient is lower than AS/NZS 3500.2 minimum of $minGrade%. Blockage risk!',
                    style: GoogleFonts.inter(fontSize: 12, color: alertColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Single metric row layout.
  Widget _buildReportItem(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
          Text(val, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
