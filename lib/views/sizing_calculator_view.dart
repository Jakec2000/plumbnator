import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';

/// Upgraded three-mode hydraulic sizer and laser grade staff level calculator
/// based on AS/NZS 3500.1 (water), AS/NZS 3500.2 (drainage/laser) standards.
class SizingCalculatorView extends ConsumerStatefulWidget {
  const SizingCalculatorView({super.key});

  @override
  ConsumerState<SizingCalculatorView> createState() => _SizingCalculatorViewState();
}

class _SizingCalculatorViewState extends ConsumerState<SizingCalculatorView> {
  double _groundSlope = 2.0; // default ground slope of 2%
  double _startCover = 600.0; // default start cover of 600mm

  @override
  Widget build(BuildContext context) {
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
          'Automated AS/NZS 3500 sanitary loading, water pipe, and laser grade compliance sizer',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Mode toggle selector for Drainage, Water Supply, and Laser Grade.
  Widget _buildModeSelector(SizingState state, SizingNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              'Drainage (3500.2)',
              SizingMode.drainage,
              state.sizingMode,
              notifier,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildModeTab(
              'Water (3500.1)',
              SizingMode.waterSupply,
              state.sizingMode,
              notifier,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildModeTab(
              'Laser Grade (3500.2)',
              SizingMode.laserGrade,
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
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  /// Grid splitting inputs and reports dynamically.
  Widget _buildCalculatorGrid(
    BuildContext context,
    SizingState state,
    SizingNotifier notifier,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    final Widget leftColumn;
    if (state.sizingMode == SizingMode.laserGrade) {
      leftColumn = _buildLaserGradeControls(state, notifier);
    } else {
      leftColumn = Column(
        children: [
          _buildFixtureCard(state, notifier),
          const SizedBox(height: 20),
          if (state.sizingMode == SizingMode.drainage)
            _buildTrenchControls(state, notifier)
          else
            _buildPressureControls(notifier),
        ],
      );
    }

    final Widget rightColumn;
    if (state.sizingMode == SizingMode.laserGrade) {
      rightColumn = _buildLaserGradeReport(state);
    } else {
      rightColumn = _buildSizingReportCard(state);
    }

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isMobile ? 0 : 4,
          child: leftColumn,
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 3,
          child: Column(
            children: [
              if (isMobile) const SizedBox(height: 24),
              rightColumn,
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
      borderColor: Colors.white.withValues(alpha: 0.05),
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

  /// Singular fixture row layout with incremental adjustments.
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
      borderColor: Colors.white.withValues(alpha: 0.05),
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

  /// Static explanation for QLD water supply pressure guidelines.
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
      borderColor: alertColor.withValues(alpha: 0.2),
      backgroundGradient: [
        alertColor.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.01),
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
              color: alertColor.withValues(alpha: 0.1),
              border: Border.all(color: alertColor.withValues(alpha: 0.2)),
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
      borderColor: alertColor.withValues(alpha: 0.2),
      backgroundGradient: [
        alertColor.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.01),
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
          _buildWaterReportAlert(requiresBackflowDevice, totalLu),
        ],
      ),
    );
  }

  /// Helper rendering the warnings or successes inside the water report.
  Widget _buildWaterReportAlert(bool requiresBackflowDevice, int totalLu) {
    if (requiresBackflowDevice) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFFFB000).withValues(alpha: 0.1),
          border: Border.all(color: const Color(0xFFFFB000).withValues(alpha: 0.2)),
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
      );
    } else if (totalLu > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00FF87).withValues(alpha: 0.1),
          border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.2)),
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
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: const Text(
          'Specify fixtures above to generate hydraulic report.',
          style: TextStyle(fontSize: 12, color: Colors.white30),
        ),
      );
    }
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

  /// Builds the controls for Laser Grade and Staff Level calculations.
  Widget _buildLaserGradeControls(SizingState state, SizingNotifier notifier) {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laser Grade Setup Specifications',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Configure reference staff benchmark, run, and gradient parameters.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          _buildBenchmarkInput(state, notifier),
          const Divider(color: Colors.white12, height: 24),
          _buildExcavationOffsetInput(state, notifier),
          const Divider(color: Colors.white12, height: 24),
          _buildLaserRunSliders(state, notifier),
          const Divider(color: Colors.white12, height: 24),
          _buildGroundProfileControls(),
        ],
      ),
    );
  }

  /// Builds the setup benchmark staff reading input with increment buttons.
  Widget _buildBenchmarkInput(SizingState state, SizingNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Benchmark Start Staff (mm)',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            Text(
              '${state.setupStaffReading.toStringAsFixed(0)} mm',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00E6FF)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildIncrementButton(
                label: '-100',
                onPressed: () => notifier.updateSetupStaffReading(state.setupStaffReading - 100),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIncrementButton(
                label: '-10',
                onPressed: () => notifier.updateSetupStaffReading(state.setupStaffReading - 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIncrementButton(
                label: '+10',
                onPressed: () => notifier.updateSetupStaffReading(state.setupStaffReading + 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIncrementButton(
                label: '+100',
                onPressed: () => notifier.updateSetupStaffReading(state.setupStaffReading + 100),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper button layout for benchmark incremental adjustments.
  Widget _buildIncrementButton({required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  /// Builds the excavation offset depth slider input.
  Widget _buildExcavationOffsetInput(SizingState state, SizingNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trench Excavation Depth Offset (mm)',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            Text(
              '${state.excavationOffset.toStringAsFixed(0)} mm',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Allows for bedding sand thickness and pipe wall thickness below the invert line.',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
        ),
        Slider(
          value: state.excavationOffset,
          min: 0.0,
          max: 500.0,
          divisions: 50,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white12,
          onChanged: notifier.updateExcavationOffset,
        ),
      ],
    );
  }

  /// Builds run length and target grade sliders for the laser mode.
  Widget _buildLaserRunSliders(SizingState state, SizingNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Run Length: ${state.runLength.toStringAsFixed(1)} m',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        Slider(
          value: state.runLength,
          min: 1.0,
          max: 100.0,
          divisions: 99,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white12,
          onChanged: notifier.updateRunLength,
        ),
        const SizedBox(height: 8),
        Text(
          'Gradient (Target Slope): ${state.gradePercentage.toStringAsFixed(2)}%',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        Slider(
          value: state.gradePercentage,
          min: 0.5,
          max: 10.0,
          divisions: 95,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white12,
          onChanged: notifier.updateGradePercentage,
        ),
      ],
    );
  }

  /// Builds the ground profile adjustments (Start Cover, Ground Slope).
  Widget _buildGroundProfileControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ground Profile & Slopes',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start Soil Cover Depth (mm)',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
            Text(
              '${_startCover.toStringAsFixed(0)} mm',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: _startCover,
          min: 100.0,
          max: 1500.0,
          divisions: 28,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white12,
          onChanged: (val) => setState(() => _startCover = val),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ground Surface Downwards Slope (%)',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
            Text(
              '${_groundSlope.toStringAsFixed(2)}%',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: _groundSlope,
          min: 0.0,
          max: 10.0,
          divisions: 100,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white12,
          onChanged: (val) => setState(() => _groundSlope = val),
        ),
      ],
    );
  }

  /// Laser grade calculations report presenting sloped levels and cover alarms.
  Widget _buildLaserGradeReport(SizingState state) {
    // Ground Fall (mm) = Run * Ground Slope * 10
    final groundFall = state.runLength * _groundSlope * 10.0;
    // Downstream Cover = Start Cover + Pipe Fall - Ground Fall
    final downstreamCover = _startCover + state.requiredFallMm - groundFall;

    return Column(
      children: [
        GlassCard(
          borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.2),
          backgroundGradient: [
            const Color(0xFF00E6FF).withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.01),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LASER LEVEL REPORT (AS/NZS 3500.2)',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E6FF),
                  letterSpacing: 0.5,
                ),
              ),
              const Divider(color: Colors.white12, height: 20),
              _buildReportItem('Upstream Benchmark Staff', '${state.setupStaffReading.toStringAsFixed(0)} mm'),
              _buildReportItem('Total Pipe Vertical Fall', '${state.requiredFallMm.toStringAsFixed(1)} mm'),
              _buildReportItem('Downstream Invert Staff', '${state.downstreamInvertStaffReading.toStringAsFixed(1)} mm'),
              _buildReportItem('Downstream Trench Staff', '${state.downstreamTrenchStaffReading.toStringAsFixed(1)} mm'),
              _buildReportItem('Downstream Cover Depth', '${downstreamCover.toStringAsFixed(1)} mm'),
              const SizedBox(height: 16),
              _buildSoilCoverAlerts(downstreamCover),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildBlueprintCard(state, downstreamCover),
      ],
    );
  }

  /// Builds the real-time compliance alerts container for AS/NZS 3500.2 Clause 9.3 soil cover boundaries.
  Widget _buildSoilCoverAlerts(double coverMm) {
    final hasGardenAlert = coverMm < 300.0;
    final hasDrivewayAlert = coverMm < 500.0;
    final hasRoadAlert = coverMm < 750.0;

    final bool isAnyFail = hasGardenAlert || hasDrivewayAlert || hasRoadAlert;
    final alertColor = isAnyFail ? const Color(0xFFFF416C) : const Color(0xFF00FF87);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: alertColor.withValues(alpha: 0.1),
        border: Border.all(color: alertColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAnyFail ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                color: alertColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAnyFail ? 'AS/NZS 3500.2 Soil Cover Violation' : 'AS/NZS 3500.2 Cover Compliant',
                style: GoogleFonts.inter(fontSize: 12, color: alertColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCoverStatusLine('Paths/Gardens (Min 300mm):', coverMm >= 300.0, alertColor),
          const SizedBox(height: 4),
          _buildCoverStatusLine('Driveways (Min 500mm):', coverMm >= 500.0, alertColor),
          const SizedBox(height: 4),
          _buildCoverStatusLine('Roadway Surfaces (Min 750mm):', coverMm >= 750.0, alertColor),
        ],
      ),
    );
  }

  /// Helper row showing check/cross status of cover rules.
  Widget _buildCoverStatusLine(String label, bool isCompliant, Color defaultColor) {
    final statusColor = isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
        ),
        Row(
          children: [
            Icon(
              isCompliant ? Icons.check : Icons.close,
              color: statusColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isCompliant ? 'PASS' : 'FAIL',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ],
        ),
      ],
    );
  }

  /// Renders a beautiful visual blueprint diagram of the laser reference system.
  Widget _buildBlueprintCard(SizingState state, double coverMm) {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LASER SETUP BLUEPRINT DIAGRAM',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF060913),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: CustomPaint(
              painter: BlueprintPainter(
                grade: state.gradePercentage,
                fall: state.requiredFallMm,
                startStaff: state.setupStaffReading,
                excavationOffset: state.excavationOffset,
                cover: coverMm,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildBlueprintLabels(),
        ],
      ),
    );
  }

  /// Builds legend indicators and labels underneath the custom canvas blueprint.
  Widget _buildBlueprintLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBlueprintLabelIndicator('Laser Plane', Colors.redAccent),
        _buildBlueprintLabelIndicator('Pipe Invert', const Color(0xFF00FF87)),
        _buildBlueprintLabelIndicator('Trench Excavation', const Color(0xFFFFB000)),
        _buildBlueprintLabelIndicator('Staff Height', Colors.white60),
      ],
    );
  }

  /// Helper widget building a singular colored badge for the diagram legend.
  Widget _buildBlueprintLabelIndicator(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Painter that renders a sleek, premium high-fidelity engineering blueprint
/// of the laser level plane, sloped pipe line, and trench bed.
class BlueprintPainter extends CustomPainter {
  final double grade;
  final double fall;
  final double startStaff;
  final double excavationOffset;
  final double cover;

  BlueprintPainter({
    required this.grade,
    required this.fall,
    required this.startStaff,
    required this.excavationOffset,
    required this.cover,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLaser = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintTrench = Paint()
      ..color = const Color(0xFFFFB000).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintGround = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Laser Level Line (constant horizontal line near top)
    const laserY = 20.0;
    canvas.drawLine(const Offset(10, laserY), Offset(size.width - 10, laserY), paintLaser);

    // Ground line (sloped downwards)
    canvas.drawLine(const Offset(20, 50), Offset(size.width - 20, 75), paintGround);

    // Upstream and Downstream Pipe Invert levels
    const startPipeY = laserY + 45.0;
    final endPipeY = startPipeY + 20.0;

    // Draw sloped Pipe line
    final paintPipe = Paint()
      ..color = const Color(0xFF00FF87)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(40, startPipeY), Offset(size.width - 40, endPipeY), paintPipe);

    // Draw Trench line below pipe representing excavation offset
    final hasOffset = excavationOffset > 0;
    final trenchShift = hasOffset ? 12.0 : 0.0;
    canvas.drawLine(
      Offset(40, startPipeY + trenchShift),
      Offset(size.width - 40, endPipeY + trenchShift),
      paintTrench,
    );

    // Draw Staff poles
    final paintStaff = Paint()
      ..color = Colors.white60
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Upstream staff connecting laser level to invert
    canvas.drawLine(const Offset(40, laserY), const Offset(40, startPipeY), paintStaff);
    // Downstream staff connecting laser level to invert
    canvas.drawLine(Offset(size.width - 40, laserY), Offset(size.width - 40, endPipeY), paintStaff);
  }

  @override
  bool shouldRepaint(covariant BlueprintPainter oldDelegate) => true;
}
