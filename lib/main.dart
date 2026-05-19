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
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    DashboardView(),
    AiComplianceView(),
    SizingCalculatorView(),
    QbccForm4View(),
    WhsSwmsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
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
              if (isLargeScreen) _buildSidebarRail(),
              Expanded(
                child: _views[_currentIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isLargeScreen ? _buildBottomNavBar() : null,
    );
  }

  /// Sidebar navigation rail for desktop and web layouts.
  Widget _buildSidebarRail() {
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
          _buildSidebarItem(0, 'Dashboard', Icons.dashboard_customize_outlined),
          _buildSidebarItem(1, 'AI Vision Audit', Icons.psychology_outlined),
          _buildSidebarItem(2, 'Hydraulic Sizer', Icons.plumbing_outlined),
          _buildSidebarItem(3, 'QBCC Form 4', Icons.assignment_outlined),
          _buildSidebarItem(4, 'WHS SWMS', Icons.gavel_outlined),
          const Spacer(),
          _buildLicenseFooter(),
        ],
      ),
    );
  }

  /// Title branding header inside the sidebar.
  Widget _buildSidebarBrand() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
    );
  }

  /// Custom list tile buttons for the sidebar layout.
  Widget _buildSidebarItem(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
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
  Widget _buildBottomNavBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
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
