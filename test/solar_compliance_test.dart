import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AS/NZS 3500.4 Solar & Heat Pump Compliance Sizer Tests', () {
    test('Default initial compliance state is correctly initialized', () {
      final state = SolarComplianceState.initial();

      expect(state.zone, equals('Zone 2'));
      expect(state.techType, equals('Solar Flat Plate'));
      expect(state.bedrooms, equals(3));
      expect(state.occupants, equals(4));
      expect(state.dailyDemand, equals(250.0));
      expect(state.collectorTilt, equals(30.0));
      expect(state.orientation, equals('North'));
      expect(state.setpointTemp, equals(60.0));
      expect(state.ptrRatingKpa, equals(850));
      expect(state.ecvRatingKpa, equals(700));
      expect(state.plvSettingKpa, equals(500));
      expect(state.shadingFactor, equals(0.0));
      
      // Defaults are compliant
      expect(state.isFullyCompliant, isTrue);
      expect(state.isLegionellaCompliant, isTrue);
      expect(state.isValveChainCompliant, isTrue);
      expect(state.isFrostCompliant, isTrue); // Zone 2 is not frost-prone
      expect(state.isSafeTrayCompliant, isTrue); // External install by default
    });

    test('Bedrooms and occupants helper calculations operate correctly', () {
      var state = SolarComplianceState.initial();

      // Occupants: 4 * 75 = 300L
      expect(state.calculatedDemandFromOccupants, equals(300.0));
      
      // Bedrooms: 3 Bed = 250L
      expect(state.calculatedDemandFromBedrooms, equals(250.0));

      // Overrides
      state = state.copyWith(bedrooms: 1, occupants: 2);
      expect(state.calculatedDemandFromBedrooms, equals(150.0));
      expect(state.calculatedDemandFromOccupants, equals(150.0));

      state = state.copyWith(bedrooms: 5, occupants: 6);
      expect(state.calculatedDemandFromBedrooms, equals(350.0));
      expect(state.calculatedDemandFromOccupants, equals(450.0));
    });

    test('Legionella set-point regulations are correctly audited', () {
      var state = SolarComplianceState.initial();

      state = state.copyWith(setpointTemp: 65.0);
      expect(state.isLegionellaCompliant, isTrue);

      state = state.copyWith(setpointTemp: 59.0);
      expect(state.isLegionellaCompliant, isFalse); // Below AS/NZS 3500.4 limit
    });

    test('Pressure valve coordination chain delta clearances are strictly verified', () {
      var state = SolarComplianceState.initial();

      // Default PLV=500, ECV=700, PTR=850 (PASS)
      expect(state.isValveChainCompliant, isTrue);

      // PLV too high (> 500 kPa)
      state = state.copyWith(plvSettingKpa: 550);
      expect(state.isPlvCompliant, isFalse);
      expect(state.isValveChainCompliant, isFalse);

      // ECV gap failure (< 100 kPa above PLV)
      state = state.copyWith(plvSettingKpa: 500, ecvRatingKpa: 550);
      expect(state.isEcvCompliant, isFalse);
      expect(state.isValveChainCompliant, isFalse);

      // PTR gap failure (< 150 kPa above ECV)
      state = state.copyWith(plvSettingKpa: 500, ecvRatingKpa: 700, ptrRatingKpa: 800);
      expect(state.isPtrCompliant, isFalse);
      expect(state.isValveChainCompliant, isFalse);
    });

    test('Thermal insulation recommendations dynamically adjust per climate region', () {
      var state = SolarComplianceState.initial();

      // Zone 2 (Brisbane) R0.3
      expect(state.requiredInsulationRValue, equals(0.3));
      expect(state.insulationRecommendation, contains('13mm'));

      // Zone 3 (Darling Downs) R0.6 (due to frost)
      state = state.copyWith(zone: 'Zone 3');
      expect(state.requiredInsulationRValue, equals(0.6));
      expect(state.insulationRecommendation, contains('25mm'));
    });

    test('Freeze protection audits strictly check Zone 3 requirements', () {
      var state = SolarComplianceState.initial();

      // Zone 2 (no freeze check required)
      expect(state.isFrostCompliant, isTrue);

      // Zone 3 with no protection
      state = state.copyWith(zone: 'Zone 3', hasFrostProtection: false);
      expect(state.isFrostCompliant, isFalse); // Non-compliant

      // Zone 3 with active protection
      state = state.copyWith(zone: 'Zone 3', hasFrostProtection: true);
      expect(state.isFrostCompliant, isTrue); // Compliant
    });

    test('Internal safe tray installation checklists work correctly', () {
      var state = SolarComplianceState.initial();

      // External, no tray (PASS)
      expect(state.isSafeTrayCompliant, isTrue);

      // Internal, no tray (FAIL)
      state = state.copyWith(isInternal: true, safeTrayInstalled: false);
      expect(state.isSafeTrayCompliant, isFalse);

      // Internal, tray installed (PASS)
      state = state.copyWith(isInternal: true, safeTrayInstalled: true);
      expect(state.isSafeTrayCompliant, isTrue);
    });

    test('Relief line metallic copper material checklists work correctly', () {
      var state = SolarComplianceState.initial();

      expect(state.isReliefLineCompliant, isTrue); // Copper by default

      state = state.copyWith(reliefIsCopper: false);
      expect(state.isReliefLineCompliant, isFalse); // PVC/PE relief line is non-compliant
    });

    test('Acoustical boundary buffers work correctly for heat pump systems', () {
      var state = SolarComplianceState.initial();

      // Heat pump, far boundary (PASS)
      state = state.copyWith(techType: 'Heat Pump', boundaryDistance: 5.0);
      expect(state.isAcousticCompliant, isTrue);

      // Heat pump, close boundary (FAIL)
      state = state.copyWith(techType: 'Heat Pump', boundaryDistance: 2.0);
      expect(state.isAcousticCompliant, isFalse); // Noise boundary issue
    });

    test('Solar flat plate and evacuated tube orientation factor penalties are calculated', () {
      var state = SolarComplianceState.initial();

      // Flat plate orientation weights
      state = state.copyWith(techType: 'Solar Flat Plate', orientation: 'North');
      expect(state.orientationFactor, equals(1.0));

      state = state.copyWith(techType: 'Solar Flat Plate', orientation: 'East');
      expect(state.orientationFactor, equals(0.80));

      state = state.copyWith(techType: 'Solar Flat Plate', orientation: 'South');
      expect(state.orientationFactor, equals(0.40));

      // Evacuated tubes orientation weights
      state = state.copyWith(techType: 'Solar Evacuated Tubes', orientation: 'East');
      expect(state.orientationFactor, equals(0.85));

      state = state.copyWith(techType: 'Solar Evacuated Tubes', orientation: 'South');
      expect(state.orientationFactor, equals(0.45));
    });

    test('Carbon offset and financial savings engine math is mathematically correct', () {
      var state = SolarComplianceState.initial();
      
      // Solar Flat Plate in Zone 2, North, no shading, 250L daily demand
      // Base energy = 3600 kWh
      // Savings = 3600 * 0.65 (efficiency) * 1.0 (orientation) * 1.0 (shading) = 2340 kWh
      // Annual financial savings = 2340 * 0.33 = $772.2
      // Carbon reduction = 2340 * 0.85 = 1989.0 kg CO2
      state = state.copyWith(
        techType: 'Solar Flat Plate',
        zone: 'Zone 2',
        orientation: 'North',
        shadingFactor: 0,
        dailyDemand: 250,
      );

      expect(state.annualEnergySavingsKwh, closeTo(2340.0, 0.1));
      expect(state.annualSavingsAud, closeTo(772.2, 0.1));
      expect(state.annualCarbonReductionKg, closeTo(1989.0, 0.1));
      
      // Verify shading scales down savings proportionally
      state = state.copyWith(shadingFactor: 20); // 20% shade reduction
      // Savings = 2340 * 0.8 = 1872 kWh
      expect(state.annualEnergySavingsKwh, closeTo(1872.0, 0.1));
    });

    test('STCs certificate and cash rebate calculations scale correctly', () {
      var state = SolarComplianceState.initial();

      // Zone 2 Flat Plate, North orientation, no shade, 250L demand -> base 26 STCs
      state = state.copyWith(
        zone: 'Zone 2',
        orientation: 'North',
        shadingFactor: 0,
        dailyDemand: 250,
      );

      expect(state.calculatedStcs, equals(26.0));
      expect(state.estimatedStcRebate, equals(26.0 * 38.0)); // $988

      // Zone 3 has base 24 STCs
      state = state.copyWith(zone: 'Zone 3');
      expect(state.calculatedStcs, equals(24.0));
    });
  });
}
