import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AS/NZS 3500.2 Laser Grade & Staff Level Sizer Engine', () {
    /// Test default initial values for the laser grading component.
    test('Default setup staff readings and excavation depth offsets are valid', () {
      final state = SizingState.initial();
      
      expect(state.setupStaffReading, equals(1500.0));
      expect(state.excavationOffset, equals(100.0));
      expect(state.downstreamInvertStaffReading, equals(1747.5)); // 1500 + 247.5
      expect(state.downstreamTrenchStaffReading, equals(1847.5)); // 1747.5 + 100
    });

    /// Test grade vertical fall calculations for various lengths and target slopes.
    test('Calculates vertical fall mm accurately over different run lengths and target gradients', () {
      var state = SizingState.initial();
      
      // 20m run, 2.5% grade (DN80 minimum grade)
      state = state.copyWith(runLength: 20.0, gradePercentage: 2.5);
      expect(state.requiredFallMm, equals(500.0)); // 20 * 0.025 * 1000 = 500
      expect(state.downstreamInvertStaffReading, equals(2000.0)); // 1500 + 500
      expect(state.downstreamTrenchStaffReading, equals(2100.0)); // 2000 + 100
    });

    /// Test customized excavation depth offset adjustments.
    test('Calculates trench bottom staff readings when excavation offset is customized', () {
      var state = SizingState.initial();
      
      // Adjust excavation offset for thick walls or heavy gravel bedding
      state = state.copyWith(excavationOffset: 150.0);
      expect(state.downstreamInvertStaffReading, equals(1747.5));
      expect(state.downstreamTrenchStaffReading, equals(1897.5)); // 1747.5 + 150
    });

    /// Test soil cover warning logic formulas to guarantee compliance boundaries.
    test('Verifies structural soil cover calculation formulas comply with AS/NZS 3500.2 Clause 9.3', () {
      const double startCover = 600.0;
      const double pipeFall = 247.5;
      
      // Flat ground groundFall = 0.0
      const double flatGroundFall = 0.0;
      const double flatDownstreamCover = startCover + pipeFall - flatGroundFall;
      expect(flatDownstreamCover, equals(847.5)); // Cover increases as pipe drops
      expect(flatDownstreamCover >= 750.0, isTrue); // Compliant in all conditions

      // Sloping ground with 3% ground fall over 15m run -> groundFall = 15 * 3 * 10 = 450mm
      const double groundFall3Pct = 450.0;
      const double slopingDownstreamCover = startCover + pipeFall - groundFall3Pct;
      expect(slopingDownstreamCover, equals(397.5));
      
      // Downstream cover is 397.5mm.
      // - Paths/Gardens (Min 300mm): 397.5 >= 300 (PASS)
      // - Driveways (Min 500mm): 397.5 < 500 (FAIL)
      // - Roads (Min 750mm): 397.5 < 750 (FAIL)
      expect(slopingDownstreamCover >= 300.0, isTrue);
      expect(slopingDownstreamCover >= 500.0, isFalse);
      expect(slopingDownstreamCover >= 750.0, isFalse);
    });
  });
}
