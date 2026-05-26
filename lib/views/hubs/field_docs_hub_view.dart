import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../qbcc_form4_view.dart';
import '../whs_swms_view.dart';
import '../backflow_calculator_view.dart';

/// Hub view for grouping all statutory forms and field documents.
class FieldDocsHubView extends ConsumerStatefulWidget {
  /// Creates a [FieldDocsHubView] instance.
  const FieldDocsHubView({super.key});

  @override
  ConsumerState<FieldDocsHubView> createState() => _FieldDocsHubViewState();
}

class _FieldDocsHubViewState extends ConsumerState<FieldDocsHubView> {
  int _activeTab = 0; // 0: Form 4, 1: WHS SWMS, 2: Backflow

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
            child: _buildActiveDoc(),
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
          'FIELD DOCUMENTS',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete and submit mandatory statutory certificates, safety sheets, and backflow tests.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Tab selector supporting the field forms.
  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(0, 'QBCC Form 4', Icons.assignment_turned_in_outlined),
          const SizedBox(width: 8),
          _buildTabButton(1, 'WHS SWMS', Icons.shield_outlined),
          const SizedBox(width: 8),
          _buildTabButton(2, 'Backflow Tests', Icons.history_edu_outlined),
        ],
      ),
    );
  }

  /// Generates visual tab button with glassmorphic styles.
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
  Widget _buildActiveDoc() {
    switch (_activeTab) {
      case 0:
        return const QbccForm4View();
      case 1:
        return const WhsSwmsView();
      case 2:
        return const BackflowCalculatorView();
      default:
        return const QbccForm4View();
    }
  }
}
