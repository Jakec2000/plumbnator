import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/hubs/operations_hub_view.dart';
import 'views/hubs/sizers_hub_view.dart';
import 'views/hubs/field_docs_hub_view.dart';
import 'views/hubs/compliance_hub_view.dart';
import 'providers/state_providers.dart';
import 'services/standards_search_service.dart';
import 'widgets/navigation/sidebar_rail.dart';
import 'widgets/navigation/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Safe diagnostic printout when running in decoupled sandbox
  }

  // Pre-load full-text AS/NZS 3500 standards in background
  StandardsSearchService().loadFullTextStandards();

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
    OperationsHubView(),
    SizersHubView(),
    FieldDocsHubView(),
    ComplianceHubView(),
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
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1.0,
                ),
              ),
            )
          : null,
      drawer: !isLargeScreen ? AppDrawer(currentIndex: currentIndex) : null,
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
              if (isLargeScreen) SidebarRail(currentIndex: currentIndex),
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

  /// Standard bottom navigation bar for mobile size displays.
  Widget _buildBottomNavBar(int currentIndex) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (idx) {
        ref.read(navProvider.notifier).setIndex(idx);
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
