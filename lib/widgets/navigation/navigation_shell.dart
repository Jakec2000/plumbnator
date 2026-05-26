import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'sidebar_rail.dart';
import 'app_drawer.dart';

/// The responsive layout shell managing navigation states and presenting active views.
class NavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      appBar: !isLargeScreen
          ? AppBar(
              backgroundColor: const Color(0xFF0A0F1D),
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFF00E6FF)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: InkWell(
                onTap: () => widget.navigationShell.goBranch(0),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.electric_bolt,
                        color: Color(0xFF00E6FF),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PLUMBNATOR',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1.0,
                ),
              ),
            )
          : null,
      drawer: !isLargeScreen
          ? AppDrawer(
              currentIndex: currentIndex,
              onDestinationSelected: (idx) => widget.navigationShell.goBranch(idx),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0F1D),
              Color(0xFF05070E),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isLargeScreen)
                SidebarRail(
                  currentIndex: currentIndex,
                  onDestinationSelected: (idx) => widget.navigationShell.goBranch(idx),
                ),
              Expanded(
                child: widget.navigationShell,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isLargeScreen ? _buildBottomNavBar(currentIndex) : null,
    );
  }

  /// Standard bottom navigation bar for mobile size displays.
  Widget _buildBottomNavBar(int currentIndex) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (idx) {
        widget.navigationShell.goBranch(idx);
      },
      backgroundColor: const Color(0xFF0A0F1D),
      indicatorColor: const Color(0xFF00E6FF).withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_customize_outlined),
          selectedIcon: Icon(Icons.dashboard_customize, color: Color(0xFF00E6FF)),
          label: 'Operations',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate, color: Color(0xFF00E6FF)),
          label: 'Sizers',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: Color(0xFF00E6FF)),
          label: 'Field Docs',
        ),
        NavigationDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel, color: Color(0xFF00E6FF)),
          label: 'Compliance',
        ),
      ],
    );
  }
}
