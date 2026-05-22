import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';
import '../providers/state_providers.dart';
import '../widgets/solar_schematic_painter.dart';

/// Comprehensive Solar & Heat Pump Compliance Sizer Screen.
/// Built using a premium glassmorphic dual-pane dashboard layout.
class SolarComplianceView extends ConsumerWidget {
  const SolarComplianceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 950) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 4, child: SingleChildScrollView(child: LeftTelemetryPanel())),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: SingleChildScrollView(child: RightDashboardPanel())),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const LeftTelemetryPanel(),
                        const SizedBox(height: 24),
                        RightDashboardPanel(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Page title and subtitle block.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOLAR & HEAT PUMP COMPLIANCE SIZER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify AS/NZS 3500.4 Section 8, thermal efficiency, valve coordination, and Legionella control',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

/// Left telemetry panel with input parameters and sliders.
class LeftTelemetryPanel extends ConsumerWidget {
  const LeftTelemetryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(solarComplianceProvider);
    final notifier = ref.read(solarComplianceProvider.notifier);

    return Column(
      children: [
        _buildGeneralDetailsCard(state, notifier),
        const SizedBox(height: 16),
        _buildSizingHelperCard(state, notifier),
        const SizedBox(height: 16),
        _buildValveCoordinationCard(state, notifier),
        const SizedBox(height: 16),
        _buildInstallationTogglesCard(state, notifier),
      ],
    );
  }

  Widget _buildGeneralDetailsCard(SolarComplianceState state, SolarComplianceNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('1. SYSTEM PARAMETERS'),
          const SizedBox(height: 12),
          _buildDropdown('Climate Region (AS/NZS 3500.4)', state.zone, ['Zone 1', 'Zone 2', 'Zone 3'], (v) {
            if (v != null) notifier.updateZone(v);
          }),
          const SizedBox(height: 12),
          _buildDropdown('Technology Type', state.techType, ['Solar Flat Plate', 'Solar Evacuated Tubes', 'Heat Pump'], (v) {
            if (v != null) notifier.updateTech(v);
          }),
          const SizedBox(height: 12),
          _buildDropdown('Collector Orientation', state.orientation, ['North', 'East', 'West', 'South'], (v) {
            if (v != null) notifier.updateOrientation(v);
          }),
          const SizedBox(height: 12),
          _buildSlider('Collector Tilt / Pitch', state.collectorTilt, 0, 60, (v) => notifier.updateTilt(v), '${state.collectorTilt.toStringAsFixed(0)}°'),
          const SizedBox(height: 12),
          _buildSlider('Collector Shading %', state.shadingFactor, 0, 80, (v) => notifier.updateShading(v), '${state.shadingFactor.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildSizingHelperCard(SolarComplianceState state, SolarComplianceNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('2. OCCUPANCY & DAILY DEMAND'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Bedrooms Guideline', '${state.bedrooms} Bed', ['1 Bed', '2 Bed', '3 Bed', '4 Bed', '5 Bed'], (v) {
                  if (v != null) {
                    notifier.updateBedrooms(int.parse(v.split(' ')[0]));
                    notifier.setDemandFromBedrooms();
                  }
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown('Occupants Count', '${state.occupants} Occupants', List.generate(10, (i) => '${i + 1} Occupants'), (v) {
                  if (v != null) {
                    notifier.updateOccupants(int.parse(v.split(' ')[0]));
                    notifier.setDemandFromOccupants();
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSlider('Daily Hot Water Demand', state.dailyDemand, 100, 500, (v) => notifier.updateDemand(v), '${state.dailyDemand.toStringAsFixed(0)} L/day'),
        ],
      ),
    );
  }

  Widget _buildValveCoordinationCard(SolarComplianceState state, SolarComplianceNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('3. VALVE COORDINATION CHAIN (AS/NZS 3500.4 Cl 5.4)'),
          const SizedBox(height: 12),
          _buildDropdown('PTR Valve Rating', '${state.ptrRatingKpa} kPa', ['850 kPa', '1000 kPa'], (v) {
            if (v != null) notifier.updatePtr(int.parse(v.split(' ')[0]));
          }),
          const SizedBox(height: 12),
          _buildDropdown('ECV Valve Rating', '${state.ecvRatingKpa} kPa', ['700 kPa', '850 kPa'], (v) {
            if (v != null) notifier.updateEcv(int.parse(v.split(' ')[0]));
          }),
          const SizedBox(height: 12),
          _buildSlider('Mains PLV Setting', state.plvSettingKpa.toDouble(), 150, 600, (v) => notifier.updatePlv(v.round()), '${state.plvSettingKpa} kPa'),
          const SizedBox(height: 8),
          _buildSlider('Tank Setpoint Temp', state.setpointTemp, 50, 75, (v) => notifier.updateSetpoint(v), '${state.setpointTemp.toStringAsFixed(0)}°C'),
        ],
      ),
    );
  }

  Widget _buildInstallationTogglesCard(SolarComplianceState state, SolarComplianceNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('4. INSTALLATION METHOD CONFIG'),
          const SizedBox(height: 12),
          _buildDropdown('Cylinder Location', state.isInternal ? 'Internal / Roofspace' : 'External Ground', ['Internal / Roofspace', 'External Ground'], (v) {
            if (v != null) notifier.updateInternal(v == 'Internal / Roofspace');
          }),
          const SizedBox(height: 12),
          _buildDropdown('Tempering Outlet Class', state.facilityType == 'Special' ? 'Special (45°C TMV)' : 'Standard (50°C Max)', ['Standard (50°C Max)', 'Special (45°C TMV)'], (v) {
            if (v != null) notifier.updateFacility(v.contains('Special') ? 'Special' : 'Standard');
          }),
          const SizedBox(height: 8),
          _buildSwitch('Safe Tray with Drain (AS/NZS 3500.4 Cl 4.6)', state.safeTrayInstalled, (v) => notifier.updateSafeTray(v)),
          _buildSwitch('Thermosiphon Heat Trap Loop (Cl 8.2.2)', state.heatTrapInstalled, (v) => notifier.updateHeatTrap(v)),
          _buildSwitch('Active Frost Protection (Cl 8.5)', state.hasFrostProtection, (v) => notifier.updateFrost(v)),
          _buildSwitch('Inlet Duo Valve Installed (Cl 5.2)', state.duoValveInstalled, (v) => notifier.updateDuoValve(v)),
          _buildSwitch('TPR Drain is Metallic Copper (Cl 5.12)', state.reliefIsCopper, (v) => notifier.updateReliefCopper(v)),
          const SizedBox(height: 8),
          _buildSlider('Boundary Distance', state.boundaryDistance, 0.5, 20.0, (v) => notifier.updateBoundary(v), '${state.boundaryDistance.toStringAsFixed(1)} m'),
        ],
      ),
    );
  }

  Widget _buildPanelTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.cyan, letterSpacing: 0.8),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.grey.shade900,
              isExpanded: true,
              value: value,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, String display) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
            Text(display, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.cyan,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.cyanAccent,
            overlayColor: Colors.cyan.withOpacity(0.2),
          ),
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70))),
        Switch(
          value: value,
          activeThumbColor: Colors.cyanAccent,
          activeTrackColor: Colors.cyan.withOpacity(0.5),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Right compliance dashboard rendering vector painter, pass/fail checks and savings ledger.
class RightDashboardPanel extends ConsumerWidget {
  const RightDashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(solarComplianceProvider);

    return Column(
      children: [
        _buildVectorCanvasCard(state),
        const SizedBox(height: 16),
        _buildStatutoryChecklist(state),
        const SizedBox(height: 16),
        _buildFinancialLedgerCard(state),
      ],
    );
  }

  Widget _buildVectorCanvasCard(SolarComplianceState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTERACTIVE THERMAL & VALVING SCHEMATIC',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.cyan, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: state.isFullyCompliant ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.isFullyCompliant ? 'PASS AS/NZS' : 'FAILING CHECK',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: state.isFullyCompliant ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: SolarSchematicPainter(state: state),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryChecklist(SolarComplianceState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATUTORY COMPLIANCE CHECKLIST', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.cyan, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          _buildCheckRow('Legionella Prevention (Cl 4.2)', state.isLegionellaCompliant, 'Stored Temp must be >= 60°C to prevent biological colonization.'),
          _buildCheckRow('PLV Coordination setting (Cl 5.4)', state.isPlvCompliant, 'PLV outlet pressure must not exceed 500 kPa boundary limits.'),
          _buildCheckRow('ECV Valve margin (Cl 5.4)', state.isEcvCompliant, 'ECV pressure setting must be >= PLV + 100 kPa delta clearance.'),
          _buildCheckRow('PTR Relief margin (Cl 5.4)', state.isPtrCompliant, 'PTR relief valve must be >= ECV + 150 kPa delta coordination.'),
          _buildCheckRow('Internal Safe Tray (Cl 4.6)', state.isSafeTrayCompliant, 'Internal installations require corrosion-proof safe tray & drain.'),
          _buildCheckRow('Relief Line metallic (Cl 5.12)', state.isReliefLineCompliant, 'Relief drainage lines must be Copper (PVC/PE strictly prohibited).'),
          _buildCheckRow('Inlet Duo check valve (Cl 5.2)', state.isDuoValveCompliant, 'Cold feed requires combined isolating & non-return check valve.'),
          _buildCheckRow('Acoustic boundary clearance', state.isAcousticCompliant, 'Compressor should keep >= 3m boundary buffer (QLD EPA noise cap).'),
          _buildCheckRow('Frost protection (Cl 8.5)', state.isFrostCompliant, 'Zone 3 (Darling Downs) requires active frost valve or glycol loop.'),
          if (state.requiresCycloneMounting)
            _buildCautionRow('Cyclone Framing (AS/NZS 1170.2)', 'Zone 1 (Tropical North) solar collectors must use wind region C/D certified mounts.'),
          if (state.requiresWhsRoofHarness)
            _buildCautionRow('WHS Roof Safety Access', 'Collector tilt/roof pitch exceeds 30°. Fixed anchors & ladder clips required.'),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String title, bool pass, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(pass ? Icons.check_circle_outline : Icons.cancel_outlined, color: pass ? Colors.greenAccent : Colors.redAccent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(desc, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCautionRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                Text(desc, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialLedgerCard(SolarComplianceState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ENERGY SAVINGS & REBATES LEDGER', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.cyan, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCell('Estimated STCs', '${state.calculatedStcs.toStringAsFixed(1)} Certificates', Colors.tealAccent),
              _buildMetricCell('STC Rebate (AUD)', '\$${state.estimatedStcRebate.toStringAsFixed(0)}', Colors.tealAccent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCell('Annual Savings (AUD)', '\$${state.annualSavingsAud.toStringAsFixed(0)} / yr', Colors.greenAccent),
              _buildMetricCell('Carbon Footprint Down', '${state.annualCarbonReductionKg.toStringAsFixed(0)} kg CO2 / yr', Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flash_on_outlined, color: Colors.yellowAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RECOMMENDED BOOSTER DISINFECTION TIMING', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                      const SizedBox(height: 2),
                      Text(state.recommendedBoostSchedule, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCell(String title, String val, Color highlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
        Text(val, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: highlight)),
      ],
    );
  }
}
