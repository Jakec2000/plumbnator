import 'package:flutter/material.dart';
import '../providers/state_providers.dart';

/// Renders a beautiful interactive vector schematic canvas for Stormwater installations.
class StormwaterSchematicPainter extends CustomPainter {
  final StormwaterComplianceState state;

  StormwaterSchematicPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _drawGridBackground(canvas, rect);
    
    // Determine status color
    final primaryColor = state.isFullyCompliant 
        ? const Color(0xFF00FF87) // Safe Neon Green
        : const Color(0xFFFF3366); // Warning Neon Pink

    // Draw Roof Catchment
    _drawRoof(canvas, size, primaryColor);

    // Draw Gutters
    _drawGutter(canvas, size, primaryColor);

    // Draw Downpipes
    _drawDownpipe(canvas, size, primaryColor);

    // Draw Overflow Relief Indicators
    _drawOverflowIndicators(canvas, size);
  }

  /// Renders background blueprint grid lines.
  void _drawGridBackground(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    for (double x = 0; x < rect.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, rect.height), gridPaint);
    }
    for (double y = 0; y < rect.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(rect.width, y), gridPaint);
    }
  }

  /// Draws the pitched catchment roof with active water currents.
  void _drawRoof(Canvas canvas, Size size, Color statusColor) {
    final roofPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.3) // Roof Peak
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.55) // Roof Eaves
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..close();

    canvas.drawPath(path, roofPaint);

    // Draw roof sheet ribs / lines
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 2.0;

    const ribs = 6;
    for (int i = 0; i <= ribs; i++) {
      final ratio = i / ribs;
      final startX = size.width * (0.1 + ratio * 0.6);
      final endX = size.width * (0.2 + ratio * 0.6);
      canvas.drawLine(
        Offset(startX, size.height * 0.3), 
        Offset(endX, size.height * 0.55), 
        ribPaint
      );
    }

    // Draw active rain vectors
    final rainPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 8; i++) {
      final rx = size.width * (0.15 + i * 0.08);
      canvas.drawLine(
        Offset(rx, size.height * 0.1),
        Offset(rx + 10, size.height * 0.25),
        rainPaint
      );
    }
  }

  /// Draws the sloped eaves or box gutter with flowing water level indicator.
  void _drawGutter(Canvas canvas, Size size, Color statusColor) {
    final isEaves = state.gutterType == 'Eaves Gutter';
    final hasCapacity = state.isGutterCapacityCompliant;

    final gutterPaint = Paint()
      ..color = isEaves 
          ? (state.gutterProfile == 'Quad PVC' ? const Color(0xFF475569) : const Color(0xFF94A3B8))
          : const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    // Draw horizontal run representing gutter sloped slightly downstream
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.57),
      Offset(size.width * 0.82, size.height * 0.58),
      gutterPaint
    );

    // Glowing Neon water stream inside the gutter
    final waterPaint = Paint()
      ..color = hasCapacity ? const Color(0xFF00E6FF) : const Color(0xFFFF3366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(size.width * 0.19, size.height * 0.575),
      Offset(size.width * 0.81, size.height * 0.582),
      waterPaint
    );
  }

  /// Draws downpipes corresponding to the selected style (round vs rectangular).
  void _drawDownpipe(Canvas canvas, Size size, Color statusColor) {
    final dpPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final waterColor = state.isDownpipeCompliant 
        ? const Color(0xFF00E6FF) 
        : const Color(0xFFFF3366);

    final waterFlowPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw downpipe count runs
    for (int i = 0; i < state.downpipeCount; i++) {
      final xOffset = size.width * (0.3 + (i * 0.4 / state.downpipeCount));
      
      if (state.downpipeStyle == 'Round') {
        // Round Downpipe Cylinder
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(xOffset, size.height * 0.58, 12, size.height * 0.3),
            const Radius.circular(6)
          ),
          dpPaint
        );
        // Water center line
        canvas.drawLine(
          Offset(xOffset + 6, size.height * 0.58),
          Offset(xOffset + 6, size.height * 0.88),
          waterFlowPaint
        );
      } else {
        // Rectangular Downpipe
        canvas.drawRect(
          Rect.fromLTWH(xOffset, size.height * 0.58, 16, size.height * 0.3),
          dpPaint
        );
        // Water double lines
        canvas.drawLine(
          Offset(xOffset + 4, size.height * 0.58),
          Offset(xOffset + 4, size.height * 0.88),
          waterFlowPaint
        );
        canvas.drawLine(
          Offset(xOffset + 12, size.height * 0.58),
          Offset(xOffset + 12, size.height * 0.88),
          waterFlowPaint
        );
      }
    }
  }

  /// Draws slot or rainhead overflow relief vectors if active.
  void _drawOverflowIndicators(Canvas canvas, Size size) {
    final overflowPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    if (state.gutterType == 'Eaves Gutter' && state.slottedOverflow) {
      // Draw slotted overflow droplets along the gutter length
      for (int i = 0; i < 10; i++) {
        final dx = size.width * (0.22 + i * 0.057);
        canvas.drawCircle(
          Offset(dx, size.height * 0.6 + (i % 2 == 0 ? 5.0 : 8.0)), 
          2.0, 
          overflowPaint
        );
      }
    } else if (state.gutterType == 'Box Gutter' && state.rainheadOverflow) {
      // Draw a box rainhead with overflow weir water cascade
      final headPaint = Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.fill;

      final rx = size.width * 0.82;
      canvas.drawRect(Rect.fromLTWH(rx - 10, size.height * 0.54, 25, 20), headPaint);
      
      // Cascading overflow water
      canvas.drawCircle(Offset(rx + 18, size.height * 0.56), 3.0, overflowPaint);
      canvas.drawCircle(Offset(rx + 22, size.height * 0.60), 2.5, overflowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StormwaterSchematicPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
