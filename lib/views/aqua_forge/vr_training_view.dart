import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:google_fonts/google_fonts.dart';

class VrTrainingModule extends StatefulWidget {
  const VrTrainingModule({super.key});

  @override
  State<VrTrainingModule> createState() => _VrTrainingModuleState();
}

class _VrTrainingModuleState extends State<VrTrainingModule> {
  int _score = 0;
  bool _foundFault = false;

  void _onFaultDiscovered() {
    if (!_foundFault) {
      setState(() {
        _score += 100;
        _foundFault = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excellent! You identified the seismic stress fracture on the main intake.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPD Module 4: Seismic Stress'),
        backgroundColor: Colors.black87,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PanoramaViewer(
            child: Image.network('https://images.unsplash.com/photo-1590494794218-c290130dbb6e?q=80&w=3600&auto=format&fit=crop'),
          ),
          
          if (!_foundFault)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.6,
              child: GestureDetector(
                onTap: _onFaultDiscovered,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 3),
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                  child: const Center(
                    child: Icon(Icons.search, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Objective:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    _foundFault 
                      ? 'Objective Complete. Module passed. +2 CPD Points.' 
                      : 'Scan the 360-degree environment. Locate the micro-fracture on the primary manifold caused by recent seismic activity.',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (_foundFault)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('Return to Pro Dashboard', style: TextStyle(color: Colors.white)),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
