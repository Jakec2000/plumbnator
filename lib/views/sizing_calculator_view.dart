import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';

/// Upgraded dual-mode hydraulic sizer view based on AS/NZS 3500.1 and AS/NZS 3500.2 standards.
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
          const SizedBox(height: 20),
          _buildModeSelector(state, notifier),
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
          'HYDRAULIC COMPLIANCE SIZER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Automated AS/NZS 3500 sanitary loading and water pipe compliance sizer',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Mode toggle selector for Drainage and Water Supply.
  Widget _buildModeSelector(SizingState state, SizingNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              'Sanitary Drainage (AS/NZS 3500.2)',
              SizingMode.drainage,
              state.sizingMode,
              notifier,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildModeTab(
              'Water Supply (AS/NZS 3500.1)',
              SizingMode.waterSupply,
              state.sizingMode,
              notifier,
            ),
          ),
        ],
      ),
    );
  }

  /// Single selector tab layout.
  Widget _buildModeTab(
    String label,
    SizingMode targetMode,
    SizingMode activeMode,
    SizingNotifier notifier,
  ) {
    final isSelected = activeMode == targetMode;
    final primaryColor = const Color(0xFF00E6FF);

    return InkWell(
      onTap: () => notifier.updateSizingMode(targetMode),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  /// Grid splitting fixtures and sizing results dynamically.
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
              _buildFixtureCard(state, notifier),
              const SizedBox(height: 20),
              if (state.sizingMode == SizingMode.drainage)
                _buildTrenchControls(state, notifier)
              else
                _buildPressureControls(notifier),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 3,
          child: Column(
            children: [
              if (isMobile) const SizedBox(height: 24),
              _buildSizingReportCard(state),
            ],
          ),
        ),
      ],
    );
  }

  /// Fixture selection inventory card based on sizer mode.
  Widget _buildFixtureCard(SizingState state, SizingNotifier notifier) {
    final isDrainage = state.sizingMode == SizingMode.drainage;
    final title = isDrainage ? 'Sanitary Fixture Inventory' : 'Water Supply Outlets';
    final desc = isDrainage
        ? 'Add fixtures to calculate total discharge loading unit value (FU).'
        : 'Specify supply fixtures to calculate peak demand Loading Units (LU).';
    final fixtures = isDrainage ? state.fixtureCounts : state.waterFixtureCounts;

    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ...fixtures.entries.map((entry) {
            return _buildFixtureRow(entry.key, entry.value, isDrainage, notifier);
          }),
        ],
      ),
    );
  }

  /// Singular item row layout.
  Widget _buildFixtureRow(
    String fixtureName,
    int count,
    bool isDrainage,
    SizingNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              fixtureName,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (isDrainage) {
                    notifier.updateFixtureCount(fixtureName, count - 1);
                  } else {
                    notifier.updateWaterFixtureCount(fixtureName, count - 1);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E6FF), size: 20),
              ),
              Container(
                width: 28,
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (isDrainage) {
                    notifier.updateFixtureCount(fixtureName, count + 1);
                  } else {
                    notifier.updateWaterFixtureCount(fixtureName, count + 1);
                  }
                },
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E6FF), size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Standard trench gradient slider controls for drainage mode.
  Widget _buildTrenchControls(SizingState state, SizingNotifier notifier) {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trench Run Specifications',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Trench Run Length: ${state.runLength.toStringAsFixed(1)} m',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
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
          const SizedBox(height: 8),
          Text(
            'Installation Gradient (Slope): ${state.gradePercentage.toStringAsFixed(2)}%',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
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

  /// Static explanation for water supply parameters.
  Widget _buildPressureControls(SizingNotifier notifier) {
    return const GlassCard(
      borderColor: Colors.white60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00E6FF), size: 20),
              SizedBox(width: 10),
              Text(
                'QLD Water Main Pressure Rules',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Under AS/NZS 3500.1 Clause 3.4, static water pressure at any sanitary outlet within a building must not exceed 500 kPa. If static pressure exceeds 500 kPa, a Pressure Limiting Valve (PLV) must be installed at the boundary feed.',
            style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Multi-faceted sizing report generator card.
  Widget _buildSizingReportCard(SizingState state) {
    if (state.sizingMode == SizingMode.drainage) {
      return _buildDrainageReport(state);
    } else {
      return _buildWaterReport(state);
    }
  }

  /// Drainage report view under AS/NZS 3500.2.
  Widget _buildDrainageReport(SizingState state) {
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
            'HYDRAULIC REPORT (AS/NZS 3500.2)',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: alertColor, letterSpacing: 0.5),
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildReportItem('Total Fixture Units', '${state.totalFixtureUnits} FU'),
          _buildReportItem('Required Min Pipe Size', 'DN ${state.minimumPipeSize}'),
          _buildReportItem('AS/NZS 3500.2 Min Grade', '${minGrade.toStringAsFixed(2)}% (1:${(100 / minGrade).toStringAsFixed(0)})'),
          _buildReportItem('Calculated Total Fall', '${state.requiredFallMm.toStringAsFixed(1)} mm'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: alertColor.withOpacity(0.1),
              border: Border.all(color: alertColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(isGradeCompliant ? Icons.check_circle_outline : Icons.warning_amber_outlined, color: alertColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isGradeCompliant
                        ? 'Gradient matches AS/NZS 3500.2 sanitary drainage guidelines.'
                        : 'Warning: Gradient is lower than AS/NZS 3500.2 minimum of $minGrade%. Blockage risk!',
                    style: GoogleFonts.inter(fontSize: 11, color: alertColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Water supply report view under AS/NZS 3500.1.
  Widget _buildWaterReport(SizingState state) {
    final totalLu = state.totalWaterLoadingUnits;
    final recommendedSize = state.recommendedWaterPipeSize;
    final hasHoseTap = (state.waterFixtureCounts['Hose Tap (DN20)'] ?? 0) > 0;
    final requiresBackflowDevice = hasHoseTap;
    final alertColor = totalLu > 0 ? const Color(0xFF00E6FF) : Colors.white24;

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
            'HYDRAULIC REPORT (AS/NZS 3500.1)',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: alertColor, letterSpacing: 0.5),
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildReportItem('Total Loading Units', '$totalLu LU'),
          _buildReportItem('Recommended Main Size', recommendedSize > 0 ? 'DN $recommendedSize' : 'N/A'),
          _buildReportItem('Estimated Peak Demand', '${state.estimatedWaterFlowRate.toStringAsFixed(2)} L/s'),
          _buildReportItem('Backflow Hazard Rating', requiresBackflowDevice ? 'Medium / High' : 'Low'),
          const SizedBox(height: 20),
          if (requiresBackflowDevice)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFFB000).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFFFB000).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB000), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hose Tap detected. Under AS/NZS 3500.1, this is rated Medium/High Hazard. A registered Backflow Preventer (RPZD or Double Check) must be commissioned via Form 9.',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFFFB000), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else if (totalLu > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF00FF87).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00FF87), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All fixtures classified as Low Hazard. Standard double check valves or non-return valves are compliant.',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF00FF87), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: const Text(
                'Specify fixtures above to generate hydraulic report.',
                style: TextStyle(fontSize: 12, color: Colors.white30),
              ),
            ),
        ],
      ),
    );
  }

  /// Metric row display component.
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
