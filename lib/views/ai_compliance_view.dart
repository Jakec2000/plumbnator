import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/analysis_result_card.dart';
import '../widgets/ai_compliance/compliance_heading.dart';
import '../widgets/ai_compliance/rate_limiter_badge.dart';
import '../widgets/ai_compliance/control_panel.dart';
import '../widgets/ai_compliance/scanning_progress_indicator.dart';
import '../widgets/ai_compliance/compliance_error_message.dart';

/// Multimodal compliance visual audit view powered by Grok/GPT-4o Vision API
/// and QLD AS/NZS 3500 regulatory criteria.
class AiComplianceView extends ConsumerStatefulWidget {
  const AiComplianceView({super.key});

  @override
  ConsumerState<AiComplianceView> createState() => _AiComplianceViewState();
}

class _AiComplianceViewState extends ConsumerState<AiComplianceView> {
  String? _selectedPhotoName;

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAnalysisProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ComplianceHeading(),
          const SizedBox(height: 20),
          const RateLimiterBadge(),
          const SizedBox(height: 24),
          ControlPanel(
            selectedPhotoName: _selectedPhotoName,
            onPhotoSelected: (name) => setState(() => _selectedPhotoName = name),
            onRunAudit: (category, deviation) => ref.read(aiAnalysisProvider.notifier).runAnalysis(
                  [0, 1, 2, 3],
                  persist: true,
                  alignmentCategory: category,
                  measuredDeviation: deviation,
                ),
          ),
          if (aiState.isLoading) const ScanningProgressIndicator(),
          if (aiState.error != null) ComplianceErrorMessage(message: aiState.error!),
          if (aiState.result != null) ...[
            const SizedBox(height: 32),
            AnalysisResultCard(
              result: aiState.result!,
              onFlagManually: () {
                ref.read(aiAnalysisProvider.notifier).flagResultManually();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFFF416C),
                    content: Text(
                      'Marked as manually flagged for priority inspector review.',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
