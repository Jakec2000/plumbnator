import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Camera presets matching the statutory plumbing audit criteria.
enum CameraPreset {
  hws,
  gradient,
  stack,
  valve,
}

/// A highly interactive, premium, grid-guided compliance camera viewfinder dialog.
/// Integrates dynamic sensory sliders, bubble levels, custom blueprint painters,
/// and live AS/NZS statutory references to support the yes-man plumber.
class CameraCaptureDialog extends StatefulWidget {
  final Function(String category, String measuredDeviation) onCapture;

  const CameraCaptureDialog({super.key, required this.onCapture});

  static void show(
    BuildContext context,
    Function(String category, String measuredDeviation) onCapture,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => CameraCaptureDialog(onCapture: onCapture),
    );
  }

  @override
  State<CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<CameraCaptureDialog> with SingleTickerProviderStateMixin {
  CameraPreset _activePreset = CameraPreset.hws;
  double _sliderValue = 0.0; // Dynamic slider input
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Set initial preset default values
    _resetSensorForPreset(_activePreset);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resetSensorForPreset(CameraPreset preset) {
    setState(() {
      _activePreset = preset;
      switch (preset) {
        case CameraPreset.hws:
          _sliderValue = 0.5; // Alignment centering
          break;
        case CameraPreset.gradient:
          _sliderValue = 1.0; // In degrees, initially unaligned (under 1.65%)
          break;
        case CameraPreset.stack:
          _sliderValue = -2.5; // In degrees, initially tilted out of plumb
          break;
        case CameraPreset.valve:
          _sliderValue = 6.0; // Lagging thickness in mm, initially sub-standard
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate sensory state variables based on active preset
    double angle = 0.0;
    double gradePercent = 0.0;
    double laggingMm = 0.0;
    bool isCompliant = false;
    String alignmentTelemetryText = '';
    String standardReferenceClause = '';
    String statutoryRuleSummary = '';
    String qldQbccNotice = '';

    switch (_activePreset) {
      case CameraPreset.hws:
        // HWS is aligned if centering slider is near middle (0.4 to 0.6)
        isCompliant = _sliderValue >= 0.4 && _sliderValue <= 0.6;
        alignmentTelemetryText = isCompliant ? 'Cylinder Centered' : 'Out of Bounds';
        standardReferenceClause = 'AS/NZS 3500.4 Cl 5.11 / 5.9';
        statutoryRuleSummary = 'Safe tray must drain to approved terminal points. Relief lines must drain with a continuous fall.';
        qldQbccNotice = 'QBCC REGULATORY NOTE: Lodgement of Form 4 with QBCC is mandatory within 10 business days of installation.';
        break;

      case CameraPreset.gradient:
        // Slider value represents slope in degrees (from 0.0 to 3.0)
        angle = _sliderValue;
        // Grade % = tan(angle in radians) * 100
        gradePercent = math.tan(angle * math.pi / 180) * 100;
        // Compliant range: 1.65% to 2.50%
        isCompliant = gradePercent >= 1.65 && gradePercent <= 2.50;
        alignmentTelemetryText = '${gradePercent.toStringAsFixed(2)}% Gradient';
        standardReferenceClause = 'AS/NZS 3500.2 Table 3.2';
        statutoryRuleSummary = 'Minimum sanitary drain fall for DN 100 is 1.65% (1:60). Max compliant grade is 2.50% (1:40).';
        qldQbccNotice = 'QLD INSPECTION NOTE: Below ground drainage works must remain open for local council inspector approval.';
        break;

      case CameraPreset.stack:
        // Slider value represents vertical plumbing tilt deviation in degrees (-3.0 to +3.0)
        angle = _sliderValue;
        // Compliant if vertical stack deviation is <= 1.0 degree
        isCompliant = angle.abs() <= 1.0;
        alignmentTelemetryText = '${angle.abs().toStringAsFixed(1)}° Plumb Deviation';
        standardReferenceClause = 'AS/NZS 3500.2 Cl 6.1';
        statutoryRuleSummary = 'Vertical drainage stacks and vents must not deviate more than 1.0° from absolute plumb vertical lines.';
        qldQbccNotice = 'COMPLIANCE CLEARANCE: Dual base anchor brackets and intermediate expansion joints must be visually certified.';
        break;

      case CameraPreset.valve:
        // Slider value represents lagging insulation thickness in mm (from 0.0 to 20.0)
        laggingMm = _sliderValue;
        // Compliant if lagging thickness is >= 13mm
        isCompliant = laggingMm >= 13.0;
        alignmentTelemetryText = '${laggingMm.toStringAsFixed(0)}mm Insulation Lagging';
        standardReferenceClause = 'AS/NZS 3500.4 Clause 5.9';
        statutoryRuleSummary = 'Minimum 13mm closed-cell elastomeric insulation lagging required on the first 1.0m from heated water systems.';
        qldQbccNotice = 'SCALD PREVENTION: Valve calibration limits hot water delivery at sanitary basins to a strict max of 50°C.';
        break;
    }

    final accentColor = isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: const Color(0xFF030509),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLUMB-SCANNER VIEWFINDER',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E6FF),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompliant ? 'ALIGNMENT LOCKED' : 'CALIBRATING SENSORS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                  ),
                ],
              ),
            ),

            // 2. Viewfinder Viewport Stack
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
                    color: Colors.black,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder Grid Overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: PlumbingBlueprintPainter(
                            preset: _activePreset,
                            sliderValue: _sliderValue,
                            isCompliant: isCompliant,
                            angle: angle,
                            pulseValue: _pulseController.value,
                          ),
                        ),
                      ),

                      // Holographic Focus Target
                      IgnorePointer(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00E6FF).withValues(
                                alpha: 0.15 + (_pulseController.value * 0.2),
                              ),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E6FF).withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Floating Bubble Level Gauge (For Drain & Stack Alignment)
                      if (_activePreset == CameraPreset.gradient || _activePreset == CameraPreset.stack)
                        Positioned(
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'LEVEL',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 80,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Compliance boundaries marker inside level
                                      Container(
                                        width: _activePreset == CameraPreset.gradient ? 24 : 16,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                                          border: const Border.symmetric(
                                            vertical: BorderSide(color: Color(0xFF00FF87), width: 0.5),
                                          ),
                                        ),
                                      ),
                                      // Moving Bubble
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 100),
                                        // Map angle to offset position
                                        left: _computeBubbleOffset(_activePreset, _sliderValue),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: accentColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: accentColor.withValues(alpha: 0.4),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Holographic Statutory Overlay
                      if (isCompliant)
                        Positioned(
                          bottom: 16,
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                                border: Border.all(color: const Color(0xFF00FF87), width: 1),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, color: Color(0xFF00FF87), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ALIGNMENT LOCKED • STATUTORY MET',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00FF87),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF416C).withValues(alpha: 0.15),
                              border: Border.all(color: const Color(0xFFFF416C), width: 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFFF416C), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  _activePreset == CameraPreset.gradient
                                      ? 'ADJUST GRADE SLIDER FOR COMPLIANT ANGLE'
                                      : (_activePreset == CameraPreset.stack
                                          ? 'ADJUST TILT TO ALIGN STACK PLUMB'
                                          : (_activePreset == CameraPreset.hws
                                              ? 'CENTER TANK INSIDE GREEN VIEWFINDER'
                                              : 'ADJUST INSULATION TO MIN 13MM')),
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF416C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Horizontal Preset Selector List
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CameraPreset.values.map((preset) {
                    final isSelected = _activePreset == preset;
                    String title = '';
                    IconData icon = Icons.help_outline;

                    switch (preset) {
                      case CameraPreset.hws:
                        title = 'HWS Cylinder';
                        icon = Icons.propane_tank_outlined;
                        break;
                      case CameraPreset.gradient:
                        title = 'Drain Grade';
                        icon = Icons.architecture_outlined;
                        break;
                      case CameraPreset.stack:
                        title = 'Plumb Stack';
                        icon = Icons.align_vertical_bottom_outlined;
                        break;
                      case CameraPreset.valve:
                        title = 'Insulation Lagging';
                        icon = Icons.layers_outlined;
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(title),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _resetSensorForPreset(preset);
                          }
                        },
                        labelStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.white60,
                        ),
                        selectedColor: const Color(0xFF00E6FF),
                        backgroundColor: Colors.white.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF00E6FF) : Colors.white10,
                          ),
                        ),
                        avatar: Icon(
                          icon,
                          size: 14,
                          color: isSelected ? Colors.black : Colors.white60,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 4. Interactive Sensory Alignment Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _activePreset == CameraPreset.gradient
                            ? 'Simulated Gradient Grade Fall:'
                            : (_activePreset == CameraPreset.stack
                                ? 'Simulated Plumb Stack Tilt:'
                                : (_activePreset == CameraPreset.hws
                                    ? 'Cylinder Center Offset:'
                                    : 'Insulation Lagging Thickness:')),
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                      ),
                      Text(
                        alignmentTelemetryText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accentColor,
                      inactiveTrackColor: Colors.white10,
                      thumbColor: accentColor,
                      overlayColor: accentColor.withValues(alpha: 0.15),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _sliderValue,
                      min: _activePreset == CameraPreset.gradient
                          ? 0.0
                          : (_activePreset == CameraPreset.stack
                              ? -3.0
                              : (_activePreset == CameraPreset.hws ? 0.0 : 0.0)),
                      max: _activePreset == CameraPreset.gradient
                          ? 3.0
                          : (_activePreset == CameraPreset.stack
                              ? 3.0
                              : (_activePreset == CameraPreset.hws ? 1.0 : 20.0)),
                      onChanged: (val) {
                        setState(() {
                          _sliderValue = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 5. AS/NZS Code Standard Guidance Drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  color: Colors.white.withValues(alpha: 0.01),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: Color(0xFF00E6FF), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          standardReferenceClause,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00E6FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statutoryRuleSummary,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.yellow.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        qldQbccNotice,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFCC00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Action Triggers
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        String presetNameText = '';
                        switch (_activePreset) {
                          case CameraPreset.hws:
                            presetNameText = 'HWS Preset';
                            break;
                          case CameraPreset.gradient:
                            presetNameText = 'Drain Gradient';
                            break;
                          case CameraPreset.stack:
                            presetNameText = 'Drainage Stack';
                            break;
                          case CameraPreset.valve:
                            presetNameText = 'Tempering Valve';
                            break;
                        }
                        widget.onCapture(presetNameText, alignmentTelemetryText);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF87),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        'Check Compliance',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculates bubble offset inside horizontal level container (0 to 70 range).
  double _computeBubbleOffset(CameraPreset preset, double val) {
    if (preset == CameraPreset.gradient) {
      // Scale from degrees [0.0 to 3.0] down to [0 to 70] offset
      // Center standard grade target (1.65% to 2.5% matches ~0.95° to ~1.43°). Let's put 0.95° to 1.43° near center.
      final normalized = (val / 3.0).clamp(0.0, 1.0);
      return normalized * 70.0;
    } else if (preset == CameraPreset.stack) {
      // Scale vertical tilt from [-3.0 to +3.0] down to [0 to 70] offset.
      // Offset center is 0.0 deviation.
      final normalized = ((val + 3.0) / 6.0).clamp(0.0, 1.0);
      return normalized * 70.0;
    }
    return 35.0; // default centered
  }
}

/// Custom painter rendering gorgeous, statutory architectural blueprints on viewfinder.
class PlumbingBlueprintPainter extends CustomPainter {
  final CameraPreset preset;
  final double sliderValue;
  final bool isCompliant;
  final double angle;
  final double pulseValue;

  PlumbingBlueprintPainter({
    required this.preset,
    required this.sliderValue,
    required this.isCompliant,
    required this.angle,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Viewport Background Grid (10% Opacity)
    final gridPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    const gridCellSize = 25.0;
    for (double x = 0; x < w; x += gridCellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridCellSize) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final accentPaint = Paint()
      ..color = isCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF416C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Dynamic color helper
    final neonCyanPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = isCompliant 
          ? const Color(0xFF00FF87).withValues(alpha: 0.04) 
          : const Color(0xFFFF416C).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // 2. Draw blueprint outlines based on active preset
    switch (preset) {
      case CameraPreset.hws:
        // Draw cylindrical hot water cylinder silhouette
        final centerX = w / 2;
        final centerY = h / 2;
        
        // Dynamic horizontal tank shift based on slider offset (slider range: 0.0 to 1.0)
        final tankShift = (sliderValue - 0.5) * (w * 0.4);
        final tankLeft = centerX - 40 + tankShift;
        final tankRight = centerX + 40 + tankShift;
        final tankTop = centerY - 65;
        final tankBottom = centerY + 55;

        final tankRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(tankLeft, tankTop, tankRight, tankBottom),
          const Radius.circular(8),
        );
        canvas.drawRRect(tankRect, fillPaint);
        canvas.drawRRect(tankRect, accentPaint);

        // Draw top & bottom cap lines
        canvas.drawLine(Offset(tankLeft, tankTop + 15), Offset(tankRight, tankTop + 15), neonCyanPaint);
        canvas.drawLine(Offset(tankLeft, tankBottom - 15), Offset(tankRight, tankBottom - 15), neonCyanPaint);

        // Draw Safe Tray outer containment zone at bottom
        final trayRect = Rect.fromLTRB(centerX - 55, tankBottom + 2, centerX + 55, tankBottom + 10);
        canvas.drawRect(trayRect, Paint()..color = const Color(0xFF00E6FF).withValues(alpha: 0.1));
        canvas.drawRect(trayRect, neonCyanPaint);
        break;

      case CameraPreset.gradient:
        // Draw Drainage pipe gradient baseline & fall targets
        final centerY = h / 2;
        
        // Drawing baseline pipe horizontal guide
        canvas.drawLine(Offset(20, centerY + 30), Offset(w - 20, centerY + 30), neonCyanPaint);

        // Draw sloped envelope (1:60 to 1:40 target angle guidelines)
        final envelopePaint = Paint()
          ..color = const Color(0xFF00FF87).withValues(alpha: 0.15)
          ..style = PaintingStyle.fill;

        final path = Path()
          ..moveTo(20, centerY + 20)
          // 1.65% slope endpoint: angle 0.95°
          ..lineTo(w - 20, centerY + 20 - ((w - 40) * math.tan(0.95 * math.pi / 180)))
          // 2.5% slope endpoint: angle 1.43°
          ..lineTo(w - 20, centerY + 20 - ((w - 40) * math.tan(1.43 * math.pi / 180)))
          ..close();
        canvas.drawPath(path, envelopePaint);

        // Draw the sloped compliance pipe line controlled by slider value (in degrees)
        final measuredAngleRad = angle * math.pi / 180;
        final pipeEndX = w - 30;
        final pipeEndY = (centerY + 20) - ((pipeEndX - 30) * math.tan(measuredAngleRad));

        final pipePaint = Paint()
          ..color = accentPaint.color
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(30, centerY + 20), Offset(pipeEndX, pipeEndY), pipePaint);

        // Pulsing circular pipe joins
        canvas.drawCircle(Offset(30, centerY + 20), 4, Paint()..color = accentPaint.color);
        canvas.drawCircle(Offset(pipeEndX, pipeEndY), 4, Paint()..color = accentPaint.color);
        break;

      case CameraPreset.stack:
        // Draw vertical plumb stack guidelines
        final centerX = w / 2;

        // Ideal Plumb Vertical Line
        final plumbPaint = Paint()
          ..color = const Color(0xFF00E6FF).withValues(alpha: 0.3)
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(centerX, 15), Offset(centerX, h - 15), plumbPaint);

        // 1.0° plumb tolerance boundary lines
        final tolerancePaint = Paint()
          ..color = const Color(0xFF00FF87).withValues(alpha: 0.2)
          ..strokeWidth = 0.5;
        final devOffset = (h - 30) * math.tan(1.0 * math.pi / 180);
        canvas.drawLine(Offset(centerX - devOffset, 15), Offset(centerX - devOffset, h - 15), tolerancePaint);
        canvas.drawLine(Offset(centerX + devOffset, 15), Offset(centerX + devOffset, h - 15), tolerancePaint);

        // The actual pipe stack rotated by current slider tilt angle
        final stackPaint = Paint()
          ..color = accentPaint.color
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke;

        final actualDevOffset = (h - 30) * math.tan(angle * math.pi / 180);
        canvas.drawLine(Offset(centerX, h - 20), Offset(centerX + actualDevOffset, 20), stackPaint);

        // Draw structural support clamping brackets indicators at bottom & top
        canvas.drawRect(Rect.fromLTWH(centerX - 10, h - 45, 20, 6), Paint()..color = Colors.white24);
        canvas.drawRect(Rect.fromLTWH(centerX + (actualDevOffset * 0.7) - 10, 45, 20, 6), Paint()..color = Colors.white24);
        break;

      case CameraPreset.valve:
        // Draw Tempering Valve target crosshair circles & insulation zones
        final centerX = w / 2;
        final centerY = h / 2;

        // Central valve core shape outline
        final valvePaint = Paint()
          ..color = accentPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        
        final valvePath = Path()
          ..moveTo(centerX - 20, centerY)
          ..lineTo(centerX + 20, centerY)
          ..moveTo(centerX, centerY - 10)
          ..lineTo(centerX, centerY + 20);
        canvas.drawPath(valvePath, valvePaint);

        // Insulation lagging boundary (slider controls thickness in mm 0 to 20, compliant is >=13)
        final laggingRadius = 30.0 + (sliderValue * 2.0);
        canvas.drawCircle(
          Offset(centerX, centerY),
          laggingRadius,
          Paint()
            ..color = accentPaint.color.withValues(alpha: 0.05)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(centerX, centerY),
          laggingRadius,
          Paint()
            ..color = accentPaint.color.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        // Minimum 13mm statutory boundary guideline
        canvas.drawCircle(
          Offset(centerX, centerY),
          56.0, // represents 13mm standard
          Paint()
            ..color = const Color(0xFF00FF87).withValues(alpha: 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PlumbingBlueprintPainter oldDelegate) {
    return oldDelegate.preset != preset ||
        oldDelegate.sliderValue != sliderValue ||
        oldDelegate.isCompliant != isCompliant ||
        oldDelegate.angle != angle ||
        oldDelegate.pulseValue != pulseValue;
  }
}
