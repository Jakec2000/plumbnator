import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumbnator/services/rate_limiter_service.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator Gold Subscription Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Standard rate limiter restricts after 5 scans, but Gold bypasses it completely', () async {
      final rateLimiter = RateLimiterService();

      // Verify original capacity allows scans
      expect(await rateLimiter.canAnalyze(), isTrue);

      // Consume the daily 5 scans
      for (int i = 0; i < 5; i++) {
        await rateLimiter.recordAnalysis();
      }

      // Assert rate limit lock activates
      expect(await rateLimiter.canAnalyze(), isFalse);

      // Opt-in / purchase Plumbnator Gold
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_gold_member', true);

      // Assert rate limit has been cleanly bypassed
      expect(await rateLimiter.canAnalyze(), isTrue);
    });

    test('Riverpod AiAnalysisNotifier resolves to unlimited state on upgradeToGold', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Flush microtasks
      await Future.delayed(Duration.zero);

      final notifier = container.read(aiAnalysisProvider.notifier);
      final initialState = container.read(aiAnalysisProvider);

      expect(initialState.canAnalyze, isTrue);
      expect(initialState.dailyRemaining, equals(5));

      // Trigger the upgrade payment loop
      await notifier.upgradeToGold();

      final updatedState = container.read(aiAnalysisProvider);
      expect(updatedState.canAnalyze, isTrue);
      expect(updatedState.dailyRemaining, equals(99999));
    });
  });
}
