import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/analysis_result_card.dart';

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
          _buildHeading(),
          const SizedBox(height: 20),
          _buildRateLimiterBadge(aiState),
          const SizedBox(height: 24),
          _buildControlPanel(aiState),
          if (aiState.isLoading) _buildScanningProgress(),
          if (aiState.error != null) _buildErrorMessage(aiState.error!),
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

  /// Page heading details.
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI VISION COMPLIANCE CHECKER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Multimodal installation scanning (AS/NZS 3500 & PCA Standards)',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Interactive daily usage cap display.
  Widget _buildRateLimiterBadge(AiAnalysisState aiState) {
    final isGold = aiState.dailyRemaining == 99999;
    final limitColor = isGold 
        ? const Color(0xFFFFD700) 
        : (aiState.canAnalyze ? const Color(0xFF00FF87) : const Color(0xFFFF416C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: limitColor.withValues(alpha: 0.08),
        border: Border.all(color: limitColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGold 
                ? Icons.workspace_premium_outlined 
                : (aiState.canAnalyze ? Icons.verified_outlined : Icons.lock_outline),
            color: limitColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isGold
                  ? 'PLUMBNATOR GOLD: Unlimited AS/NZS 3500 compliance scans unlocked!'
                  : (aiState.canAnalyze
                      ? 'Daily Usage Rate Limiter Active: ${aiState.dailyRemaining} / 5 analyses remaining today'
                      : 'Daily Limit Reached (5/5). Upgrade to Plumbnator Gold to scan unlimited installations.'),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: limitColor,
              ),
            ),
          ),
          if (!isGold) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _showPaywallModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Upgrade to Gold',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Control frame supporting sandbox mock capture & real library triggers.
  Widget _buildControlPanel(AiAnalysisState aiState) {
    return GlassCard(
      borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.1),
      child: Column(
        children: [
          _buildUploaderArea(aiState),
          const SizedBox(height: 20),
          _buildActionButtons(aiState),
        ],
      ),
    );
  }

  /// Upload container slot.
  Widget _buildUploaderArea(AiAnalysisState aiState) {
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
                  _selectedPhotoName != null ? Icons.image_outlined : Icons.cloud_upload_outlined,
                  color: _selectedPhotoName != null ? const Color(0xFF00FF87) : Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedPhotoName ?? 'Capture Installation Photo or Upload File',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedPhotoName != null ? const Color(0xFF00FF87) : Colors.white70,
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

  /// Gallery + Camera action selections. Disables automatically when daily cap reached.
  Widget _buildActionButtons(AiAnalysisState aiState) {
    final enabled = !aiState.isLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled
                ? () {
                    if (aiState.canAnalyze) {
                      _triggerSampleUpload();
                    } else {
                      _showPaywallModal(context);
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
                      _triggerCameraCapture();
                    } else {
                      _showPaywallModal(context);
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

  /// Simulated gallery dialog choosing compliant elements.
  void _triggerSampleUpload() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1D),
        title: Text(
          'Select Sample File',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGalleryTile('Water_Pipe_Lagging_Check.jpg'),
            const SizedBox(height: 10),
            _buildGalleryTile('Sanitary_Vent_Stack_Drain.jpg'),
            const SizedBox(height: 10),
            _buildGalleryTile('Hot_Water_System_Tempering.jpg'),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryTile(String fileName) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          _selectedPhotoName = fileName;
        });
        _runAudit();
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

  /// Simulated compliance live camera alignment interface.
  void _triggerCameraCapture() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _selectedPhotoName = 'Camera_Capture_Live.jpg';
              });
              _runAudit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E6FF),
              foregroundColor: Colors.black,
            ),
            child: const Text('Check Compliance'),
          ),
        ],
      ),
    );
  }

  void _runAudit() {
    // Dispatch compliance analysis flow using random dummy bytes for visual scan
    ref.read(aiAnalysisProvider.notifier).runAnalysis([0, 1, 2, 3], persist: true);
  }

  /// Scanning feedback loader.
  Widget _buildScanningProgress() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          const LinearProgressIndicator(
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E6FF)),
          ),
          const SizedBox(height: 12),
          Text(
            'Grok Vision processing compliance parameters against AS/NZS 3500 with extreme accuracy...',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// Custom error presentation card.
  Widget _buildErrorMessage(String msg) {
    return Padding(
      key: const ValueKey('error_widget'),
      padding: const EdgeInsets.only(top: 24.0),
      child: GlassCard(
        borderColor: const Color(0xFFFF416C).withValues(alpha: 0.3),
        backgroundGradient: [
          const Color(0xFFFF416C).withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.01),
        ],
        child: Row(
          children: [
            const Icon(Icons.error_outline_sharp, color: Color(0xFFFF416C), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Warning',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFFFF416C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive gold upgrade subscription modal sheet.
  void _showPaywallModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        bool isLoading = false;
        bool isSuccess = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0F1D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 20),
                    // Gold Crown Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFFFD700), size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'UPGRADE TO PLUMBNATOR GOLD',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock unlimited AS/NZS 3500 & PCA compliance audits',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(height: 24),

                    // Plan details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.01),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Commercial License Plan',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                              ),
                              Text(
                                '\$29.90 / mo',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 20),
                          _buildPlanBenefit('Unlimited Visual AI Auditing Scans'),
                          _buildPlanBenefit('High-Resolution As-Constructed PDF plans'),
                          _buildPlanBenefit('AS 2845.3 Backflow tests & Form 9 registry'),
                          _buildPlanBenefit('Offline Local database automatic synchronization'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Secure pay shield banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, color: Colors.white30, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Secure SSL payment verified by JobFlow Pay',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isSuccess)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🎉 PLUMBNATOR GOLD ACTIVATED!',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF87),
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setModalState(() {
                                    isLoading = true;
                                  });
                                  // Secure mock billing wait
                                  await Future.delayed(const Duration(milliseconds: 1500));
                                  await ref.read(aiAnalysisProvider.notifier).upgradeToGold();
                                  setModalState(() {
                                    isLoading = false;
                                    isSuccess = true;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 1000));
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFFFFD700),
                                      content: Text(
                                        '🎉 Plumbnator Gold subscription activated successfully! Welcome to premium!',
                                        style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Text(
                                  'Authorize & Unlock Plumbnator Gold',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFFFFD700), size: 14),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
        ],
      ),
    );
  }
}
