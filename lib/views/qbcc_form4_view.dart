import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_card.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';

/// Form 4 lodgement and statutory compliance tracker view.
class QbccForm4View extends ConsumerStatefulWidget {
  const QbccForm4View({super.key});

  @override
  ConsumerState<QbccForm4View> createState() => _QbccForm4ViewState();
}

class _QbccForm4ViewState extends ConsumerState<QbccForm4View> {
  final _licenceController = TextEditingController(text: 'QBCC-1509923');
  String? _selectedJobId;
  String _selectedTier = 'Standard'; // Standard vs Premium

  @override
  void dispose() {
    _licenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(jobsProvider);
    final unlodgedJobs = jobs.where((j) => !j.form4Submitted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeading(),
          const SizedBox(height: 24),
          _buildMainSection(context, unlodgedJobs),
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
          'QBCC FORM 4 REGISTER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track and lodge Notifiable Work under Plumbing and Drainage Regulations',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Responsive body grid.
  Widget _buildMainSection(BuildContext context, dynamic unlodgedJobs) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isMobile ? 0 : 4,
          child: Column(
            children: [
              _buildForm4Selector(unlodgedJobs),
              const SizedBox(height: 20),
              _buildPricingPanel(),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 3,
          child: Column(
            children: [
              if (isMobile) const SizedBox(height: 24),
              _buildLodgementDetails(),
            ],
          ),
        ),
      ],
    );
  }

  /// Selector widget for unlodged jobs.
  Widget _buildForm4Selector(dynamic unlodgedJobs) {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Completed Job to Lodge',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (unlodgedJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'All jobs successfully lodged with QBCC! No pending items.',
                style: GoogleFonts.inter(color: const Color(0xFF00FF87), fontStyle: FontStyle.italic),
              ),
            )
          else
            ...unlodgedJobs.map<Widget>((job) {
              final isSelected = _selectedJobId == job.id;
              final alertColor = job.isOverdue ? const Color(0xFFFF416C) : const Color(0xFFFFD200);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedJobId = job.id),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00E6FF) : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                      color: Colors.white.withValues(alpha: isSelected ? 0.05 : 0.01),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(job.address, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: alertColor.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            job.isOverdue ? 'OVERDUE' : '${job.daysUntilOverdue}d Left',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: alertColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  /// Interactive pricing panel for standard vs priority options.
  Widget _buildPricingPanel() {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lodgement Service Selection',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTierOption(
            tier: 'Standard',
            price: '\$32.40',
            desc: 'Cheapest Compliant Option: standard QBCC processing (10 business days)',
          ),
          const SizedBox(height: 10),
          _buildTierOption(
            tier: 'Priority Premium',
            price: '\$58.10',
            desc: 'Includes instant processing receipt, custom client PDF reports, and SMS verification',
          ),
        ],
      ),
    );
  }

  /// Helper row to build tier option buttons.
  Widget _buildTierOption({
    required String tier,
    required String price,
    required String desc,
  }) {
    final isSelected = _selectedTier == tier;
    final themeColor = isSelected ? const Color(0xFF00E6FF) : Colors.white70;

    return InkWell(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF00E6FF) : Colors.white12),
          color: isSelected ? const Color(0xFF00E6FF).withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: themeColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tier, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: themeColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Final lodgement submission card.
  Widget _buildLodgementDetails() {
    return GlassCard(
      borderColor: const Color(0xFF00E6FF).withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LODGEMENT PROTOCOL',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00E6FF)),
          ),
          const Divider(color: Colors.white12, height: 24),
          Text('QBCC License Number', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 8),
          TextField(
            controller: _licenceController,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          // Lodgement button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedJobId == null ? null : _submitLodgement,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E6FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Lodge Form 4 Now',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Export PDF button (enabled after a job is selected)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _selectedJobId == null ? null : _exportForm4Pdf,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E6FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF00E6FF)),
              label: Text(
                'Export Form 4 PDF',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Triggers statutory submission and updates global state.
  void _submitLodgement() {
    if (_selectedJobId == null) return;
    ref.read(jobsProvider.notifier).lodgeForm4(_selectedJobId!);
    final jobs = ref.read(jobsProvider);
    final job = jobs.firstWhere((j) => j.id == _selectedJobId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00FF87),
        content: Text(
          'Successfully Lodge Form 4 for "${job.title}". Statuory obligation satisfied!',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );

    setState(() {
      _selectedJobId = null;
    });
  }
  /// Export the lodged Form 4 as a styled PDF document.
  Future<void> _exportForm4Pdf() async {
    if (_selectedJobId == null) return;
    final jobs = ref.read(jobsProvider);
    final job = jobs.firstWhere((j) => j.id == _selectedJobId);
    final pdfBytes = await PdfService().generateForm4Pdf(job);
    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: 'Form4_${job.id}.pdf',
    );
  }

}
