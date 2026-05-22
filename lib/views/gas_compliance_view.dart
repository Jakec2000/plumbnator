import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/gas_schematic_painter.dart';

/// Glassmorphic UI Dashboard view for Gas Fitting Pipe Sizing & Ventilation Compliance (AS/NZS 5601.1).
class GasComplianceView extends ConsumerWidget {
  const GasComplianceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gasComplianceProvider);
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
              'AS/NZS 5601.1 Gas Pipe Sizer & Ventilation Auditor',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pipeline Load Friction Drop sizer and Room Ventilation Aperture Audit',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(gasComplianceProvider.notifier).reset(),
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

  /// Left panel for gas inputs.
  Widget _buildTelemetryPanel(BuildContext context, WidgetRef ref, GasComplianceState state) {
    final notifier = ref.read(gasComplianceProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTelemetryTitle('1. Gas Source & Fuel Type'),
          _buildGasTypeChips(state, notifier),
          const SizedBox(height: 20),
          _buildTelemetryTitle('2. Pipeline Telemetry'),
          _buildMaterialChips(state, notifier),
          const SizedBox(height: 12),
          _buildSlider(
            label: 'Total Appliance Load (MJ/h)',
            value: state.totalLoad,
            min: 10.0,
            max: 300.0,
            onChanged: notifier.updateLoad,
            valueSuffix: ' MJ/h',
          ),
          _buildSlider(
            label: 'Pipe Run Length (m)',
            value: state.pipeLength,
            min: 1.0,
            max: 80.0,
            onChanged: notifier.updateLength,
            valueSuffix: ' m',
          ),
          _buildDiameterDropdown(state, notifier),
          const SizedBox(height: 24),
          _buildTelemetryTitle('3. Ventilation Space Audit'),
          _buildSlider(
            label: 'Room Volume (m³)',
            value: state.roomVolume,
            min: 2.0,
            max: 100.0,
            onChanged: notifier.updateVolume,
            valueSuffix: ' m³',
          ),
          _buildSlider(
            label: 'Aperture Free Area (mm²)',
            value: state.ventFreeArea,
            min: 0.0,
            max: 100000.0,
            divisions: 100,
            onChanged: notifier.updateVentArea,
            valueSuffix: ' mm²',
          ),
          SwitchListTile(
            title: const Text('Vents Correctly Aligned (Upper/Lower)', style: TextStyle(fontSize: 13)),
            value: state.ventsProperlyPositioned,
            activeThumbColor: const Color(0xFF00E6FF),
            onChanged: notifier.updateVentPositioned,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildTelemetryTitle('4. Safety Devices'),
          _buildSafetyToggles(state, notifier),
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

  /// Slider helper.
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
          inactiveColor: Colors.white.withOpacity(0.08),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Gas source type selector.
  Widget _buildGasTypeChips(GasComplianceState state, GasComplianceNotifier notifier) {
    return Row(
      children: ['Natural Gas', 'LPG'].map((type) {
        final isSelected = state.gasType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (val) {
              if (val) notifier.updateGasType(type);
            },
            selectedColor: const Color(0xFF00E6FF).withOpacity(0.15),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: isSelected ? const Color(0xFF00E6FF) : Colors.white24,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Pipe material type selector.
  Widget _buildMaterialChips(GasComplianceState state, GasComplianceNotifier notifier) {
    return Row(
      children: ['Copper', 'PEX-AL-PEX'].map((mat) {
        final isSelected = state.pipeMaterial == mat;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(mat),
            selected: isSelected,
            onSelected: (val) {
              if (val) notifier.updateMaterial(mat);
            },
            selectedColor: const Color(0xFF00FF87).withOpacity(0.15),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: isSelected ? const Color(0xFF00FF87) : Colors.white24,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Dropdown for Nominal Diameters.
  Widget _buildDiameterDropdown(GasComplianceState state, GasComplianceNotifier notifier) {
    return DropdownButtonFormField<String>(
      initialValue: state.pipeDiameter,
      dropdownColor: const Color(0xFF0F172A),
      decoration: const InputDecoration(
        labelText: 'Nominal Pipe Diameter (DN)',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'DN15', child: Text('DN15 (Small load)')),
        DropdownMenuItem(value: 'DN20', child: Text('DN20 (Standard load)')),
        DropdownMenuItem(value: 'DN25', child: Text('DN25 (Medium load)')),
        DropdownMenuItem(value: 'DN32', child: Text('DN32 (High load)')),
        DropdownMenuItem(value: 'DN40', child: Text('DN40 (Commercial load)')),
      ],
      onChanged: (val) {
        if (val != null) notifier.updateDiameter(val);
      },
    );
  }

  /// Safety device switches.
  Widget _buildSafetyToggles(GasComplianceState state, GasComplianceNotifier notifier) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Combined Pressure Regulator', style: TextStyle(fontSize: 13)),
          value: state.regulatorInstalled,
          activeThumbColor: const Color(0xFF00E6FF),
          onChanged: notifier.updateRegulator,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Auto Solenoid Leak Shutoff', style: TextStyle(fontSize: 13)),
          value: state.hasSolenoidShutoff,
          activeThumbColor: const Color(0xFF00FF87),
          onChanged: notifier.updateSolenoid,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Glassmorphic Right Dashboard panel displaying schematic, checklist, and cost analysis.
  Widget _buildDashboardPanel(BuildContext context, WidgetRef ref, GasComplianceState state) {
    return Column(
      children: [
        // Vector schematic view
        Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: GasSchematicPainter(state: state),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Alarm status card for confined room ventilation limits
        if (state.isConfinedSpace) _buildConfinedRoomAlarmCard(state),
        const SizedBox(height: 16),

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

  /// Renders confined space warning callout.
  Widget _buildConfinedRoomAlarmCard(GasComplianceState state) {
    final hasEnoughVent = state.isVentilationCompliant;
    final warningColor = hasEnoughVent ? const Color(0xFFFF9900) : const Color(0xFFFF3366);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningColor.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: warningColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFINED ROOM DETECTED (Clause 6.4)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: warningColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Room volume is under the 0.07 m³/MJ/h limit. Required minimum free-air ventilation aperture area is ${state.requiredVentilationArea.toStringAsFixed(0)} mm².',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sizer flow details grid.
  Widget _buildStatsLedger(GasComplianceState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
              _buildLedgerTile('Gas Flow Rate', '${state.gasFlowRate.toStringAsFixed(2)} m³/h'),
              _buildLedgerTile('Calculated Pressure Drop', '${state.calculatedPressureDrop.toStringAsFixed(4)} kPa'),
              _buildLedgerTile('Max Allowed Drop', '${state.maxAllowedPressureDrop.toStringAsFixed(3)} kPa'),
              _buildLedgerTile('Nominal Inner Diameter', '${state.innerDiameter.toStringAsFixed(1)} mm'),
              _buildLedgerTile('Required Vent Area', '${state.requiredVentilationArea.toStringAsFixed(0)} mm²'),
              _buildLedgerTile('Ventilation Type', state.isConfinedSpace ? 'Confined (Requires Vents)' : 'Unconfined (Standard Room)'),
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

  /// Checklist audits against AS/NZS 5601.1 sections.
  Widget _buildStatutoryChecklist(GasComplianceState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statutory Audit Checklist (AS/NZS 5601.1)',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 24, color: Colors.white12),
          _buildAuditRow(
            'Gas Pressure Drop Limit (Cl 5.1.1 / App F)',
            'Checks low-pressure piping drop parameters.',
            state.isPressureDropCompliant,
          ),
          _buildAuditRow(
            'Room Ventilation Aperture (Cl 6.4)',
            'Checks free-air flow and vent positioning.',
            state.isVentilationCompliant,
          ),
          _buildAuditRow(
            'Regulator Installation (Cl 5.2.1)',
            'Verifies gas flow safety isolation and regulators.',
            state.isRegulatorCompliant,
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
              color: statusColor.withOpacity(0.12),
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
  Widget _buildCostLedgerCard(WidgetRef ref, GasComplianceState state) {
    final isPremium = state.pipeMaterial == 'PEX-AL-PEX';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            isPremium ? const Color(0xFF00FF87).withOpacity(0.05) : const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium ? const Color(0xFF00FF87).withOpacity(0.2) : Colors.white.withOpacity(0.05),
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
                  color: isPremium ? const Color(0xFF00FF87).withOpacity(0.15) : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPremium ? 'PREMIUM PEX-AL-PEX' : 'STANDARD COPPER',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? const Color(0xFF00FF87) : Colors.white60,
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
              _buildCostColumn('Premium Upgraded Cost', '\$${state.premiumEstimatedCost.toStringAsFixed(2)}', const Color(0xFF00FF87)),
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
                final notifier = ref.read(gasComplianceProvider.notifier);
                if (isPremium) {
                  // Revert to cheapest
                  notifier.updateMaterial('Copper');
                  notifier.updateSolenoid(false);
                } else {
                  // Upgrade to premium
                  notifier.updateMaterial('PEX-AL-PEX');
                  notifier.updateSolenoid(true);
                  notifier.updateDiameter('DN20'); // Ensure compliant sizing
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? const Color(0xFF334155) : const Color(0xFF00FF87),
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
