import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/providers/state_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Plumbnator QLD: WHS SWMS Upgrade Tests', () {
    test('Initial seeded SWMS profiles are configured correctly with 5 default items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final swms = container.read(swmsProvider);
      
      expect(swms.length, equals(5));
      expect(swms[0].taskName, equals('Hot Work / Copper Silver-Brazing'));
      expect(swms[1].taskName, equals('Excavation & Trenching (> 1.5m)'));
      expect(swms[2].taskName, equals('Working at Heights / Roof Plumbing'));
      expect(swms[3].taskName, equals('Confined Space Entry - Sewers & Main Holes'));
      expect(swms[4].taskName, equals('High-Pressure Sewer Jetting Operations'));

      // Verify some hazards are properly seeded
      expect(swms[2].hazards, contains('Falls from height / roof edge (severe injury or death)'));
      expect(swms[3].controlMeasures, contains('Conduct gas testing using calibrated multi-gas detector prior to entry'));
      expect(swms[4].controlMeasures, contains('Use a foot control valve to enable instantaneous water pressure shut-off'));
    });

    test('addCustomSwms appends a custom bespoke SWMS profile dynamically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(swmsProvider.notifier);

      notifier.addCustomSwms(
        'Custom Hot Water Tank Lift',
        ['Heavy lifting causing muscle strain', 'Drop hazard'],
        ['Use team lift or mechanical aid', 'Wear steel-cap boots'],
      );

      final swms = container.read(swmsProvider);
      expect(swms.length, equals(6));
      expect(swms.last.taskName, equals('Custom Hot Water Tank Lift'));
      expect(swms.last.hazards, contains('Heavy lifting causing muscle strain'));
      expect(swms.last.controlMeasures, contains('Wear steel-cap boots'));
      expect(swms.last.isSigned, isFalse);
    });

    test('signSwms digitally signs a specific SWMS profile successfully', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(swmsProvider.notifier);

      notifier.signSwms('swms-1', 'Jack Czek');

      final swms = container.read(swmsProvider);
      final profile = swms.firstWhere((p) => p.id == 'swms-1');

      expect(profile.isSigned, isTrue);
      expect(profile.signedBy, equals('Jack Czek'));
      expect(profile.signedAt, isNotNull);
    });
  });
}
