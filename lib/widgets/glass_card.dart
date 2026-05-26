import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium, highly customizable Glassmorphic Card widget with hover effects.
/// Provides deep Gaussian blur, border lighting, and subtle gradients.
class GlassCard extends StatefulWidget {
  /// The content to display inside the card.
  final Widget child;

  /// Padding applied to the card's content.
  final EdgeInsetsGeometry padding;

  /// Border radius of the card corners.
  final double borderRadius;

  /// The border color of the card outline.
  final Color? borderColor;

  /// Gradient colors for the card background.
  final List<Color>? backgroundGradient;

  /// Gaussian blur intensity for the glass effect.
  final double blurAmount;

  /// Width of the card border outline.
  final double borderWidth;

  /// Whether to enable the hover lift effect on desktop.
  final bool enableHover;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius = 16.0,
    this.borderColor,
    this.backgroundGradient,
    this.blurAmount = 15.0,
    this.borderWidth = 1.0,
    this.enableHover = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderCol = widget.borderColor ?? Colors.white.withValues(alpha: 0.08);
    final gradientColors = widget.backgroundGradient ??
        [
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.01),
        ];

    // Subtle brightness boost on hover for desktop interactivity
    final hoverBorderCol = _isHovered
        ? borderCol.withValues(alpha: (borderCol.a + 0.06).clamp(0.0, 1.0))
        : borderCol;

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered && widget.enableHover
            ? Matrix4.translationValues(0.0, -1.5, 0.0)
            : Matrix4.identity(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurAmount,
              sigmaY: widget.blurAmount,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                border: Border.all(
                  color: hoverBorderCol,
                  width: widget.borderWidth,
                ),
                boxShadow: _isHovered && widget.enableHover
                    ? [
                        BoxShadow(
                          color: (widget.borderColor ?? const Color(0xFF00E6FF))
                              .withValues(alpha: 0.06),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
