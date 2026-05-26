import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simulated gallery dialog choosing compliant elements.
class SampleGalleryDialog extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const SampleGalleryDialog({super.key, required this.onSelected});

  static void show(BuildContext context, ValueChanged<String> onSelected) {
    showDialog(
      context: context,
      builder: (ctx) => SampleGalleryDialog(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0F1D),
      title: Text(
        'Select Sample File',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGalleryTile(context, 'Water_Pipe_Lagging_Check.jpg'),
          const SizedBox(height: 10),
          _buildGalleryTile(context, 'Sanitary_Vent_Stack_Drain.jpg'),
          const SizedBox(height: 10),
          _buildGalleryTile(context, 'Hot_Water_System_Tempering.jpg'),
        ],
      ),
    );
  }

  Widget _buildGalleryTile(BuildContext context, String fileName) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelected(fileName);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
