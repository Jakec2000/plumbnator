import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';

/// Interactive AI compliance checking view powered by simulated Gemini Vision.
class AiComplianceView extends StatefulWidget {
  const AiComplianceView({super.key});

  @override
  State<AiComplianceView> createState() => _AiComplianceViewState();
}

class _AiComplianceViewState extends State<AiComplianceView> {
  String _selectedCategory = 'Tempering Valve';
  bool _isAnalyzing = false;
  bool _showResult = false;
  String? _selectedPhotoName;
  double _complianceScore = 0.96;
  int _activeHotspot = 0;

  final Map<String, List<String>> _complianceGuidelines = {
    'Tempering Valve': [
      'AS/NZS 3500.4 Clause 5.3 compliant delivery temperature (<50°C)',
      'Water heater storage minimum set-point temperature (>60°C)',
      'Tempering valve is WaterMark certified and verified',
      'All pipes properly lagged/insulated to prevent thermal loss',
    ],
    'Drainage Junction': [
      'Junction is oriented at 45° angle to prevent stranding',
      'Minimal grade of 1.65% gradient verified for DN100 pipe run',
      'As-constructed drawing uploaded and validated',
      'Pipes show no structural stress fractures or sagging points',
    ],
    'Backflow RPZD': [
      'RPZ Valve installed min 300mm above ground level',
      'Line pressure tested and certified by licensed technician',
      'Dual check valve auxiliary backups verified',
      'WaterMark compliance and calibration tags attached',
    ],
  };

  /// Hotspot check points for extreme accuracy feedback
  final Map<String, List<Map<String, String>>> _hotspots = {
    'Tempering Valve': [
      {'title': 'Hot Inlet Feed', 'standard': 'AS/NZS 3500.4 Cl 5.2', 'status': 'PASS (Stored @ 62°C)'},
      {'title': 'Tempered Outlet', 'standard': 'AS/NZS 3500.4 Cl 5.3', 'status': 'PASS (Delivered @ 48°C)'},
      {'title': 'Cold Main Bypass', 'standard': 'AS/NZS 3500.1 Cl 2.4', 'status': 'PASS (Pressure Regulated)'},
      {'title': 'WaterMark Seal', 'standard': 'PCA Part B1 Compliance', 'status': 'PASS (WMKA-21908)'},
    ],
    'Drainage Junction': [
      {'title': 'Junction Angle', 'standard': 'AS/NZS 3500.2 Cl 4.5', 'status': 'PASS (45° Y-Junction)'},
      {'title': 'Incline Slope', 'standard': 'AS/NZS 3500.2 Table 5.2', 'status': 'PASS (1.68% Graded)'},
      {'title': 'Invert Offset', 'standard': 'AS/NZS 3500.2 Cl 4.7', 'status': 'PASS (12mm Soffit Offset)'},
    ],
    'Backflow RPZD': [
      {'title': 'Ground Clearance', 'standard': 'AS/NZS 3500.1 Cl 4.3', 'status': 'PASS (320mm Elevation)'},
      {'title': 'Upstream Dual Check', 'standard': 'AS/NZS 3500.1 Cl 4.4', 'status': 'PASS (No Back siphonage)'},
      {'title': 'Calibration Stamp', 'standard': 'QBCC Licensing rules', 'status': 'PASS (Audited May 2026)'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeading(),
          const SizedBox(height: 24),
          _buildConfigurationSelector(),
          const SizedBox(height: 24),
          _buildControlPanel(),
          if (_isAnalyzing) _buildScanningProgress(),
          if (_showResult) ...[
            const SizedBox(height: 32),
            _buildComplianceReport(context),
          ],
        ],
      ),
    );
  }

  /// Header widget.
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

  /// Selector for installation type.
  Widget _buildConfigurationSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _complianceGuidelines.keys.map((cat) {
        final isSelected = _selectedCategory == cat;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = cat;
              _showResult = false;
              _selectedPhotoName = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? const Color(0xFF00E6FF) : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: isSelected ? const Color(0xFF00E6FF) : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              cat,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the file selector and run panel.
  Widget _buildControlPanel() {
    return GlassCard(
      borderColor: const Color(0xFF00E6FF).withOpacity(0.1),
      child: Column(
        children: [
          _buildUploaderArea(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// The upload container frame.
  Widget _buildUploaderArea() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
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
            'AS/NZS 3500 high-fidelity calibration active',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  /// Triggers standard buttons for simulated camera capture & upload gallery.
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showPhotoGalleryDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF00E6FF)),
            label: Text(
              'Upload Photo',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _runSimulatedCamera,
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

  /// Simulated Camera Viewfinder overlay dialog.
  void _runSimulatedCamera() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1D),
        title: Text(
          'Live Compliance Viewfinder',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E6FF), width: 2),
                color: Colors.black,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.transparent, Colors.black87],
                            radius: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.plumbing, color: Colors.white30, size: 64),
                  // Reticle crosshair overlays
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.5), width: 1.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'ALIGN $_selectedCategory INSIDE FRAME',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF00E6FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Grid calibration mapping: AS/NZS 3500 compliance guidelines active.',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, fontStyle: FontStyle.italic),
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
                _selectedPhotoName = 'Camera_Capture_${_selectedCategory.replaceAll(' ', '_')}.jpg';
                _complianceScore = 0.98;
              });
              _runAiAnalysis();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E6FF), foregroundColor: Colors.black),
            child: const Text('Capture & Check'),
          ),
        ],
      ),
    );
  }

  /// Gallery photo dialog.
  void _showPhotoGalleryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1D),
        title: Text(
          'Select Installation Sample',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGalleryOption(ctx, 'Tempering_Valve_Compliance_AS3500.png', 0.97),
            const SizedBox(height: 10),
            _buildGalleryOption(ctx, 'Drainage_Junction_Gridded_Audit.png', 0.72),
            const SizedBox(height: 10),
            _buildGalleryOption(ctx, 'RPZ_Backflow_Clearance_Check.png', 0.99),
          ],
        ),
      ),
    );
  }

  /// Renders a single image file choice in gallery list.
  Widget _buildGalleryOption(BuildContext dialogCtx, String name, double score) {
    return InkWell(
      onTap: () {
        Navigator.of(dialogCtx).pop();
        setState(() {
          _selectedPhotoName = name;
          _complianceScore = score;
        });
        _runAiAnalysis();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  /// Triggers the simulated AI visual analysis.
  void _runAiAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _showResult = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _showResult = true;
        });
      }
    });
  }

  /// Scanning loader widget.
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
            'Gemini 3 Pro Vision: Analyzing pixels for compliance parameters with extreme accuracy...',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// Comprehensive compliance check card.
  Widget _buildComplianceReport(BuildContext context) {
    final rules = _complianceGuidelines[_selectedCategory] ?? [];
    final hasFailed = _complianceScore < 0.8;
    final themeColor = hasFailed ? const Color(0xFFFF416C) : const Color(0xFF00FF87);

    return Flex(
      direction: MediaQuery.of(context).size.width < 900 ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: GlassCard(
            borderColor: themeColor.withOpacity(0.2),
            backgroundGradient: [
              themeColor.withOpacity(0.05),
              Colors.white.withOpacity(0.01),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasFailed ? 'COMPLIANCE AUDIT AUDITED (ISSUES DETECTED)' : 'COMPLIANCE AUDIT PASSED',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    Icon(
                      hasFailed ? Icons.error_outline : Icons.check_circle_outline,
                      color: themeColor,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The AI parsed standard criteria and calculated an overall compliance rating of ${(double.parse((_complianceScore * 100).toStringAsFixed(0)))}%.',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                ),
                const Divider(color: Colors.white12, height: 32),
                Text(
                  'Audited Parameters Checklist:',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ...rules.map((rule) => _buildReportRule(rule, hasFailed)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildVisualHotspotsCard(),
        ),
      ],
    );
  }

  /// Renders a single check element.
  Widget _buildReportRule(String rule, bool hasFailed) {
    // Simulated failed items for gridded sanitary junction score < 80%
    final isFail = hasFailed && rule.contains('1.65% gradient');
    final checkColor = isFail ? const Color(0xFFFF416C) : const Color(0xFF00FF87);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(isFail ? Icons.close : Icons.check, color: checkColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isFail ? const Color(0xFFFF416C) : Colors.white70,
                fontWeight: isFail ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders interactive visual hotspots card showing extreme accuracy checks.
  Widget _buildVisualHotspotsCard() {
    final list = _hotspots[_selectedCategory] ?? [];

    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extreme Accuracy Hotspots',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00E6FF)),
          ),
          const SizedBox(height: 4),
          Text(
            'Select checkpoints to verify exact compliance measurements.',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
          ),
          const Divider(color: Colors.white12, height: 24),
          ...list.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isActive = _activeHotspot == idx;

            return Padding(
              key: ValueKey(idx),
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => setState(() => _activeHotspot = idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? const Color(0xFF00E6FF) : Colors.white12,
                    ),
                    color: Colors.white.withOpacity(isActive ? 0.05 : 0.01),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? const Color(0xFF00E6FF) : Colors.white24,
                        ),
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${item['standard']!} — ${item['status']!}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF00FF87),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
}
