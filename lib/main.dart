import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'views/error/global_error_view.dart';
import 'services/standards_search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Custom Flutter error boundary to intercept rendering and system errors elegantly
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorView(
      errorMessage: details.exceptionAsString(),
    );
  };

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
    return MaterialApp.router(
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
      routerConfig: appRouter,
    );
  }
}

