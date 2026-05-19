import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
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
          Text(
            'Select SWMS to Audit & Sign',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
          if (profile.isSigned)
            _buildSignedBadge(profile)
          else
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
}
