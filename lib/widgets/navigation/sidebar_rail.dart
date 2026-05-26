import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_providers.dart';
import '../../services/standards_search_service.dart';

/// Sidebar navigation rail for desktop and web layouts.
class SidebarRail extends ConsumerWidget {
  /// The currently active navigation index.
  final int currentIndex;

  /// Creates a [SidebarRail].
  const SidebarRail({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D).withValues(alpha: 0.8),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00E6FF).withValues(alpha: 0.06),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarBrand(ref),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSectionLabel('PLUMBING SYSTEM'),
                  _buildSidebarItem(ref, 0, 'Operations Hub', Icons.dashboard_customize_outlined, currentIndex),
                  _buildSidebarItem(ref, 1, 'Sizers Hub', Icons.calculate_outlined, currentIndex),
                  _buildSidebarItem(ref, 2, 'Field Docs Hub', Icons.assignment_outlined, currentIndex),
                  _buildSidebarItem(ref, 3, 'Compliance & Plans', Icons.gavel_outlined, currentIndex),
                ],
              ),
            ),
          ),
          _buildLicenseFooter(),
        ],
      ),
    );
  }

  /// Title branding header inside the sidebar.
  Widget _buildSidebarBrand(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: () => ref.read(navProvider.notifier).setIndex(0),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
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
        ),
      ),
    );
  }

  /// Section label divider for grouped sidebar categories.
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, bottom: 8.0, top: 4.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Colors.white24,
        ),
      ),
    );
  }

  /// Custom list tile buttons for the sidebar layout with active glow.
  Widget _buildSidebarItem(WidgetRef ref, int index, String title, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: InkWell(
        onTap: () => ref.read(navProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E6FF).withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.15))
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E6FF).withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: themeColor, size: 18),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00E6FF),
                  ),
                ),
              ],
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
