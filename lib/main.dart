import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/ai_compliance_view.dart';
import 'views/dashboard_view.dart';
import 'views/qbcc_form4_view.dart';
import 'views/sizing_calculator_view.dart';
import 'views/whs_swms_view.dart';
import 'views/backflow_calculator_view.dart';
import 'views/drainage_sketcher_view.dart';
import 'views/standards_library_view.dart';
import 'views/solar_compliance_view.dart';
import 'views/stormwater_compliance_view.dart';
import 'views/gas_compliance_view.dart';
import 'providers/state_providers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Safe diagnostic printout when running in decoupled sandbox
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The root application widget setting up styling themes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plumbnator QLD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B14),
        primaryColor: const Color(0xFF00E6FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E6FF),
          secondary: Color(0xFF00FF87),
          surface: Color(0xFF0A0F1D),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const NavigationShell(),
    );
  }
}

/// The responsive layout shell managing navigation states and presenting active views.
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  final List<Widget> _views = const [
    DashboardView(),
    AiComplianceView(),
    SizingCalculatorView(),
    QbccForm4View(),
    WhsSwmsView(),
    BackflowCalculatorView(),
    DrainageSketcherView(),
    StandardsLibraryView(),
    SolarComplianceView(),
    StormwaterComplianceView(),
    GasComplianceView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;
    final currentIndex = ref.watch(navProvider);

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
                onTap: () => ref.read(navProvider.notifier).setIndex(0),
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
                  color: Colors.white.withOpacity(0.05),
                  height: 1.0,
                ),
              ),
            )
          : null,
      drawer: !isLargeScreen
          ? Drawer(
              backgroundColor: const Color(0xFF0A0F1D),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.05),
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
                          _buildDrawerItem(0, 'Dashboard', Icons.dashboard_customize_outlined, currentIndex),
                          _buildDrawerItem(1, 'AI Vision Audit', Icons.psychology_outlined, currentIndex),
                          _buildDrawerItem(2, 'Hydraulic Sizer', Icons.plumbing_outlined, currentIndex),
                          _buildDrawerItem(3, 'QBCC Form 4', Icons.assignment_outlined, currentIndex),
                          _buildDrawerItem(4, 'WHS SWMS', Icons.gavel_outlined, currentIndex),
                          _buildDrawerItem(5, 'Backflow Tests', Icons.water_drop_outlined, currentIndex),
                          _buildDrawerItem(6, 'Drainage Plan', Icons.gesture_outlined, currentIndex),
                          _buildDrawerItem(7, 'Standards Library', Icons.menu_book_outlined, currentIndex),
                          _buildDrawerItem(8, 'Solar / Heat Pump', Icons.solar_power_outlined, currentIndex),
                          _buildDrawerItem(9, 'Stormwater Sizer', Icons.thunderstorm_outlined, currentIndex),
                          _buildDrawerItem(10, 'Gas Pipe Sizer', Icons.local_fire_department_outlined, currentIndex),
                        ],
                      ),
                    ),
                    _buildLicenseFooter(),
                  ],
                ),
              ),
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
              if (isLargeScreen) _buildSidebarRail(currentIndex),
              Expanded(
                child: _views[currentIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isLargeScreen ? _buildBottomNavBar(currentIndex) : null,
    );
  }

  /// Sidebar navigation rail for desktop and web layouts.
  Widget _buildSidebarRail(int currentIndex) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D).withOpacity(0.8),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarBrand(),
          const SizedBox(height: 24),
          _buildSidebarItem(0, 'Dashboard', Icons.dashboard_customize_outlined, currentIndex),
          _buildSidebarItem(1, 'AI Vision Audit', Icons.psychology_outlined, currentIndex),
          _buildSidebarItem(2, 'Hydraulic Sizer', Icons.plumbing_outlined, currentIndex),
          _buildSidebarItem(3, 'QBCC Form 4', Icons.assignment_outlined, currentIndex),
          _buildSidebarItem(4, 'WHS SWMS', Icons.gavel_outlined, currentIndex),
          _buildSidebarItem(5, 'Backflow Tests', Icons.water_drop_outlined, currentIndex),
          _buildSidebarItem(6, 'Drainage Plan', Icons.gesture_outlined, currentIndex),
          _buildSidebarItem(7, 'Standards Library', Icons.menu_book_outlined, currentIndex),
          _buildSidebarItem(8, 'Solar / Heat Pump', Icons.solar_power_outlined, currentIndex),
          _buildSidebarItem(9, 'Stormwater Sizer', Icons.thunderstorm_outlined, currentIndex),
          _buildSidebarItem(10, 'Gas Pipe Sizer', Icons.local_fire_department_outlined, currentIndex),
          const Spacer(),
          _buildLicenseFooter(),
        ],
      ),
    );
  }

  /// Title branding header inside the sidebar.
  Widget _buildSidebarBrand() {
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

  /// Custom list tile buttons for the sidebar layout.
  Widget _buildSidebarItem(int index, String title, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => ref.read(navProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E6FF).withOpacity(0.08) : Colors.transparent,
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

  /// Custom list tile buttons for the drawer layout in mobile view.
  Widget _buildDrawerItem(int index, String title, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          ref.read(navProvider.notifier).setIndex(index);
          Navigator.of(context).pop(); // Close drawer
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E6FF).withOpacity(0.08) : Colors.transparent,
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

  /// Standard bottom navigation bar for mobile size displays.
  Widget _buildBottomNavBar(int currentIndex) {
    return NavigationBar(
      selectedIndex: currentIndex >= 9 ? 0 : currentIndex,
      onDestinationSelected: (idx) => ref.read(navProvider.notifier).setIndex(idx),
      backgroundColor: const Color(0xFF0A0F1D),
      indicatorColor: const Color(0xFF00E6FF).withOpacity(0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_customize_outlined),
          selectedIcon: Icon(Icons.dashboard_customize, color: Color(0xFF00E6FF)),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology, color: Color(0xFF00E6FF)),
          label: 'AI Audit',
        ),
        NavigationDestination(
          icon: Icon(Icons.plumbing_outlined),
          selectedIcon: Icon(Icons.plumbing, color: Color(0xFF00E6FF)),
          label: 'Sizer',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: Color(0xFF00E6FF)),
          label: 'Form 4',
        ),
        NavigationDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel, color: Color(0xFF00E6FF)),
          label: 'SWMS',
        ),
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop, color: Color(0xFF00E6FF)),
          label: 'Backflow',
        ),
        NavigationDestination(
          icon: Icon(Icons.gesture_outlined),
          selectedIcon: Icon(Icons.gesture, color: Color(0xFF00E6FF)),
          label: 'Sketcher',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book, color: Color(0xFF00E6FF)),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.solar_power_outlined),
          selectedIcon: Icon(Icons.solar_power, color: Color(0xFF00E6FF)),
          label: 'Solar/HP',
        ),
      ],
    );
  }

  /// Renders a footer with local licencing info in the sidebar.
  Widget _buildLicenseFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Licensed to: QLD Plumbers',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 3.0.0 (AS/NZS 3500)',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

