import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vr_training_view.dart';
import '../../widgets/glass_card.dart';

class ProDashboard extends StatelessWidget {
  final FirebaseFirestore? firestore;
  const ProDashboard({super.key, this.firestore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PRO DISPATCHER HUB',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E6FF).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.5)),
              ),
              child: IconButton(
                icon: const Icon(Icons.vrpano, color: Color(0xFF00E6FF)),
                tooltip: 'VR Training',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VrTrainingModule())),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (firestore ?? FirebaseFirestore.instance).collection('jobs').where('status', isEqualTo: 'dispatched').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E6FF)),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.satellite_alt_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'NO ACTIVE DISPATCHES',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitoring systems on standby.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            );
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobDoc = jobs[index];
              final data = jobDoc.data() as Map<String, dynamic>;
              final isCritical = data['urgency'] == 'critical';
              final accentColor = isCritical ? const Color(0xFFFF416C) : const Color(0xFF00E6FF);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GlassCard(
                  borderColor: accentColor.withValues(alpha: 0.3),
                  backgroundGradient: [
                    accentColor.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (data['title'] ?? 'Emergency Dispatch').toString().toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withValues(alpha: 0.1),
                            ),
                            child: Icon(Icons.plumbing, color: accentColor, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.white54, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Unknown Coordinates',
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: accentColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'URGENCY: ${data['urgency']?.toString().toUpperCase() ?? 'ROUTINE'}',
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => _showComplianceDialog(context, jobDoc.id),
                          icon: const Icon(Icons.verified_user_outlined, size: 20),
                          label: Text(
                            'COMPLETE & VERIFY COMPLIANCE',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFF00FF87),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: const Color(0xFF00FF87).withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }

  void _showComplianceDialog(BuildContext context, String jobId) {
    bool pressureCheck = false;
    bool watermarkCheck = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: GlassCard(
                borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.4),
                backgroundGradient: [
                  const Color(0xFF0A0F1D).withValues(alpha: 0.9),
                  const Color(0xFF05070E).withValues(alpha: 0.95),
                ],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gavel, color: Color(0xFF00E6FF), size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'AS/NZS 3500 COMPLIANCE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You must verify the following regulatory standards before marking this job complete:',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    _buildCheckboxTile(
                      'Static pressure does not exceed 500 kPa (AS/NZS 3500.1)',
                      pressureCheck,
                      (val) => setState(() => pressureCheck = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckboxTile(
                      'All replaced fittings possess a valid WaterMark certification',
                      watermarkCheck,
                      (val) => setState(() => watermarkCheck = val ?? false),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF416C),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: (pressureCheck && watermarkCheck) ? () async {
                            Navigator.of(dialogContext).pop();
                            try {
                              await (firestore ?? FirebaseFirestore.instance).collection('jobs').doc(jobId).update({
                                'status': 'completed',
                                'complianceVerified': true,
                                'completedAt': FieldValue.serverTimestamp()
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Compliance Verified! Web3 Warranty Unlocked.',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF00FF87),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  )
                                );
                              }
                            } catch (e) {
                              debugPrint('Error updating job status: $e');
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87),
                            foregroundColor: const Color(0xFF070B14),
                            disabledBackgroundColor: Colors.white12,
                            disabledForegroundColor: Colors.white30,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'SIGN OFF',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: value ? const Color(0xFF00E6FF) : Colors.white.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF00E6FF) : Colors.transparent,
                border: Border.all(
                  color: value ? const Color(0xFF00E6FF) : Colors.white54,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF0A0F1D))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: value ? Colors.white : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

