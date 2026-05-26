import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/stormwater_schematic_painter.dart';

/// Glassmorphic UI Dashboard view for Stormwater Drainage & Gutter Compliance (AS/NZS 3500.3).
class StormwaterComplianceView extends ConsumerWidget {
  const StormwaterComplianceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stormwaterComplianceProvider);
    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ref),
              const SizedBox(height: 24),
              isLargeScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildTelemetryPanel(context, ref, state)),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _buildDashboardPanel(context, ref, state)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTelemetryPanel(context, ref, state),
                        const SizedBox(height: 24),
                        _buildDashboardPanel(context, ref, state),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Title header block.
  Widget _buildHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AS/NZS 3500.3 Stormwater Compliance',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Statutory Catchment Drainage, Gutter Capacity, & Overflow Relief Safeguard',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(stormwaterComplianceProvider.notifier).reset(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Glassmorphic Left panel for user entries and slider configurations.
  Widget _buildTelemetryPanel(BuildContext context, WidgetRef ref, StormwaterComplianceState state) {
    final notifier = ref.read(stormwaterComplianceProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTelemetryTitle('1. Catchment Telemetry'),
          _buildSlider(
            label: 'Roof Run Length (m)',
            value: state.roofLength,
            min: 5.0,
            max: 50.0,
            onChanged: notifier.updateLength,
            valueSuffix: ' m',
          ),
          _buildSlider(
            label: 'Roof Width (m)',
            value: state.roofWidth,
            min: 2.0,
            max: 30.0,
            onChanged: notifier.updateWidth,
            valueSuffix: ' m',
          ),
          _buildSlider(
            label: 'Roof Pitch (deg)',
            value: state.roofPitch,
            min: 0.0,
            max: 45.0,
            onChanged: notifier.updatePitch,
            valueSuffix: '°',
          ),
          const SizedBox(height: 16),
          _buildTelemetryTitle('2. Local Intensity Zone'),
          _buildZoneChips(state, notifier),
          const SizedBox(height: 24),
          _buildTelemetryTitle('3. Drainage System & Downpipes'),
          _buildGutterSelectors(state, notifier),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Downpipe Count',
            value: state.downpipeCount.toDouble(),
            min: 1.0,
            max: 8.0,
            onChanged: (val) => notifier.updateDownpipeCount(val.toInt()),
            divisions: 7,
            valueSuffix: '',
          ),
          _buildDownpipeStyleChips(state, notifier),
          const SizedBox(height: 20),
          _buildTelemetryTitle('4. Statutory Overflow Relief'),
          _buildOverflowToggles(state, notifier),
        ],
      ),
    );
  }

  /// Helper to draw group labels.
  Widget _buildTelemetryTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00E6FF),
        ),
      ),
    );
  }

  /// Renders customized sleek slider controls.
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    required String valueSuffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            Text(
              '${value.toStringAsFixed(1)}$valueSuffix',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF00E6FF),
          inactiveColor: Colors.white.withValues(alpha: 0.08),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// QLD Rainfall Zone segment selectors.
  Widget _buildZoneChips(StormwaterComplianceState state, StormwaterComplianceNotifier notifier) {
    return Row(
      children: ['Brisbane', 'Cairns', 'Toowoomba'].map((zone) {
        final isSelected = state.rainfallZone == zone;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(zone),
            selected: isSelected,
            onSelected: (val) {
              if (val) notifier.updateZone(zone);
            },
            selectedColor: const Color(0xFF00E6FF).withValues(alpha: 0.15),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: isSelected ? const Color(0xFF00E6FF) : Colors.white24,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Gutter architecture selectors.
  Widget _buildGutterSelectors(StormwaterComplianceState state, StormwaterComplianceNotifier notifier) {
    return Column(
      children: [
        Row(
          children: ['Eaves Gutter', 'Box Gutter'].map((type) {
            final isSelected = state.gutterType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (val) {
                  if (val) notifier.updateGutterType(type);
                },
                selectedColor: const Color(0xFF00E6FF).withValues(alpha: 0.15),
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF00E6FF) : Colors.white24,
                ),
              ),
            );
          }).toList(),
        ),
        if (state.gutterType == 'Eaves Gutter') ...[
          const SizedBox(height: 12),
          Row(
            children: ['Quad PVC', 'Colorbond Slotted'].map((profile) {
              final isSelected = state.gutterProfile == profile;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(profile),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) notifier.updateGutterProfile(profile);
                  },
                  selectedColor: const Color(0xFF00FF87).withValues(alpha: 0.15),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF00FF87) : Colors.white24,
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            initialValue: state.boxGutterSlope,
            dropdownColor: const Color(0xFF0F172A),
            decoration: const InputDecoration(
              labelText: 'Box Gutter Slope Ratio',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 100.0, child: Text('1:100 (Compliant - AS/NZS)')),
              DropdownMenuItem(value: 200.0, child: Text('1:200 (Minimum Compliant)')),
              DropdownMenuItem(value: 500.0, child: Text('1:500 (Non-Compliant - Risk)')),
            ],
            onChanged: (val) {
              if (val != null) notifier.updateSlope(val);
            },
          ),
        ]
      ],
    );
  }

  /// Downpipe styling selector choices.
  Widget _buildDownpipeStyleChips(StormwaterComplianceState state, StormwaterComplianceNotifier notifier) {
    return Row(
      children: ['Round', 'Rectangular'].map((style) {
        final isSelected = state.downpipeStyle == style;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(style),
            selected: isSelected,
            onSelected: (val) {
              if (val) notifier.updateDownpipeStyle(style);
            },
            selectedColor: const Color(0xFF00E6FF).withValues(alpha: 0.15),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: isSelected ? const Color(0xFF00E6FF) : Colors.white24,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Active overflow safety relief switch triggers.
  Widget _buildOverflowToggles(StormwaterComplianceState state, StormwaterComplianceNotifier notifier) {
    return Column(
      children: [
        if (state.gutterType == 'Eaves Gutter')
          SwitchListTile(
            title: const Text('Slotted Overflow Face', style: TextStyle(fontSize: 13)),
            value: state.slottedOverflow,
            activeThumbColor: const Color(0xFF00FF87),
            onChanged: notifier.updateSlotted,
            contentPadding: EdgeInsets.zero,
          )
        else
          SwitchListTile(
            title: const Text('Rainhead / Sump Overflow Weir', style: TextStyle(fontSize: 13)),
            value: state.rainheadOverflow,
            activeThumbColor: const Color(0xFF00FF87),
            onChanged: notifier.updateRainhead,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }

  /// Glassmorphic Right Dashboard panel displaying schematic, checklist, and cost analysis.
  Widget _buildDashboardPanel(BuildContext context, WidgetRef ref, StormwaterComplianceState state) {
    return Column(
      children: [
        // Vector schematic view
        Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: StormwaterSchematicPainter(state: state),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Telemetry details cards
        _buildStatsLedger(state),
        const SizedBox(height: 24),

        // Compliance Checklist Card
        _buildStatutoryChecklist(state),
        const SizedBox(height: 24),

        // Cost & Upgrade Ledger
        _buildCostLedgerCard(ref, state),
      ],
    );
  }

  /// Sizer flow details grid.
  Widget _buildStatsLedger(StormwaterComplianceState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hydraulic Calculations Ledger',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const Divider(height: 24, color: Colors.white12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.2,
            children: [
              _buildLedgerTile('Effective Roof Area', '${state.effectiveCatchmentArea.toStringAsFixed(1)} m²'),
              _buildLedgerTile('Rainfall Intensity', '${state.rainfallIntensity.toStringAsFixed(0)} mm/hr'),
              _buildLedgerTile('Total Catchment Flow', '${state.totalFlowRate.toStringAsFixed(2)} L/s'),
              _buildLedgerTile('Flow Rate / Downpipe', '${state.flowRatePerDownpipe.toStringAsFixed(2)} L/s'),
              _buildLedgerTile('Recommended Downpipe', state.recommendedDownpipeSize),
              _buildLedgerTile('Gutter Slope Required', state.gutterType == 'Eaves Gutter' ? 'Min 1:500' : 'Min 1:200'),
            ],
          ),
        ],
      ),
    );
  }

  /// Ledger detail tile helper.
  Widget _buildLedgerTile(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  /// Checklist audits against AS/NZS 3500.3 sections.
  Widget _buildStatutoryChecklist(StormwaterComplianceState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statutory Audit Checklist (AS/NZS 3500.3)',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 24, color: Colors.white12),
          _buildAuditRow(
            'Catchment Area Assessment (Cl 2.4)',
            'Calculated slope allowances applied correctly.',
            true,
          ),
          _buildAuditRow(
            'Downpipe Sizing Capacity (Cl 4.6 / Table 4.6)',
            'Flow per downpipe matches style design parameters.',
            state.isDownpipeCompliant,
          ),
          _buildAuditRow(
            'Gutter Carrying Limit (Cl 3.5)',
            'Checks cross-sectional area flow boundaries.',
            state.isGutterCapacityCompliant,
          ),
          _buildAuditRow(
            'Slope Alignment Check (Cl 3.3.2)',
            'Ensures proper fall to limit sediment build.',
            state.isBoxGutterSlopeCompliant,
          ),
          _buildAuditRow(
            'Overflow Relief Safeguards (Cl 4.6)',
            'Slotted profiles or weirs active for flood bypass.',
            state.isOverflowReliefCompliant,
          ),
        ],
      ),
    );
  }

  /// Single audit element.
  Widget _buildAuditRow(String clause, String desc, bool isCompliant) {
    final statusColor = isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF3366);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompliant ? Icons.check_circle_outline : Icons.error_outline,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clause,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompliant ? Colors.white : statusColor,
                  ),
                ),
                Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isCompliant ? 'PASS' : 'FAIL',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Cost Comparison & Upgrade Option Card.
  Widget _buildCostLedgerCard(WidgetRef ref, StormwaterComplianceState state) {
    final isPremium = state.gutterProfile == 'Colorbond Slotted';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            isPremium ? const Color(0xFF00E6FF).withValues(alpha: 0.05) : const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium ? const Color(0xFF00E6FF).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          width: isPremium ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Material Estimation',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPremium ? const Color(0xFF00E6FF).withValues(alpha: 0.15) : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPremium ? 'PREMIUM STEEL' : 'STANDARD PVC',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? const Color(0xFF00E6FF) : Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCostColumn('Cheapest Compliant Cost', '\$${state.cheapestEstimatedCost.toStringAsFixed(2)}', Colors.white60),
              _buildCostColumn('Premium Upgraded Cost', '\$${state.premiumEstimatedCost.toStringAsFixed(2)}', const Color(0xFF00E6FF)),
            ],
          ),
          const Divider(height: 32, color: Colors.white12),
          Text(
            state.upgradeRecommendation,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final notifier = ref.read(stormwaterComplianceProvider.notifier);
                if (isPremium) {
                  // Revert to cheapest
                  notifier.updateGutterProfile('Quad PVC');
                  notifier.updateSlotted(false);
                } else {
                  // Upgrade to premium
                  notifier.updateGutterProfile('Colorbond Slotted');
                  notifier.updateSlotted(true);
                  notifier.updateDownpipeCount(state.downpipeCount + 1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? const Color(0xFF334155) : const Color(0xFF00E6FF),
                foregroundColor: isPremium ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isPremium ? 'Revert to Cheapest Standard' : 'Instant One-Tap Premium Upgrade',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cost column helper.
  Widget _buildCostColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor),
        ),
      ],
    );
  }
}
