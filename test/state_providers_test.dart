import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';
import 'package:plumbnator/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('State Providers Tests', () {
    test('NavNotifier updates index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(navProvider), equals(0));
      
      container.read(navProvider.notifier).setIndex(2);
      expect(container.read(navProvider), equals(2));
    });

    test('SizingNotifier calculates Fixture Units correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sizingProvider.notifier);
      
      // Initial state
      expect(container.read(sizingProvider).totalFixtureUnits, equals(0));

      // Update Water Closet count (Weight is 4)
      notifier.updateFixtureCount('Water Closet (WC)', 2);
      // Update Basin count (Weight is 1)
      notifier.updateFixtureCount('Basin', 3);

      final state = container.read(sizingProvider);
      // 2 * 4 + 3 * 1 = 11
      expect(state.totalFixtureUnits, equals(11));

      // Minimum pipe size should update to 100 since FU > 10
      expect(state.minimumPipeSize, equals(100));

      // Recommended minimum grade for DN100 is 1.65%
      expect(state.minimumCompliantGrade, equals(1.65));
    });

    test('SizingNotifier calculates Water Loading Units correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sizingProvider.notifier);

      // Add Bath Tap (Weight 4) and Basin Tap (Weight 1)
      notifier.updateWaterFixtureCount('Bath Tap', 1);
      notifier.updateWaterFixtureCount('Basin Tap', 2);

      final state = container.read(sizingProvider);
      // 1 * 4 + 2 * 1 = 6
      expect(state.totalWaterLoadingUnits, equals(6));
      expect(state.recommendedWaterPipeSize, equals(15)); // LU <= 8 -> DN15
    });

    test('SwmsNotifier allows signing and adding profiles', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(swmsProvider.notifier);
      final initialState = container.read(swmsProvider);
      
      // Ensure seed data is present
      expect(initialState.length, equals(5));
      expect(initialState.first.isSigned, isFalse);

      // Sign the first profile
      notifier.signSwms(initialState.first.id, 'Jack Plumber');
      
      final signedState = container.read(swmsProvider);
      expect(signedState.first.isSigned, isTrue);
      expect(signedState.first.signedBy, equals('Jack Plumber'));

      // Add custom SWMS
      notifier.addCustomSwms('Fix Leaky Tap', ['Slip Hazard'], ['Wear non-slip boots']);
      
      final finalState = container.read(swmsProvider);
      expect(finalState.length, equals(6));
      expect(finalState.last.taskName, equals('Fix Leaky Tap'));
    });

    test('BackflowNotifier can submit form and add device', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(backflowProvider.notifier);
      final initialState = container.read(backflowProvider);

      expect(initialState.length, equals(3));
      final unsubmittedDevice = initialState.firstWhere((d) => !d.isSubmitted);
      
      // Submit form
      notifier.submitForm9(unsubmittedDevice.id);
      
      final updatedState = container.read(backflowProvider);
      final submittedDevice = updatedState.firstWhere((d) => d.id == unsubmittedDevice.id);
      expect(submittedDevice.isSubmitted, isTrue);

      // Add device
      final newDevice = BackflowDevice(
        id: 'new-bf',
        deviceType: 'Double Check Valve',
        brand: 'TestBrand',
        modelName: 'ModelX',
        serialNumber: '12345',
        sizeDn: 20,
        location: 'Backyard',
        testDate: DateTime.now(),
        upstreamPressureKpa: 500,
        firstCheckValueKpa: 10,
        reliefValveOpeningKpa: 0,
        secondCheckValueKpa: 10,
        testerName: 'Tester',
        testerLicence: '123',
      );

      notifier.addDevice(newDevice);
      
      final finalState = container.read(backflowProvider);
      expect(finalState.length, equals(4));
      expect(finalState.last.id, equals('new-bf'));
    });

    test('AssistantNotifier manages messages correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(assistantProvider.notifier);
      
      // Initial message
      expect(container.read(assistantProvider).messages.length, equals(1));
      
      // Changing model
      notifier.selectModel('New Model 5.0');
      expect(container.read(assistantProvider).selectedModel, equals('New Model 5.0'));

      // Clearing history keeps only the initial message
      notifier.clearHistory();
      expect(container.read(assistantProvider).messages.length, equals(1));
      expect(container.read(assistantProvider).selectedModel, equals('New Model 5.0'));
    });
  });
}
