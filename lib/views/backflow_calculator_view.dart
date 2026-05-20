import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../providers/state_providers.dart';
import '../models/models.dart';
import '../widgets/glass_card.dart';
import '../services/pdf_service.dart';

/// Backflow Prevention and Field Commissioning view under AS 2845.3.
class BackflowCalculatorView extends ConsumerStatefulWidget {
  const BackflowCalculatorView({super.key});

  @override
  ConsumerState<BackflowCalculatorView> createState() => _BackflowCalculatorViewState();
}

class _BackflowCalculatorViewState extends ConsumerState<BackflowCalculatorView> {
  final _serialController = TextEditingController(text: 'BF-77610-A');
  final _brandController = TextEditingController(text: 'Conbraco');
  final _modelController = TextEditingController(text: 'RPZ 40');
  final _locationController = TextEditingController(text: 'Main Fire Service Line');
  final _testerController = TextEditingController(text: 'Jack Czek');
  final _licenceController = TextEditingController(text: 'QBCC-1509923');

  int _selectedSizeDn = 40;
  String _selectedDeviceType = 'RPZD'; // RPZD or Double Check Valve

  double _upstreamPressure = 500.0;
  double _firstCheckValve = 45.0; // kPa drop
  double _reliefValveOpening = 16.0; // kPa opening (RPZD only)
  double _secondCheckValve = 12.0; // kPa drop

  @override
  void dispose() {
    _serialController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _testerController.dispose();
    _licenceController.dispose();
    super.dispose();
  }

  /// Calculates dynamic pass/fail checks under AS 2845.3.
  Map<String, dynamic> _evaluateInputs() {
    if (_selectedDeviceType == 'RPZD') {
      final firstCheckPass = _firstCheckValve >= 35.0;
      final reliefPass = _reliefValveOpening >= 14.0;
      final secondCheckPass = _secondCheckValve >= 7.0;
      final overallPass = firstCheckPass && reliefPass && secondCheckPass;

      List<String> reasons = [];
      if (!firstCheckPass) reasons.add('First Check Valve Drop is < 35 kPa (Tightness Failure)');
      if (!reliefPass) reasons.add('Relief Valve Opening Pressure is < 14 kPa (Cross-Contamination Hazard)');
      if (!secondCheckPass) reasons.add('Second Check Valve Drop is < 7 kPa');

      return {
        'isPass': overallPass,
        'reasons': reasons,
        'details': 'AS 2845.3 standards require First Check >= 35 kPa, Relief Valve >= 14 kPa, and Second Check >= 7 kPa.'
      };
    } else {
      final firstCheckPass = _firstCheckValve >= 7.0;
      final secondCheckPass = _secondCheckValve >= 7.0;
      final overallPass = firstCheckPass && secondCheckPass;

      List<String> reasons = [];
      if (!firstCheckPass) reasons.add('First Check Valve Drop is < 7 kPa');
      if (!secondCheckPass) reasons.add('Second Check Valve Drop is < 7 kPa');

      return {
        'isPass': overallPass,
        'reasons': reasons,
        'details': 'AS 2845.3 standards require both Double Check Valves to maintain >= 7 kPa tightness drop.'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(backflowProvider);
    final evaluation = _evaluateInputs();
    final isPass = evaluation['isPass'] as bool;
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeading(),
          const SizedBox(height: 24),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Calculator & Inputs
              Expanded(
                flex: isMobile ? 0 : 5,
                child: Column(
                  children: [
                    _buildDiagnosticBadge(isPass, evaluation),
                    const SizedBox(height: 20),
                    _buildDeviceConfigPanel(),
                    const SizedBox(height: 20),
                    _buildManifoldSliders(),
                    const SizedBox(height: 20),
                    _buildTesterPanel(),
                    const SizedBox(height: 24),
                    _buildActionButtons(isPass),
                  ],
                ),
              ),
              if (!isMobile) const SizedBox(width: 24),
              // Right Column: Active Ledger Register
              Expanded(
                flex: isMobile ? 0 : 4,
                child: Column(
                  children: [
                    if (isMobile) const SizedBox(height: 28),
                    _buildLedgerRegister(devices),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Page title heading.
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AS 2845.3 BACKFLOW COMMISSIONING',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Automated field tests and statutory Form 9 local council register',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// Live visual pass/fail indicator based on current slider values.
  Widget _buildDiagnosticBadge(bool isPass, Map<String, dynamic> eval) {
    final themeColor = isPass ? const Color(0xFF00FF87) : const Color(0xFFFF416C);
    final reasons = eval['reasons'] as List<String>;

    return GlassCard(
      borderColor: themeColor.withOpacity(0.3),
      backgroundGradient: [
        themeColor.withOpacity(0.08),
        Colors.white.withOpacity(0.01),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPass ? Icons.verified : Icons.warning_amber_rounded,
              color: themeColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPass ? 'AS 2845.3 HYDRAULIC PASS' : 'AS 2845.3 REJECTED / FAILING',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPass ? 'COMPLIANT' : 'WARNING',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: themeColor,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  eval['details'] as String,
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                ),
                if (reasons.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...reasons.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.close, color: Color(0xFFFF416C), size: 12),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                r,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFFFF416C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Metadata specifications for the valve.
  Widget _buildDeviceConfigPanel() {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valve Identification Parameters',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Device Category', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDeviceType,
                          dropdownColor: const Color(0xFF070B14),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(value: 'RPZD', child: Text('Reduced Pressure Zone (RPZD)')),
                            DropdownMenuItem(value: 'Double Check Valve', child: Text('Double Check Valve (DCV)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDeviceType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valve Size', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedSizeDn,
                          dropdownColor: const Color(0xFF070B14),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(value: 20, child: Text('DN 20 (3/4")')),
                            DropdownMenuItem(value: 25, child: Text('DN 25 (1")')),
                            DropdownMenuItem(value: 32, child: Text('DN 32 (1-1/4")')),
                            DropdownMenuItem(value: 40, child: Text('DN 40 (1-1/2")')),
                            DropdownMenuItem(value: 50, child: Text('DN 50 (2")')),
                            DropdownMenuItem(value: 80, child: Text('DN 80 (3")')),
                            DropdownMenuItem(value: 100, child: Text('DN 100 (4")')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSizeDn = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputTextField('Serial Number', _serialController)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputTextField('Manufacturer / Brand', _brandController)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputTextField('Model Code', _modelController)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputTextField('Site Location Details', _locationController)),
            ],
          ),
        ],
      ),
    );
  }

  /// Text field helper.
  Widget _buildInputTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  /// Sliders representing pressure drop measurements in kPa.
  Widget _buildManifoldSliders() {
    final isRpz = _selectedDeviceType == 'RPZD';

    return GlassCard(
      borderColor: const Color(0xFF00E6FF).withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AS 2845.3 Pressure Drops (kPa)',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Icon(Icons.speed, color: Color(0xFF00E6FF), size: 18),
            ],
          ),
          const SizedBox(height: 20),

          // Upstream Line pressure
          _buildSliderItem(
            label: 'Upstream Line Supply Pressure',
            value: _upstreamPressure,
            min: 100,
            max: 1000,
            color: Colors.blueAccent,
            onChanged: (val) => setState(() => _upstreamPressure = val),
          ),

          // First Check Drop
          _buildSliderItem(
            label: 'First Check Valve Drop',
            value: _firstCheckValve,
            min: 0,
            max: 100,
            color: _firstCheckValve >= (isRpz ? 35.0 : 7.0) ? const Color(0xFF00FF87) : const Color(0xFFFF416C),
            onChanged: (val) => setState(() => _firstCheckValve = val),
          ),

          // Relief Valve (RPZD only)
          if (isRpz)
            _buildSliderItem(
              label: 'Relief Valve Opening Pressure',
              value: _reliefValveOpening,
              min: 0,
              max: 50,
              color: _reliefValveOpening >= 14.0 ? const Color(0xFF00FF87) : const Color(0xFFFF416C),
              onChanged: (val) => setState(() => _reliefValveOpening = val),
            ),

          // Second Check Drop
          _buildSliderItem(
            label: 'Second Check Valve Drop',
            value: _secondCheckValve,
            min: 0,
            max: 50,
            color: _secondCheckValve >= 7.0 ? const Color(0xFF00FF87) : const Color(0xFFFF416C),
            onChanged: (val) => setState(() => _secondCheckValve = val),
          ),
        ],
      ),
    );
  }

  /// Helper row representing slider controllers.
  Widget _buildSliderItem({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              Text(
                '${value.toStringAsFixed(1)} kPa',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: color),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white12,
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Plumber credentials signature log.
  Widget _buildTesterPanel() {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commissioning Plumber Sign-Off',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputTextField('Tester Plumber Name', _testerController)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputTextField('QBCC Endorsed Licence No.', _licenceController)),
            ],
          ),
        ],
      ),
    );
  }

  /// Execution button layouts.
  Widget _buildActionButtons(bool isPass) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _registerDeviceTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E6FF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.save_outlined),
        label: Text(
          'Register Test & Form 9 Record',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  /// Registered test log ledger registry.
  Widget _buildLedgerRegister(List<BackflowDevice> devices) {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Form 9 Lodgements',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF00E6FF).withOpacity(0.1),
                ),
                child: Text(
                  '${devices.length} Registered',
                  style: GoogleFonts.inter(color: const Color(0xFF00E6FF), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No backflow devices commissioned yet.',
                  style: GoogleFonts.inter(color: Colors.white30, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final d = devices[index];
                final isPass = d.passesInspection;
                final badgeColor = isPass ? const Color(0xFF00FF87) : const Color(0xFFFF416C);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                    color: Colors.white.withOpacity(0.01),
                  ),
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
                                  '${d.brand} ${d.modelName} (DN ${d.sizeDn})',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'S/N: ${d.serialNumber} | ${d.location}',
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: badgeColor.withOpacity(0.12),
                            ),
                            child: Text(
                              isPass ? 'PASS' : 'FAIL',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d.isSubmitted ? '✅ LODGED WITH COUNCIL' : '⏳ PENDING LODGEMENT',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: d.isSubmitted ? const Color(0xFF00FF87) : Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            d.deviceType,
                            style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white30, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: () => _printForm9Pdf(d),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.white70),
                                label: Text(
                                  'PDF Certificate',
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton.icon(
                                onPressed: d.isSubmitted ? null : () => _lodgeForm9(d.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FF87),
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.white10,
                                  disabledForegroundColor: Colors.white30,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.send_sharp, size: 13),
                                label: Text(
                                  d.isSubmitted ? 'Lodged' : 'Lodge Form 9',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Appends device record.
  void _registerDeviceTest() {
    final newId = 'bf-${DateTime.now().millisecondsSinceEpoch}';
    final d = BackflowDevice(
      id: newId,
      serialNumber: _serialController.text.trim(),
      brand: _brandController.text.trim(),
      modelName: _modelController.text.trim(),
      sizeDn: _selectedSizeDn,
      deviceType: _selectedDeviceType,
      location: _locationController.text.trim(),
      upstreamPressureKpa: _upstreamPressure,
      firstCheckValueKpa: _firstCheckValve,
      reliefValveOpeningKpa: _reliefValveOpening,
      secondCheckValueKpa: _secondCheckValve,
      testerName: _testerController.text.trim(),
      testerLicence: _licenceController.text.trim(),
      testDate: DateTime.now(),
      isSubmitted: false,
    );

    ref.read(backflowProvider.notifier).addDevice(d);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00FF87),
        content: Text(
          'Successfully registered backflow hydraulic test. Added to Form 9 register ledger!',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );

    setState(() {
      _serialController.text = 'BF-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-Z';
    });
  }

  /// Lodgement trigger.
  void _lodgeForm9(String id) {
    ref.read(backflowProvider.notifier).submitForm9(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00FF87),
        content: Text(
          'Lodge Form 9 submitted successfully! Annual compliance registry recorded.',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// PDF print trigger.
  Future<void> _printForm9Pdf(BackflowDevice d) async {
    final pdfBytes = await PdfService().generateForm9Pdf(d);
    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: 'Form9_${d.serialNumber}.pdf',
    );
  }
}
