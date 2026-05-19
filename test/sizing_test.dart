import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AS/NZS 3500.2 Drainage Sizing Engine', () {
    test('Initial Calculator state is configured correctly', () {
      final state = SizingState.initial();
      expect(state.totalFixtureUnits, equals(0));
      expect(state.minimumPipeSize, equals(80));
      expect(state.minimumCompliantGrade, equals(2.50)); // DN80 min grade 2.50%
      expect(state.requiredFallMm, equals(247.5));
    });

    test('Calculation adapts when fixture counts increase', () {
      var state = SizingState.initial();

      // Add 2 WCs (2 * 4 = 8 FUs)
      final counts1 = Map<String, int>.from(state.fixtureCounts);
      counts1['Water Closet (WC)'] = 2;
      state = state.copyWith(fixtureCounts: counts1);

      expect(state.totalFixtureUnits, equals(8));
      expect(state.minimumPipeSize, equals(80));
      expect(state.minimumCompliantGrade, equals(2.50));

      // Add 1 washing machine (1 * 3 = 3 FUs), total = 11 FUs
      final counts2 = Map<String, int>.from(state.fixtureCounts);
      counts2['Washing Machine'] = 1;
      state = state.copyWith(fixtureCounts: counts2);

      expect(state.totalFixtureUnits, equals(11));
      // Over 10 FUs -> suggests DN100
      expect(state.minimumPipeSize, equals(100));
      // DN100 minimum grade is 1.65%
      expect(state.minimumCompliantGrade, equals(1.65));
    });

    test('Gradient evaluation calculations', () {
      var state = SizingState.initial();
      // Adjust run to 20m
      state = state.copyWith(runLength: 20.0, gradePercentage: 2.0);

      // Fall over 20m at 2.0% gradient: 20 * 1000 * 0.02 = 400.0 mm
      expect(state.requiredFallMm, equals(400.0));
    });
  });
}
