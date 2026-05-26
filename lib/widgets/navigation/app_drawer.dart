import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/standards_search_service.dart';

/// AppDrawer for mobile layouts.
class AppDrawer extends ConsumerWidget {
  /// The currently active navigation index.
  final int currentIndex;

  /// Callback when a navigation destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Creates an [AppDrawer].
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0F1D),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.electric_bolt,
                          color: Color(0xFF00E6FF),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PLUMBNATOR',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildDrawerItem(context, ref, 0, 'Operations Hub', Icons.dashboard_customize_outlined, currentIndex),
                  _buildDrawerItem(context, ref, 1, 'Sizers Hub', Icons.calculate_outlined, currentIndex),
                  _buildDrawerItem(context, ref, 2, 'Field Docs Hub', Icons.assignment_outlined, currentIndex),
                  _buildDrawerItem(context, ref, 3, 'Compliance & Plans', Icons.gavel_outlined, currentIndex),
                ],
              ),
            ),
            _buildLicenseFooter(),
          ],
        ),
      ),
    );
  }

  /// Custom list tile buttons for the drawer layout in mobile view.
  Widget _buildDrawerItem(BuildContext context, WidgetRef ref, int index, String title, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          onDestinationSelected(index);
          Navigator.of(context).pop(); // Close drawer
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E6FF).withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: themeColor, size: 20),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders a footer with local licencing info and standards loading status.
  Widget _buildLicenseFooter() {
    final searchService = StandardsSearchService();
    final docsLoaded = searchService.documentCount;
    final totalChars = searchService.totalCharactersLoaded;
    final mbLoaded = (totalChars / 1024 / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (docsLoaded > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00FF87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$docsLoaded AS/NZS docs loaded ($mbLoaded MB)',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00FF87).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Licensed to: QLD Plumbers',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 3.1.0 (AS/NZS 3500)',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
