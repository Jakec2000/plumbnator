import 'package:flutter/material.dart';
import '../providers/state_providers.dart';

/// Renders a beautiful interactive vector schematic canvas for Gas fitting and ventilation.
class GasSchematicPainter extends CustomPainter {
  final GasComplianceState state;

  GasSchematicPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _drawGridBackground(canvas, rect);

    final compliant = state.isFullyCompliant;
    final primaryColor = compliant 
        ? const Color(0xFF00E6FF) // Cyan Normal Flow
        : const Color(0xFFFF3366); // Warning Pink

    // Draw Room boundary and ventilation vents
    _drawRoomAndVents(canvas, size);

    // Draw Gas Source (LPG Cylinders vs NG Meter)
    _drawGasSource(canvas, size);

    // Draw Pipeline Run with Gauges
    _drawPipeline(canvas, size, primaryColor);

    // Draw Gas Appliance (Cooktop burner with flame)
    _drawAppliance(canvas, size);
  }

  /// Renders background blueprint grid lines.
  void _drawGridBackground(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFF070B14)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    for (double x = 0; x < rect.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, rect.height), gridPaint);
    }
    for (double y = 0; y < rect.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(rect.width, y), gridPaint);
    }
  }

  /// Draws room environment bounding box and ventilation opening slots.
  void _drawRoomAndVents(Canvas canvas, Size size) {
    final isConfined = state.isConfinedSpace;
    final isCompliant = state.isVentilationCompliant;

    final roomPaint = Paint()
      ..color = isConfined
          ? (isCompliant ? const Color(0xFF1E293B) : const Color(0xFF451A22))
          : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isConfined
          ? (isCompliant ? const Color(0xFF334155) : const Color(0xFFFF3366))
          : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Room bounding box on right half
    final roomRect = Rect.fromLTWH(
      size.width * 0.45, 
      size.height * 0.15, 
      size.width * 0.5, 
      size.height * 0.7
    );
    canvas.drawRect(roomRect, roomPaint);
    canvas.drawRect(roomRect, borderPaint);

    // Draw Vents
    if (isConfined) {
      final ventPaint = Paint()
        ..color = const Color(0xFF00FF87)
        ..style = PaintingStyle.fill;

      // Upper vent slot
      if (state.ventsProperlyPositioned) {
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.93, size.height * 0.18, 12, 20), 
          ventPaint
        );
        // Lower vent slot
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.93, size.height * 0.75, 12, 20), 
          ventPaint
        );
      }
    }
  }

  /// Draws gas supply source: Tall LPG gas bottles vs Utility NG meter.
  void _drawGasSource(Canvas canvas, Size size) {
    final metalPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    if (state.gasType == 'LPG') {
      // Draw 2 LPG Bottles on Left side
      for (int i = 0; i < 2; i++) {
        final bx = size.width * (0.08 + i * 0.07);
        final bottleRect = Rect.fromLTWH(bx, size.height * 0.45, 20, 60);
        canvas.drawRRect(
          RRect.fromRectAndRadius(bottleRect, const Radius.circular(5)), 
          metalPaint
        );
        // Red safety collars
        final collarPaint = Paint()..color = const Color(0xFFEF4444);
        canvas.drawRect(Rect.fromLTWH(bx, size.height * 0.45, 20, 8), collarPaint);
      }
    } else {
      // Draw Natural Gas Meter
      final boxPaint = Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.08, size.height * 0.48, 30, 40), 
          const Radius.circular(4)
        ), 
        boxPaint
      );
      // Renders dial meter glass
      final dialPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.54), 10.0, dialPaint);
    }
  }

  /// Renders copper vs PEX pipelines, safety valves, and pressure indicators.
  void _drawPipeline(Canvas canvas, Size size, Color statusColor) {
    final isCopper = state.pipeMaterial == 'Copper';
    
    // Pipe base trace
    final pipePaint = Paint()
      ..color = isCopper ? const Color(0xFFB45309) : const Color(0xFFEAB308) // Amber copper vs yellow PEX
      ..style = PaintingStyle.stroke
      ..strokeWidth = state.innerDiameter / 2.0;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.65);

    canvas.drawPath(path, pipePaint);

    // Regulator & Valves
    if (state.regulatorInstalled) {
      final regPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.55), 8.0, regPaint);
    }

    if (state.hasSolenoidShutoff) {
      // Glow indicator for solenoid safety valve
      final solenoidPaint = Paint()
        ..color = const Color(0xFF00FF87)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.52, 10, 12), solenoidPaint);
    }

    // Pressure Gauge indicator on flow end
    final gaugeColor = state.isPressureDropCompliant ? const Color(0xFF00FF87) : const Color(0xFFFF3366);
    final gaugePaint = Paint()..color = gaugeColor;
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.65), 6.0, gaugePaint);
  }

  /// Draws appliance (cooktop burner stove) with burning blue neon flame.
  void _drawAppliance(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;

    final px = size.width * 0.65;
    final py = size.height * 0.65;

    // Stove frame
    canvas.drawRect(Rect.fromLTWH(px, py - 15, 60, 30), bodyPaint);

    // Blue gas flame indicators
    final flamePaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final flamePath = Path()
      ..moveTo(px + 20, py - 15)
      ..quadraticBezierTo(px + 25, py - 35, px + 30, py - 15)
      ..moveTo(px + 35, py - 15)
      ..quadraticBezierTo(px + 40, py - 40, px + 45, py - 15)
      ..close();

    canvas.drawPath(flamePath, flamePaint);
  }

  @override
  bool shouldRepaint(covariant GasSchematicPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
