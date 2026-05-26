import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simulated compliance live camera alignment interface.
class CameraCaptureDialog extends StatelessWidget {
  final VoidCallback onCapture;

  const CameraCaptureDialog({super.key, required this.onCapture});

  static void show(BuildContext context, VoidCallback onCapture) {
    showDialog(
      context: context,
      builder: (ctx) => CameraCaptureDialog(onCapture: onCapture),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0F1D),
      title: Text(
        'Plumbing Live Viewfinder',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00E6FF), width: 1.5),
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.photo_camera_outlined, color: Colors.white24, size: 48),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.3)),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  child: Text(
                    'ALIGN WET COMPONENT INSIDE GRID',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF00E6FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Align water line, stack or drainage fitting inside verification circle.',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCapture();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E6FF),
            foregroundColor: Colors.black,
          ),
          child: const Text('Check Compliance'),
        ),
      ],
    );
  }
}
