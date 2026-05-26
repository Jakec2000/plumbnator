import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_card.dart';

/// Builds a beautifully stylized job element for the jobs feed.
class JobItem extends StatelessWidget {
  /// The job data model.
  final dynamic job;

  /// Creates a [JobItem].
  const JobItem({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final isCompliant = job.complianceScore >= 0.8;
    final statusColor = job.form4Submitted
        ? const Color(0xFF00FF87)
        : job.isOverdue
            ? const Color(0xFFFF416C)
            : const Color(0xFFFFD200);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderColor: statusColor.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withValues(alpha: 0.1),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Icon(
                job.form4Submitted
                    ? Icons.done_all
                    : job.isOverdue
                        ? Icons.gavel_outlined
                        : Icons.pending_actions,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.address,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C))
                        .withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '${(job.complianceScore * 100).toStringAsFixed(0)}% Match',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
