import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homeowner_dashboard_view.dart';
import 'pro_dashboard_view.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF03045E), Color(0xFF0077B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 100, color: Colors.cyanAccent),
              const SizedBox(height: 24),
              Text('AquaForge AI', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Predict. Prevent. Perfect.', style: GoogleFonts.inter(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 64),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Homeowner / DIY'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeownerDashboard())),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.plumbing),
                label: const Text('Pro / Contractor'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), foregroundColor: Colors.white, side: const BorderSide(color: Colors.cyanAccent)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProDashboard())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
