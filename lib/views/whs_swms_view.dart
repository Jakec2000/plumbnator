import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../services/pdf_service.dart';
import '../widgets/glass_card.dart';

/// Pre-Start Safe Work Method Statement (SWMS) tracking view.
class WhsSwmsView extends ConsumerStatefulWidget {
  const WhsSwmsView({super.key});

  @override
  ConsumerState<WhsSwmsView> createState() => _WhsSwmsViewState();
}

class _WhsSwmsViewState extends ConsumerState<WhsSwmsView> {
  final _plumberNameController = TextEditingController(text: 'Jack Czek');
  String? _selectedProfileId;

  @override
  void dispose() {
    _plumberNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swmsProfiles = ref.watch(swmsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildLayoutGrid(context, swmsProfiles),
        ],
      ),
    );
  }

  /// Page header details.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHS SWMS MANAGER',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'QLD WHS Act 2011 Pre-Start Safe Work Method Statements',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Responsive body grid.
  Widget _buildLayoutGrid(BuildContext context, List<SwmsProfile> swmsProfiles) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isMobile ? 0 : 4,
          child: Column(
            children: [
              _buildProfilesCard(swmsProfiles),
            ],
          ),
        ),
        if (!isMobile) const SizedBox(width: 24),
        Expanded(
          flex: isMobile ? 0 : 3,
          child: Column(
            children: [
              if (isMobile) const SizedBox(height: 24),
              _buildSignoffPanel(swmsProfiles),
            ],
          ),
        ),
      ],
    );
  }

  /// List of available SWMS templates.
  Widget _buildProfilesCard(List<SwmsProfile> profiles) {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select SWMS to Audit & Sign',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateCustomSwmsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E6FF).withOpacity(0.12),
                  foregroundColor: const Color(0xFF00E6FF),
                  side: BorderSide(color: const Color(0xFF00E6FF).withOpacity(0.4), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  'Bespoke',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...profiles.map((profile) {
            final isSelected = _selectedProfileId == profile.id;
            final themeColor = profile.isSigned ? const Color(0xFF00FF87) : const Color(0xFFFFD200);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => setState(() => _selectedProfileId = profile.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E6FF) : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                    color: Colors.white.withOpacity(isSelected ? 0.05 : 0.01),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        profile.isSigned ? Icons.verified : Icons.warning_amber_outlined,
                        color: themeColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.taskName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.isSigned
                                  ? 'Signed by ${profile.signedBy}'
                                  : 'Awaiting Pre-Start Signoff',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Opens the Bespoke SWMS creator dialog.
  void _showCreateCustomSwmsDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSwmsDialog(),
    );
  }

  /// SWMS digital signature panel.
  Widget _buildSignoffPanel(List<SwmsProfile> profiles) {
    if (_selectedProfileId == null) {
      return const GlassCard(
        child: Center(
          child: Text(
            'Please select an activity to view WHS hazards and sign off.',
            style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final profile = profiles.firstWhere((p) => p.id == _selectedProfileId);
    final themeColor = profile.isSigned ? const Color(0xFF00FF87) : const Color(0xFF00E6FF);

    return GlassCard(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.taskName.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor),
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildSwmsSection('Key Identified Hazards', profile.hazards, Colors.redAccent),
          const SizedBox(height: 16),
          _buildSwmsSection('Mandatory Risk Control Measures', profile.controlMeasures, const Color(0xFF00FF87)),
          const Divider(color: Colors.white12, height: 24),
          if (profile.isSigned) ...[
            _buildSignedBadge(profile),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _exportSwmsPdf(profile),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00FF87)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF00FF87)),
                label: Text(
                  'Export Signed SWMS PDF',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ] else
            _buildSignoffInput(),
        ],
      ),
    );
  }

  /// Helper to display sub-bullets for hazards and controls.
  Widget _buildSwmsSection(String title, List<String> items, Color bulletColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: bulletColor, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.3),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Digital sign-off fields.
  Widget _buildSignoffInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plumber Name (Digital Signature)', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 8),
        TextField(
          controller: _plumberNameController,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _signProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E6FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.draw_outlined),
            label: Text(
              'Sign Pre-Start SWMS',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// signed status badge.
  Widget _buildSignedBadge(SwmsProfile profile) {
    final dateStr = DateFormat('dd MMM yyyy, h:mm a').format(profile.signedAt!);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF00FF87).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF00FF87)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SWMS SIGNED & COMPLIANT',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00FF87)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Signed by: ${profile.signedBy}\nOn: $dateStr',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Signs the active profile and saves to state.
  void _signProfile() {
    if (_selectedProfileId == null || _plumberNameController.text.trim().isEmpty) return;
    ref.read(swmsProvider.notifier).signSwms(_selectedProfileId!, _plumberNameController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00FF87),
        content: Text(
          'SWMS signed! WHS compliance verified.',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Formulates and exports the signed pre-start document to native share/print sheets.
  Future<void> _exportSwmsPdf(SwmsProfile profile) async {
    final pdfBytes = await PdfService().generateSwmsPdf(profile);
    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: 'Signed_SWMS_${profile.id}.pdf',
    );
  }
}

/// A premium dialog allowing plumbers to build custom WHS Safe Work Method Statements on-site.
class CreateSwmsDialog extends ConsumerStatefulWidget {
  const CreateSwmsDialog({super.key});

  @override
  ConsumerState<CreateSwmsDialog> createState() => _CreateSwmsDialogState();
}

class _CreateSwmsDialogState extends ConsumerState<CreateSwmsDialog> {
  final _taskNameController = TextEditingController();
  final List<TextEditingController> _hazards = [];
  final List<TextEditingController> _controls = [];

  @override
  void initState() {
    super.initState();
    _hazards.add(TextEditingController());
    _controls.add(TextEditingController());
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    for (final controller in _hazards) {
      controller.dispose();
    }
    for (final controller in _controls) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Appends a new empty hazard input controller.
  void _addHazard() {
    setState(() => _hazards.add(TextEditingController()));
  }

  /// Removes a hazard input controller at [index].
  void _removeHazard(int index) {
    if (_hazards.length > 1) {
      setState(() => _hazards.removeAt(index).dispose());
    }
  }

  /// Appends a new empty risk control input controller.
  void _addControl() {
    setState(() => _controls.add(TextEditingController()));
  }

  /// Removes a risk control input controller at [index].
  void _removeControl(int index) {
    if (_controls.length > 1) {
      setState(() => _controls.removeAt(index).dispose());
    }
  }

  /// Validates inputs and appends the bespoke SWMS to active Riverpod state.
  void _submit() {
    final taskName = _taskNameController.text.trim();
    if (taskName.isEmpty) {
      _showError('Activity/Task name is required.');
      return;
    }

    final hazards = _hazards.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (hazards.isEmpty) {
      _showError('At least one hazard must be specified.');
      return;
    }

    final controls = _controls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (controls.isEmpty) {
      _showError('At least one control measure must be specified.');
      return;
    }

    ref.read(swmsProvider.notifier).addCustomSwms(taskName, hazards, controls);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00FF87),
        content: Text(
          'Bespoke SWMS created successfully!',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Helper to display input validation errors.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        child: GlassCard(
          borderColor: const Color(0xFF00E6FF).withOpacity(0.15),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(),
              const Divider(color: Colors.white12, height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskField(),
                      const SizedBox(height: 20),
                      _buildDynamicList(
                        title: 'Key Identified Hazards',
                        list: _hazards,
                        onAdd: _addHazard,
                        onRemove: _removeHazard,
                        label: 'Hazard',
                        bulletColor: Colors.redAccent,
                      ),
                      const SizedBox(height: 20),
                      _buildDynamicList(
                        title: 'Mandatory Risk Control Measures',
                        list: _controls,
                        onAdd: _addControl,
                        onRemove: _removeControl,
                        label: 'Control Measure',
                        bulletColor: const Color(0xFF00FF87),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the dialog title row.
  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF00E6FF), size: 24),
            const SizedBox(width: 12),
            Text(
              'CREATE BESPOKE SWMS',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white60),
          splashRadius: 20,
        ),
      ],
    );
  }

  /// Builds the task name input field.
  Widget _buildTaskField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity / Task Name',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _taskNameController,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Sewer line high-pressure jet cleaning (QLD)',
            hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00E6FF), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Builds the dynamic editable list of hazards/controls.
  Widget _buildDynamicList({
    required String title,
    required List<TextEditingController> list,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required String label,
    required Color bulletColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 14, color: Color(0xFF00E6FF)),
              label: Text(
                'Add',
                style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF00E6FF), fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(list.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  '• ',
                  style: TextStyle(color: bulletColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: TextField(
                    controller: list[index],
                    maxLines: null,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter $label details...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF00E6FF), width: 1.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                if (list.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Builds the dialog cancel/submit button actions.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white60,
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E6FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          icon: const Icon(Icons.check, size: 16),
          label: Text(
            'Create SWMS',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
