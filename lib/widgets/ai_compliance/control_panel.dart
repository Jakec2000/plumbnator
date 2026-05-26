import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_providers.dart';
import '../glass_card.dart';
import 'paywall_modal.dart';
import 'sample_gallery_dialog.dart';
import 'camera_capture_dialog.dart';

/// Control frame supporting sandbox mock capture & real library triggers.
class ControlPanel extends ConsumerWidget {
  final String? selectedPhotoName;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onRunAudit;

  const ControlPanel({
    super.key,
    required this.selectedPhotoName,
    required this.onPhotoSelected,
    required this.onRunAudit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiAnalysisProvider);
    
    return GlassCard(
      borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.1),
      child: Column(
        children: [
          _buildUploaderArea(aiState),
          const SizedBox(height: 20),
          _buildActionButtons(context, ref, aiState),
        ],
      ),
    );
  }

  Widget _buildUploaderArea(dynamic aiState) {
    final hasResult = aiState.result != null;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!hasResult) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedPhotoName != null ? Icons.image_outlined : Icons.cloud_upload_outlined,
                  color: selectedPhotoName != null ? const Color(0xFF00FF87) : Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  selectedPhotoName ?? 'Capture Installation Photo or Upload File',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedPhotoName != null ? const Color(0xFF00FF87) : Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Compliant with QLD PCA water pipes, tanks, stacks & drains',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ] else ...[
            Container(
              color: Colors.black45,
              child: Center(
                child: Icon(
                  Icons.plumbing_outlined,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 72,
                ),
              ),
            ),
            Center(
              child: Text(
                'Verification image uploaded successfully.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00FF87),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic aiState) {
    final enabled = !aiState.isLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled
                ? () {
                    if (aiState.canAnalyze) {
                      SampleGalleryDialog.show(context, (fileName) {
                        onPhotoSelected(fileName);
                        onRunAudit();
                      });
                    } else {
                      PaywallModal.show(context, ref);
                    }
                  }
                : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(
              Icons.photo_library_outlined,
              color: enabled ? const Color(0xFF00E6FF) : Colors.white24,
            ),
            label: Text(
              'Upload Photo',
              style: GoogleFonts.inter(
                color: enabled ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: enabled
                ? () {
                    if (aiState.canAnalyze) {
                      CameraCaptureDialog.show(context, () {
                        onPhotoSelected('Camera_Capture_Live.jpg');
                        onRunAudit();
                      });
                    } else {
                      PaywallModal.show(context, ref);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E6FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              'Capture Photo',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
