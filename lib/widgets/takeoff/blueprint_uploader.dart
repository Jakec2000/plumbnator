import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlueprintUploader extends StatefulWidget {
  final VoidCallback onUpload;

  const BlueprintUploader({super.key, required this.onUpload});

  @override
  State<BlueprintUploader> createState() => _BlueprintUploaderState();
}

class _BlueprintUploaderState extends State<BlueprintUploader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onUpload,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final glowValue = _controller.value;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: _isHovering 
                    ? const Color(0xFF00E6FF).withValues(alpha: 0.1) 
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00E6FF).withValues(alpha: _isHovering ? 0.6 : (0.2 + (glowValue * 0.2))),
                  width: _isHovering ? 2 : 1,
                ),
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E6FF).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: const Color(0xFF00E6FF).withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Blueprint / Plan',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supports PDF, PNG, JPG. Gemini Vision will extract the plumbing layout.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
