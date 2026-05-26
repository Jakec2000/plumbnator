import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/compliance_result.dart';
import 'glass_card.dart';

class AnalysisResultCard extends StatelessWidget {
  final ComplianceResult result;
  final VoidCallback? onFlagManually;

  const AnalysisResultCard({
    super.key,
    required this.result,
    this.onFlagManually,
  });

  @override
  Widget build(BuildContext context) {
    final hasFailed = !result.isCompliant || result.isManualFlag;
    final themeColor = hasFailed ? const Color(0xFFFF416C) : const Color(0xFF00FF87);
    final ratingPercent = (result.confidenceScore * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Status Card
        GlassCard(
          borderColor: themeColor.withValues(alpha: 0.3),
          backgroundGradient: [
            themeColor.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.01),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.isManualFlag
                              ? 'MANUALLY FLAGGED'
                              : (result.isCompliant
                                  ? 'COMPLIANCE AUDIT PASSED'
                                  : 'COMPLIANCE ISSUES DETECTED'),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.isManualFlag
                              ? 'Flagged for priority manual inspector verification'
                              : 'Confidence Rating: $ratingPercent%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAnimatedIcon(hasFailed, themeColor),
                ],
              ),
              if (result.alignmentCategory != null || result.measuredDeviation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.25)),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00E6FF).withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.explore_outlined, color: Color(0xFF00E6FF), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VIEWFINDER ALIGNMENT METRICS',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00E6FF),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                children: [
                                  TextSpan(text: 'Target: '),
                                  TextSpan(
                                    text: '${result.alignmentCategory ?? "Standard"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const TextSpan(text: '  |  Telemetry: '),
                                  TextSpan(
                                    text: '${result.measuredDeviation ?? "Aligned"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FF87)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'STATUTORY MET',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(color: Colors.white12, height: 28),
              
              // Checklist
              Text(
                'Audited Parameters Checklist:',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (result.clauses.isEmpty)
                Text(
                  'No compliance parameters parsed. Please retry or flag manually.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                )
              else
                ...result.clauses.map((clause) => _buildCheckItem(clause, themeColor)),
              
              // Issues
              if (result.issues.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Detected Non-Compliant Items:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF416C),
                  ),
                ),
                const SizedBox(height: 8),
                ...result.issues.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFF416C), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFFF416C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Manual flag toggle button
              if (!result.isManualFlag && onFlagManually != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onFlagManually,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.flag_outlined, color: Colors.white70, size: 18),
                    label: Text(
                      'Flag Manually for Inspector Review',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Visual Hotspots Overlay Card (if hotspots are present)
        if (result.hotspots.isNotEmpty) ...[
          const SizedBox(height: 20),
          GlassCard(
            borderColor: Colors.white.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extreme Accuracy Hotspots',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E6FF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI verified precise coordinate measurements.',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                ),
                const Divider(color: Colors.white12, height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.hotspots.length,
                  itemBuilder: (context, index) {
                    final spot = result.hotspots[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          color: Colors.white.withValues(alpha: 0.01),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF00E6FF).withValues(alpha: 0.2),
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00E6FF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spot['title'] ?? 'Verification Point',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${spot['standard'] ?? ''} • ${spot['status'] ?? 'PASS'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF00FF87),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedIcon(bool failed, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(
        failed ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildCheckItem(String clause, Color defaultColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00FF87),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clause,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
