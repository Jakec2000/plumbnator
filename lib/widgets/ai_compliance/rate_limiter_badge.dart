import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_providers.dart';
import 'paywall_modal.dart';

/// Interactive daily usage cap display.
class RateLimiterBadge extends ConsumerWidget {
  const RateLimiterBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiAnalysisProvider);
    final isGold = aiState.dailyRemaining == 99999;
    final limitColor = isGold 
        ? const Color(0xFFFFD700) 
        : (aiState.canAnalyze ? const Color(0xFF00FF87) : const Color(0xFFFF416C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: limitColor.withValues(alpha: 0.08),
        border: Border.all(color: limitColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGold 
                ? Icons.workspace_premium_outlined 
                : (aiState.canAnalyze ? Icons.verified_outlined : Icons.lock_outline),
            color: limitColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isGold
                  ? 'PLUMBNATOR GOLD: Unlimited AS/NZS 3500 compliance scans unlocked!'
                  : (aiState.canAnalyze
                      ? 'Daily Usage Rate Limiter Active: ${aiState.dailyRemaining} / 5 analyses remaining today'
                      : 'Daily Limit Reached (5/5). Upgrade to Plumbnator Gold to scan unlimited installations.'),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: limitColor,
              ),
            ),
          ),
          if (!isGold) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () => PaywallModal.show(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Upgrade to Gold',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
