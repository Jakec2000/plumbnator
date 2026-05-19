import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium, highly customizable Glassmorphic Card widget.
/// Provides deep Gaussian blur, border lighting, and subtle gradients.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final List<Color>? backgroundGradient;
  final double blurAmount;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius = 16.0,
    this.borderColor,
    this.backgroundGradient,
    this.blurAmount = 15.0,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol = borderColor ?? Colors.white.withOpacity(0.08);
    final gradientColors = backgroundGradient ??
        [
          Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.01),
        ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: Border.all(
              color: borderCol,
              width: borderWidth,
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
