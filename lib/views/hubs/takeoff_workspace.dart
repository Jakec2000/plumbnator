import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ai_takeoff_service.dart';
import '../../widgets/takeoff/blueprint_uploader.dart';
import '../../widgets/takeoff/material_bom_list.dart';

class TakeoffWorkspace extends ConsumerStatefulWidget {
  const TakeoffWorkspace({super.key});

  @override
  ConsumerState<TakeoffWorkspace> createState() => _TakeoffWorkspaceState();
}

class _TakeoffWorkspaceState extends ConsumerState<TakeoffWorkspace> {
  bool _isAnalyzing = false;
  List<TakeoffItem>? _generatedBom;

  Future<void> _handleUpload() async {
    setState(() {
      _isAnalyzing = true;
      _generatedBom = null;
    });

    try {
      final service = ref.read(aiTakeoffServiceProvider);
      // Simulate file picker by just passing a mock path
      final bom = await service.generateCompliantBoM('mock_blueprint.pdf');
      
      if (mounted) {
        setState(() {
          _generatedBom = bom;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing blueprint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Material Order Generator',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your plumbing plans. AquaForge AI will map the layout and reference AS/NZS 3500 rules to calculate a complete, compliant materials list.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          if (_isAnalyzing)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00E6FF)),
                    const SizedBox(height: 16),
                    Text(
                      'Gemini Vision extracting layout...',
                      style: GoogleFonts.inter(color: const Color(0xFF00E6FF)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cross-referencing AS/NZS 3500 rules...',
                      style: GoogleFonts.inter(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else if (_generatedBom == null)
            BlueprintUploader(onUpload: _handleUpload)
          else
            Column(
              children: [
                MaterialBomList(items: _generatedBom!),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Reset for demo purposes
                      setState(() => _generatedBom = null);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start New Takeoff'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order sent to supplier!')),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send to Supplier (Reece / Tradelink)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E6FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}
