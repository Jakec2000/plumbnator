import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/state_providers.dart';

/// Interactive premium vector painter illustrating AS/NZS 3500.4 hydraulic sizer details.
class SolarSchematicPainter extends CustomPainter {
  final SolarComplianceState state;

  const SolarSchematicPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _drawGridBackground(canvas, rect);
    
    // Position metrics for the layouts
    final tankCenter = Offset(size.width * 0.65, size.height * 0.55);
    final tankWidth = size.width * 0.22;
    final tankHeight = size.height * 0.55;
    
    // Draw Safe Tray (AS/NZS 3500.4 Cl 4.6) under tank if internal
    if (state.isInternal) {
      _drawSafeTray(canvas, tankCenter, tankWidth, tankHeight);
    }
    
    _drawCylinder(canvas, tankCenter, tankWidth, tankHeight);
    _drawEnergySource(canvas, size);
    _drawPipingAndValves(canvas, size, tankCenter, tankWidth, tankHeight);
    _drawReliefDrains(canvas, size, tankCenter, tankWidth, tankHeight);
  }

  /// Renders a sleek tech grid backing to fit Plumbnator's premium design.
  void _drawGridBackground(Canvas canvas, Rect rect) {
    final gridPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    
    const step = 20.0;
    for (double x = rect.left; x < rect.right; x += step) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
    for (double y = rect.top; y < rect.bottom; y += step) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }
  }

  /// Draws the main thermal cylinder with a warm-to-cool neon gradient.
  void _drawCylinder(Canvas canvas, Offset center, double width, double height) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16.0));
    
    // Warm top (Legionella safe) to cool bottom gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          state.isLegionellaCompliant ? Colors.orange.withValues(alpha: 0.85) : Colors.red.withValues(alpha: 0.85),
          Colors.blue.withValues(alpha: 0.4),
        ],
      ).createShader(rect);
    
    final strokePaint = Paint()
      ..color = state.isLegionellaCompliant ? Colors.cyan.withValues(alpha: 0.7) : Colors.red.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, strokePaint);

    // Dynamic temperature label overlay
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TEMP: ${state.setpointTemp.toStringAsFixed(0)}°C\n'
            '${state.isLegionellaCompliant ? "LEGIONELLA SAFE" : "RISK: < 60°C"}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 4.0)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  /// Draws the energy source: either Solar collectors or a Heat Pump compressor module.
  void _drawEnergySource(Canvas canvas, Size size) {
    final srcRect = Rect.fromLTWH(size.width * 0.08, size.height * 0.35, size.width * 0.28, size.height * 0.38);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (state.techType == 'Heat Pump') {
      borderPaint.color = Colors.teal.withValues(alpha: 0.85);
      canvas.drawRRect(RRect.fromRectAndRadius(srcRect, const Radius.circular(12.0)), Paint()..color = Colors.teal.withValues(alpha: 0.12));
      canvas.drawRRect(RRect.fromRectAndRadius(srcRect, const Radius.circular(12.0)), borderPaint);
      
      // Draw a vector compressor fan circle
      final fanCenter = Offset(srcRect.center.dx, srcRect.center.dy - 10);
      canvas.drawCircle(fanCenter, 35.0, Paint()..color = Colors.black.withValues(alpha: 0.3));
      canvas.drawCircle(fanCenter, 35.0, borderPaint);
      canvas.drawCircle(fanCenter, 5.0, borderPaint..style = PaintingStyle.fill);
      
      // Fan blades
      final bladePaint = Paint()
        ..color = Colors.teal.withValues(alpha: 0.8)
        ..strokeWidth = 4.0;
      for (double a = 0; a < 2 * pi; a += pi / 3) {
        canvas.drawLine(fanCenter, Offset(fanCenter.dx + 30 * cos(a), fanCenter.dy + 30 * sin(a)), bladePaint);
      }
      
      _drawText(canvas, Offset(srcRect.left + 10, srcRect.bottom - 22), 'HP COMPRESSOR\nCOP: ${state.estimatedCop.toStringAsFixed(1)}x', Colors.tealAccent);
    } else {
      // Solar collectors (Flat plate / tubes) angled at the collectorTilt setting
      borderPaint.color = Colors.orangeAccent.withValues(alpha: 0.85);
      canvas.save();
      
      final pivot = Offset(srcRect.left, srcRect.bottom);
      canvas.translate(pivot.dx, pivot.dy);
      // Limit tilt visual rotation slightly for rendering aesthetics
      canvas.rotate(-state.collectorTilt * pi / 180.0 * 0.5);
      
      final collectorRect = Rect.fromLTWH(0, -srcRect.height, srcRect.width, srcRect.height);
      canvas.drawRect(collectorRect, Paint()..color = Colors.blueGrey.withValues(alpha: 0.35));
      canvas.drawRect(collectorRect, borderPaint);
      
      // Grid lines inside solar collector
      final linePaint = Paint()..color = Colors.cyan.withValues(alpha: 0.4)..strokeWidth = 1.5;
      for (double offset = 20.0; offset < srcRect.width; offset += 20.0) {
        canvas.drawLine(Offset(offset, -srcRect.height), Offset(offset, 0), linePaint);
      }
      
      canvas.restore();
      
      _drawText(
        canvas,
        Offset(srcRect.left + 5, srcRect.bottom + 8),
        'SOLAR PANELS (${state.orientation})\nTILT: ${state.collectorTilt.toStringAsFixed(0)}° / SHADE: ${state.shadingFactor.toStringAsFixed(0)}%',
        Colors.orangeAccent,
      );
    }
  }

  /// Helper to draw a text label on the canvas.
  void _drawText(Canvas canvas, Offset offset, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  /// Draws safe tray details beneath internal installations (AS/NZS 3500.4 Cl 4.6).
  void _drawSafeTray(Canvas canvas, Offset tankCenter, double tankWidth, double tankHeight) {
    final trayWidth = tankWidth + 30.0;
    final trayRect = Rect.fromLTWH(
      tankCenter.dx - trayWidth / 2,
      tankCenter.dy + tankHeight / 2 - 2,
      trayWidth,
      12.0,
    );
    
    // Draw metallic safe tray catching leaks
    canvas.drawRect(
      trayRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade700],
        ).createShader(trayRect),
    );
    
    // Independent drain line running outwards
    final drainPaint = Paint()
      ..color = state.safeTrayInstalled ? Colors.grey : Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final drainPath = Path()
      ..moveTo(trayRect.right - 8, trayRect.bottom)
      ..lineTo(trayRect.right - 8, trayRect.bottom + 20)
      ..lineTo(trayRect.right + 20, trayRect.bottom + 20);
    
    canvas.drawPath(drainPath, drainPaint);
    _drawText(
      canvas,
      Offset(trayRect.right + 5, trayRect.bottom + 25),
      state.safeTrayInstalled ? 'SAFE TRAY COMPLIANT' : 'SAFE TRAY MISSING!',
      state.safeTrayInstalled ? Colors.grey : Colors.redAccent,
    );
  }

  /// Renders standard cold and hot copper piping runs, including core control valves.
  void _drawPipingAndValves(Canvas canvas, Size size, Offset tankCenter, double tankWidth, double tankHeight) {
    final coldInX = size.width * 0.05;
    final coldY = tankCenter.dy + tankHeight * 0.38;
    final coldMainsY = size.height * 0.88;
    
    // Paint tokens for styling
    final coldPipePaint = Paint()..color = Colors.blue.withValues(alpha: 0.85)..strokeWidth = 4.0..style = PaintingStyle.stroke;
    final hotPipePaint = Paint()..color = Colors.orange.withValues(alpha: 0.85)..strokeWidth = 4.0..style = PaintingStyle.stroke;
    
    // Cold Inflow Line
    final coldPath = Path()
      ..moveTo(coldInX, coldMainsY)
      ..lineTo(tankCenter.dx - tankWidth / 2 - 25, coldMainsY)
      ..lineTo(tankCenter.dx - tankWidth / 2 - 25, coldY)
      ..lineTo(tankCenter.dx - tankWidth / 2, coldY);
    
    canvas.drawPath(coldPath, coldPipePaint);

    // Draw Cold Inlet Valve Icons
    // 1. PLV (Mains Pressure Limiting Valve)
    final plvOffset = Offset(coldInX + 45, coldMainsY);
    _drawValveSymbol(canvas, plvOffset, 'PLV', state.isPlvCompliant ? Colors.blue : Colors.redAccent);
    
    // 2. Duo Valve (Isolating & Check combo)
    final duoOffset = Offset(tankCenter.dx - tankWidth / 2 - 25, coldMainsY - 45);
    _drawValveSymbol(canvas, duoOffset, 'DUO', state.isDuoValveCompliant ? Colors.blue : Colors.redAccent);

    // 3. ECV (Expansion Control Valve)
    final ecvOffset = Offset(tankCenter.dx - tankWidth / 2 - 12, coldY);
    _drawValveSymbol(canvas, ecvOffset, 'ECV', state.isEcvCompliant ? Colors.blue : Colors.redAccent);

    // Hot Piping from top of Cylinder, with heat trap loop (AS/NZS 3500.4 Cl 8.2.2)
    final hotStartY = tankCenter.dy - tankHeight * 0.42;
    final hotTrapDepth = state.heatTrapInstalled ? 25.0 : 0.0;
    
    final hotPath = Path()
      ..moveTo(tankCenter.dx + 10, hotStartY)
      ..lineTo(tankCenter.dx + 10, hotStartY - 15);
    
    if (state.heatTrapInstalled) {
      hotPath
        ..lineTo(tankCenter.dx + 40, hotStartY - 15)
        ..lineTo(tankCenter.dx + 40, hotStartY - 15 + hotTrapDepth) // Downward loop
        ..lineTo(tankCenter.dx + 65, hotStartY - 15 + hotTrapDepth)
        ..lineTo(tankCenter.dx + 65, hotStartY - 40);
    } else {
      hotPath
        ..lineTo(tankCenter.dx + 65, hotStartY - 15)
        ..lineTo(tankCenter.dx + 65, hotStartY - 40);
    }
    
    // Tempering Mixing line
    final tempValY = hotStartY - 55;
    hotPath.lineTo(tankCenter.dx + 65, tempValY);
    canvas.drawPath(hotPath, hotPipePaint);
    
    // Draw Heat Trap Label
    _drawText(
      canvas,
      Offset(tankCenter.dx + 70, hotStartY - 10),
      state.heatTrapInstalled ? 'HEAT TRAP (PASS)' : 'NO HEAT TRAP (FAIL)',
      state.heatTrapInstalled ? Colors.orangeAccent : Colors.redAccent,
    );

    // Tempering Valve & Outlets
    final tvOffset = Offset(tankCenter.dx + 65, tempValY);
    _drawValveSymbol(canvas, tvOffset, 'TMV', Colors.purpleAccent);
    
    // Pipe connecting cold to tempering mixing valve
    final coldMixPath = Path()
      ..moveTo(tankCenter.dx - tankWidth / 2 - 25, coldY)
      ..lineTo(tankCenter.dx - tankWidth / 2 - 25, tempValY)
      ..lineTo(tvOffset.dx - 10, tempValY);
    canvas.drawPath(coldMixPath, coldPipePaint);

    // Final outlet deliver line
    final deliveryPath = Path()
      ..moveTo(tvOffset.dx, tvOffset.dy - 12)
      ..lineTo(tvOffset.dx + 50, tvOffset.dy - 12)
      ..lineTo(tvOffset.dx + 50, tvOffset.dy - 45);
    
    final temperedPaint = Paint()..color = Colors.purple.withValues(alpha: 0.85)..strokeWidth = 4.0..style = PaintingStyle.stroke;
    canvas.drawPath(deliveryPath, temperedPaint);
    
    _drawText(
      canvas,
      Offset(tvOffset.dx + 42, tvOffset.dy - 60),
      'SHOWER/BATHS\nMAX ${state.maxTargetDeliveryTemp}°C',
      Colors.purpleAccent,
    );
  }

  /// Draws the valve control triangle symbols.
  void _drawValveSymbol(Canvas canvas, Offset offset, String label, Color color) {
    final fillPaint = Paint()..color = color.withValues(alpha: 0.35)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = color..strokeWidth = 2.0..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(offset.dx - 8, offset.dy - 6)
      ..lineTo(offset.dx + 8, offset.dy + 6)
      ..lineTo(offset.dx + 8, offset.dy - 6)
      ..lineTo(offset.dx - 8, offset.dy + 6)
      ..close();
      
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    canvas.drawCircle(offset, 4.0, strokePaint..style = PaintingStyle.fill);
    
    _drawText(canvas, Offset(offset.dx - 12, offset.dy - 18), label, color);
  }

  /// Renders relief safety discharge lines (AS/NZS 3500.4 Cl 5.12).
  void _drawReliefDrains(Canvas canvas, Size size, Offset tankCenter, double tankWidth, double tankHeight) {
    // Top tank PTR relief
    final ptrY = tankCenter.dy - tankHeight * 0.35;
    final ptrOffset = Offset(tankCenter.dx + tankWidth / 2, ptrY);
    _drawValveSymbol(canvas, ptrOffset, 'PTR', Colors.redAccent);
    
    // Draw relief piping. If copper, draw glowing orange/gold; if PVC/PE, draw warning plastic red line.
    final reliefPaint = Paint()
      ..color = state.reliefIsCopper ? Colors.amber.shade700 : Colors.redAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final reliefPath = Path()
      ..moveTo(ptrOffset.dx + 8, ptrOffset.dy)
      ..lineTo(size.width * 0.94, ptrOffset.dy)
      ..lineTo(size.width * 0.94, size.height * 0.88)
      ..lineTo(size.width * 0.88, size.height * 0.88);
    
    // Join ECV discharge into safety line
    final ecvY = tankCenter.dy + tankHeight * 0.38;
    final ecvReliefPath = Path()
      ..moveTo(tankCenter.dx - tankWidth / 2 - 12, ecvY)
      ..lineTo(tankCenter.dx - tankWidth / 2 - 40, ecvY)
      ..lineTo(tankCenter.dx - tankWidth / 2 - 40, size.height * 0.82)
      ..lineTo(size.width * 0.94, size.height * 0.82);
    
    canvas.drawPath(reliefPath, reliefPaint);
    canvas.drawPath(ecvReliefPath, reliefPaint);
    
    // Draw approved Gully termination point
    final gullyCenter = Offset(size.width * 0.88, size.height * 0.88);
    canvas.drawCircle(gullyCenter, 8.0, Paint()..color = Colors.blueGrey);
    canvas.drawCircle(gullyCenter, 8.0, Paint()..color = Colors.cyan..style = PaintingStyle.stroke..strokeWidth = 2.0);
    
    _drawText(
      canvas,
      Offset(size.width * 0.80, size.height * 0.92),
      'GULLY TRAP DRAIN\n'
      '${state.reliefIsCopper ? "COPPER PIPE (PASS)" : "PVC Relieving (FAIL!)"}',
      state.reliefIsCopper ? Colors.cyan : Colors.redAccent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
