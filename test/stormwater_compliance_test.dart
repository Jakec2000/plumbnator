import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Stormwater Compliance Math Tests', () {
    test('Calculates correct effective catchment area with slope factor', () {
      const state = StormwaterComplianceState(
        roofLength: 10.0,
        roofWidth: 5.0,
        roofPitch: 0.0, // flat
        rainfallZone: 'Brisbane',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Quad PVC',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: true,
        rainheadOverflow: false,
        downpipeCount: 1,
      );

      expect(state.effectiveCatchmentArea, closeTo(50.0, 0.01));
    });

    test('Calculates sloped roof surface multiplier correctly', () {
      const state = StormwaterComplianceState(
        roofLength: 10.0,
        roofWidth: 5.0,
        roofPitch: 45.0, // 45 degrees slope factor: 1 + 0.5 * tan(45) = 1.5
        rainfallZone: 'Brisbane',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Quad PVC',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: true,
        rainheadOverflow: false,
        downpipeCount: 1,
      );

      expect(state.effectiveCatchmentArea, closeTo(75.0, 0.01));
    });

    test('Rainfall intensity zone presets mapping matches QUDM limits', () {
      const bne = StormwaterComplianceState(
        roofLength: 10.0,
        roofWidth: 5.0,
        roofPitch: 0.0,
        rainfallZone: 'Brisbane',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Quad PVC',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: true,
        rainheadOverflow: false,
        downpipeCount: 1,
      );
      expect(bne.rainfallIntensity, 280.0);

      final cns = bne.copyWith(rainfallZone: 'Cairns');
      expect(cns.rainfallIntensity, 320.0);

      final twb = bne.copyWith(rainfallZone: 'Toowoomba');
      expect(twb.rainfallIntensity, 250.0);
    });

    test('Downpipe recommended dimensions check capacity bounds', () {
      const state = StormwaterComplianceState(
        roofLength: 15.0,
        roofWidth: 8.0,
        roofPitch: 22.5,
        rainfallZone: 'Cairns',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Colorbond Slotted',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: true,
        rainheadOverflow: false,
        downpipeCount: 2,
      );

      // Total Area = 15 * 8 * (1 + 0.5 * tan(22.5)) = 120 * 1.2071 = 144.85 m2
      // Cairns Intensity = 320 mm/hr
      // Flow = 144.85 * 320 / 3600 = 12.87 L/s
      // Per Downpipe = 6.43 L/s (Needs DN150)
      expect(state.recommendedDownpipeSize, 'DN150');
      expect(state.isDownpipeCompliant, true);
    });

    test('Gutter capacity and box gutter slope bounds compliance checks', () {
      const eavesQuad = StormwaterComplianceState(
        roofLength: 10.0,
        roofWidth: 5.0,
        roofPitch: 0.0,
        rainfallZone: 'Brisbane',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Quad PVC',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: true,
        rainheadOverflow: false,
        downpipeCount: 1,
      );

      // Flow = 50 * 280 / 3600 = 3.88 L/s
      // Quad PVC capacity max is 1.5 L/s -> Fails
      expect(eavesQuad.isGutterCapacityCompliant, false);

      final eavesSteel = eavesQuad.copyWith(gutterProfile: 'Colorbond Slotted');
      // Colorbond Slotted capacity is 3.2 L/s. Flow is 3.88 L/s -> Still fails
      expect(eavesSteel.isGutterCapacityCompliant, false);

      final eavesMultiDp = eavesSteel.copyWith(downpipeCount: 3);
      // Flow per DP = 3.88 / 3 = 1.29 L/s -> Passes
      expect(eavesMultiDp.isGutterCapacityCompliant, true);

      final boxFail = eavesQuad.copyWith(gutterType: 'Box Gutter', boxGutterSlope: 500.0);
      expect(boxFail.isBoxGutterSlopeCompliant, false);
      expect(boxFail.isFullyCompliant, false);
    });

    test('Overflow relief safeguards validation checks', () {
      const eavesNoOverflow = StormwaterComplianceState(
        roofLength: 10.0,
        roofWidth: 5.0,
        roofPitch: 0.0,
        rainfallZone: 'Brisbane',
        gutterType: 'Eaves Gutter',
        gutterProfile: 'Colorbond Slotted',
        downpipeStyle: 'Round',
        boxGutterSlope: 200.0,
        slottedOverflow: false,
        rainheadOverflow: false,
        downpipeCount: 2,
      );

      expect(eavesNoOverflow.isOverflowReliefCompliant, false);

      final eavesOverflow = eavesNoOverflow.copyWith(slottedOverflow: true);
      expect(eavesOverflow.isOverflowReliefCompliant, true);

      final boxNoOverflow = eavesNoOverflow.copyWith(gutterType: 'Box Gutter');
      expect(boxNoOverflow.isOverflowReliefCompliant, false);

      final boxOverflow = boxNoOverflow.copyWith(rainheadOverflow: true);
      expect(boxOverflow.isOverflowReliefCompliant, true);
    });
  });
}
