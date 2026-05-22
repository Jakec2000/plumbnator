import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Gas Compliance & Ventilation Math Tests', () {
    test('Converts gas MJ/h load to volumetric flow rates correctly', () {
      const ngState = GasComplianceState(
        gasType: 'Natural Gas',
        pipeMaterial: 'Copper',
        totalLoad: 76.0, // 76 MJ/h / 38 = 2.0 m3/h
        pipeLength: 10.0,
        pipeDiameter: 'DN20',
        roomVolume: 15.0,
        ventFreeArea: 1000.0,
        ventsProperlyPositioned: true,
        hasSolenoidShutoff: false,
        regulatorInstalled: true,
      );

      expect(ngState.gasFlowRate, closeTo(2.0, 0.01));

      final lpgState = ngState.copyWith(gasType: 'LPG', totalLoad: 190.0); // 190 MJ/h / 95 = 2.0 m3/h
      expect(lpgState.gasFlowRate, closeTo(2.0, 0.01));
    });

    test('Pressure drop friction curves calculation is calibrated properly', () {
      const state = GasComplianceState(
        gasType: 'Natural Gas',
        pipeMaterial: 'Copper',
        totalLoad: 38.0,
        pipeLength: 15.0,
        pipeDiameter: 'DN20', // ID is 18.0 mm
        roomVolume: 30.0,
        ventFreeArea: 1000.0,
        ventsProperlyPositioned: true,
        hasSolenoidShutoff: false,
        regulatorInstalled: true,
      );

      expect(state.calculatedPressureDrop, lessThan(state.maxAllowedPressureDrop));
      expect(state.isPressureDropCompliant, true);
    });

    test('Identifies confined spaces boundary correctly (Clause 6.4)', () {
      const state = GasComplianceState(
        gasType: 'Natural Gas',
        pipeMaterial: 'Copper',
        totalLoad: 100.0, // Confined space if Room volume < 0.07 * 100 = 7.0 m3
        pipeLength: 10.0,
        pipeDiameter: 'DN20',
        roomVolume: 10.0, // 10.0 >= 7.0 (Not confined)
        ventFreeArea: 0.0,
        ventsProperlyPositioned: false,
        hasSolenoidShutoff: false,
        regulatorInstalled: true,
      );

      expect(state.isConfinedSpace, false);
      expect(state.isVentilationCompliant, true); // Vents not required since room is not confined

      final confined = state.copyWith(roomVolume: 5.0); // 5.0 < 7.0 (Confined)
      expect(confined.isConfinedSpace, true);
      expect(confined.isVentilationCompliant, false); // Vents now required and missing
    });

    test('Confined room required aperture area updates correctly', () {
      const state = GasComplianceState(
        gasType: 'Natural Gas',
        pipeMaterial: 'Copper',
        totalLoad: 100.0,
        pipeLength: 10.0,
        pipeDiameter: 'DN20',
        roomVolume: 5.0, // Confined
        ventFreeArea: 20000.0, // 20,000 mm2
        ventsProperlyPositioned: true,
        hasSolenoidShutoff: false,
        regulatorInstalled: true,
      );

      // Required area = 100 * 300 = 30,000 mm2
      expect(state.requiredVentilationArea, 30000.0);
      expect(state.isVentilationCompliant, false); // 20,000 < 30,000

      final fullyCompliant = state.copyWith(ventFreeArea: 35000.0);
      expect(fullyCompliant.isVentilationCompliant, true); // 35,000 >= 30,000
    });
  });
}
