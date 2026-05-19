import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/services/gemini_service.dart';

void main() {
  group('Plumbnator QLD: Gemini Compliance Service Testing', () {
    final service = GeminiService();

    test('Returns precise diagnostic fallbacks for Tempering Valves when API key is empty', () async {
      final result = await service.checkCompliance(
        category: 'Tempering Valve',
        imageBytes: [1, 2, 3, 4],
      );

      expect(result['complianceScore'], equals(0.97));
      expect(result['passed'], isTrue);
      expect(result['clauses'], contains(contains('delivery temperature')));
      
      final hotspots = result['hotspots'] as List;
      expect(hotspots.length, equals(2));
      expect(hotspots[0]['title'], equals('Hot Inlet Feed'));
      expect(hotspots[0]['x'], equals(0.35));
    });

    test('Returns precise diagnostic fallbacks for Drainage Junctions when API key is empty', () async {
      final result = await service.checkCompliance(
        category: 'Drainage Junction',
        imageBytes: [1, 2, 3, 4],
      );

      expect(result['complianceScore'], equals(0.85));
      expect(result['passed'], isTrue);
      expect(result['clauses'], contains(contains('1.65% gradient')));

      final hotspots = result['hotspots'] as List;
      expect(hotspots.length, equals(1));
      expect(hotspots[0]['title'], equals('Junction Angle'));
      expect(hotspots[0]['y'], equals(0.50));
    });
  });
}
