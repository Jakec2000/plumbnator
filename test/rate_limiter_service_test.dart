import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumbnator/services/rate_limiter_service.dart';

void main() {
  group('RateLimiterService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state allows analysis and daily count starts at max remaining', () async {
      final service = RateLimiterService();
      final allowed = await service.canAnalyze();
      expect(allowed, isTrue);
    });

    test('Increments count properly and blocks after 5 evaluations', () async {
      final service = RateLimiterService();
      
      for (int i = 0; i < 5; i++) {
        expect(await service.canAnalyze(), isTrue);
        await service.recordAnalysis();
      }

      // 6th analysis should be blocked
      expect(await service.canAnalyze(), isFalse);
    });
  });
}
