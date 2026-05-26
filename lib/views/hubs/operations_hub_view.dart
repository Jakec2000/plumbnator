import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_view.dart';
import '../aqua_forge/role_selection_view.dart';
import 'takeoff_workspace.dart';
import 'ar_room_scanner_view.dart';

/// The Operations Hub view consolidating contractor dashboards and AquaForge AI access.
class OperationsHubView extends ConsumerStatefulWidget {
  /// Creates an [OperationsHubView] instance.
  const OperationsHubView({super.key});

  @override
  ConsumerState<OperationsHubView> createState() => _OperationsHubViewState();
}

class _OperationsHubViewState extends ConsumerState<OperationsHubView> {
  int _activeTab = 3; // 0: Job Workspace, 1: AquaForge AI, 2: AI Takeoff, 3: AR Scan & Quote

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
            child: _buildActiveView(),
          ),
        ],
      ),
    );
  }

  /// Renders title branding header for the Operations workspace.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPERATIONS HUB',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage active plumbing jobs and consult next-gen spatial AI tools.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Custom segmented tab buttons to toggle dashboards.
  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(0, 'Job Workspace', Icons.dashboard_customize_outlined),
          const SizedBox(width: 8),
          _buildTabButton(1, 'AquaForge AI', Icons.water_drop_outlined),
          const SizedBox(width: 8),
          _buildTabButton(2, 'AI Takeoff', Icons.document_scanner_outlined),
          const SizedBox(width: 8),
          _buildTabButton(3, 'AR Scan & Quote', Icons.threed_rotation_outlined),
        ],
      ),
    );
  }

  /// Renders a single tab selector button.
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

  /// Selects view to render based on tab selections
  Widget _buildActiveView() {
    switch (_activeTab) {
      case 0:
        return const DashboardView();
      case 1:
        return const RoleSelectionScreen();
      case 2:
        return const TakeoffWorkspace();
      case 3:
        return const ArRoomScannerView();
      default:
        return const DashboardView();
    }
  }
}
