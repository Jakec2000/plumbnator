import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AS/NZS 3500.1 Water Supply Sizing Engine', () {
    test('Initial water supply state is configured correctly', () {
      final state = SizingState.initial();
      expect(state.sizingMode, equals(SizingMode.drainage));
      expect(state.totalWaterLoadingUnits, equals(0));
      expect(state.recommendedWaterPipeSize, equals(0));
      expect(state.estimatedWaterFlowRate, equals(0.0));
    });

    test('Sizing Mode toggling works properly', () {
      var state = SizingState.initial();
      state = state.copyWith(sizingMode: SizingMode.waterSupply);
      expect(state.sizingMode, equals(SizingMode.waterSupply));
    });

    test('Water Loading Unit accumulation and pipe sizing suggestions', () {
      var state = SizingState.initial().copyWith(sizingMode: SizingMode.waterSupply);

      // Add 2 WC Cisterns (2 * 2 = 4 LUs)
      final counts1 = Map<String, int>.from(state.waterFixtureCounts);
      counts1['WC Cistern (Dual Flush)'] = 2;
      state = state.copyWith(waterFixtureCounts: counts1);

      expect(state.totalWaterLoadingUnits, equals(4));
      // 4 LU is <= 8 -> DN15 recommended
      expect(state.recommendedWaterPipeSize, equals(15));
      expect(state.estimatedWaterFlowRate, closeTo(0.3, 0.05));

      // Add 1 Bath Tap (1 * 4 = 4 LUs) and 2 Basin Taps (2 * 1 = 2 LUs) -> Total 10 LUs
      final counts2 = Map<String, int>.from(state.waterFixtureCounts);
      counts2['Bath Tap'] = 1;
      counts2['Basin Tap'] = 2;
      state = state.copyWith(waterFixtureCounts: counts2);

      expect(state.totalWaterLoadingUnits, equals(10));
      // 10 LU is <= 20 -> DN20 recommended
      expect(state.recommendedWaterPipeSize, equals(20));
      expect(state.estimatedWaterFlowRate, closeTo(0.5, 0.05));
    });

    test('High fixture count resolves to DN25 and DN32', () {
      var state = SizingState.initial().copyWith(sizingMode: SizingMode.waterSupply);

      // Add 10 Kitchen Sink Taps (10 * 3 = 30 LUs) and 10 Shower Roses (10 * 2 = 20 LUs) -> Total 50 LUs
      final counts = Map<String, int>.from(state.waterFixtureCounts);
      counts['Kitchen Sink Tap'] = 10;
      counts['Shower Rose'] = 10;
      state = state.copyWith(waterFixtureCounts: counts);

      expect(state.totalWaterLoadingUnits, equals(50));
      expect(state.recommendedWaterPipeSize, equals(25));

      // Add 1 more Kitchen Sink Tap (1 * 3 = 3 LUs) -> Total 53 LUs
      counts['Kitchen Sink Tap'] = 11;
      state = state.copyWith(waterFixtureCounts: counts);

      expect(state.totalWaterLoadingUnits, equals(53));
      // 53 LU is <= 100 -> DN32 recommended
      expect(state.recommendedWaterPipeSize, equals(32));
    });
  });
}
