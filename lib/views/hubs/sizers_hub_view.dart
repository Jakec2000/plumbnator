import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sizing_calculator_view.dart';
import '../gas_compliance_view.dart';
import '../stormwater_compliance_view.dart';
import '../solar_compliance_view.dart';

/// Hub view for grouping all calculator and sizing engines.
class SizersHubView extends ConsumerStatefulWidget {
  /// Creates a [SizersHubView] instance.
  const SizersHubView({super.key});

  @override
  ConsumerState<SizersHubView> createState() => _SizersHubViewState();
}

class _SizersHubViewState extends ConsumerState<SizersHubView> {
  int _activeTab = 0; // 0: Hydraulic, 1: Gas, 2: Stormwater, 3: Solar

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTabSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildActiveCalculator(),
          ),
        ],
      ),
    );
  }

  /// Title branding and description.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIZING ENGINES',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Run certified calculations across hydraulic, stormwater, gas, and hot water systems.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Glassmorphic tab selector supporting the four distinct sizers.
  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(0, 'Hydraulic', Icons.water_outlined),
          const SizedBox(width: 8),
          _buildTabButton(1, 'Gas Sizer', Icons.local_fire_department_outlined),
          const SizedBox(width: 8),
          _buildTabButton(2, 'Stormwater', Icons.cloudy_snowing),
          const SizedBox(width: 8),
          _buildTabButton(3, 'Solar & Hot Water', Icons.wb_sunny_outlined),
        ],
      ),
    );
  }

  /// Generates visual tab button with HSL-themed custom borders.
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    final color = isSelected ? const Color(0xFF00E6FF) : Colors.white24;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color(0xFF00E6FF).withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.01),
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 0.3 : 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E6FF) : Colors.white54,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Matches internal index to active sub-view.
  Widget _buildActiveCalculator() {
    switch (_activeTab) {
      case 0:
        return const SizingCalculatorView();
      case 1:
        return const GasComplianceView();
      case 2:
        return const StormwaterComplianceView();
      case 3:
        return const SolarComplianceView();
      default:
        return const SizingCalculatorView();
    }
  }
}
