import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ai_compliance_view.dart';
import '../standards_library_view.dart';
import '../drainage_sketcher_view.dart';

/// Hub view for grouping all statutory standards, drawings and AI compliance.
class ComplianceHubView extends ConsumerStatefulWidget {
  /// Creates a [ComplianceHubView] instance.
  const ComplianceHubView({super.key});

  @override
  ConsumerState<ComplianceHubView> createState() => _ComplianceHubViewState();
}

class _ComplianceHubViewState extends ConsumerState<ComplianceHubView> {
  int _activeTab = 0; // 0: AI Compliance, 1: Standards Search, 2: Drainage Sketcher

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
          'COMPLIANCE & PLANS',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Audit compliance via spatial AI, inspect AS/NZS 3500 codes, and draw high-res site plans.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Tab selector supporting the compliance tools.
  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(0, 'AI Vision Audit', Icons.remove_red_eye_outlined),
          const SizedBox(width: 8),
          _buildTabButton(1, 'Standards Code', Icons.menu_book_outlined),
          const SizedBox(width: 8),
          _buildTabButton(2, 'Drainage Sketcher', Icons.draw_outlined),
        ],
      ),
    );
  }

  /// Generates visual tab button with HSL neon accents.
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
        return const AiComplianceView();
      case 1:
        return const StandardsLibraryView();
      case 2:
        return const DrainageSketcherView();
      default:
        return const AiComplianceView();
    }
  }
}
