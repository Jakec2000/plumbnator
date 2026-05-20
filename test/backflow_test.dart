import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plumbnator/models/models.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AS 2845.3 Backflow Testing Engine Tests', () {
    test('RPZD diagnostic validation passes for compliant parameters', () {
      final rpz = BackflowDevice(
        id: '1',
        serialNumber: 'SN-001',
        brand: 'Watts',
        modelName: '009',
        sizeDn: 25,
        deviceType: 'RPZD',
        location: 'Fire Line',
        upstreamPressureKpa: 500,
        firstCheckValueKpa: 40.0, // Pass >= 35 kPa
        reliefValveOpeningKpa: 15.0, // Pass >= 14 kPa
        secondCheckValueKpa: 8.0, // Pass >= 7 kPa
        testerName: 'Jack Czek',
        testerLicence: 'QBCC-1509923',
        testDate: DateTime.now(),
      );

      expect(rpz.passesInspection, isTrue);
    });

    test('RPZD diagnostic validation fails if relief valve opening < 14 kPa', () {
      final rpz = BackflowDevice(
        id: '1',
        serialNumber: 'SN-001',
        brand: 'Watts',
        modelName: '009',
        sizeDn: 25,
        deviceType: 'RPZD',
        location: 'Fire Line',
        upstreamPressureKpa: 500,
        firstCheckValueKpa: 40.0,
        reliefValveOpeningKpa: 12.0, // Fails < 14 kPa
        secondCheckValueKpa: 8.0,
        testerName: 'Jack Czek',
        testerLicence: 'QBCC-1509923',
        testDate: DateTime.now(),
      );

      expect(rpz.passesInspection, isFalse);
    });

    test('Double Check Valve diagnostic validation', () {
      final dcvPass = BackflowDevice(
        id: '2',
        serialNumber: 'SN-002',
        brand: 'Febco',
        modelName: '805Y',
        sizeDn: 25,
        deviceType: 'Double Check Valve',
        location: 'Kitchen Feed',
        upstreamPressureKpa: 450,
        firstCheckValueKpa: 8.0, // Pass >= 7 kPa
        reliefValveOpeningKpa: 0,
        secondCheckValueKpa: 7.0, // Pass >= 7 kPa
        testerName: 'Sarah Jenkins',
        testerLicence: 'QBCC-2248810',
        testDate: DateTime.now(),
      );

      final dcvFail = BackflowDevice(
        id: '2',
        serialNumber: 'SN-002',
        brand: 'Febco',
        modelName: '805Y',
        sizeDn: 25,
        deviceType: 'Double Check Valve',
        location: 'Kitchen Feed',
        upstreamPressureKpa: 450,
        firstCheckValueKpa: 5.0, // Fail < 7 kPa
        reliefValveOpeningKpa: 0,
        secondCheckValueKpa: 8.0,
        testerName: 'Sarah Jenkins',
        testerLicence: 'QBCC-2248810',
        testDate: DateTime.now(),
      );

      expect(dcvPass.passesInspection, isTrue);
      expect(dcvFail.passesInspection, isFalse);
    });

    test('Riverpod backflowProvider manages and submits Form 9 states', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Check initial seed items
      final initialDevices = container.read(backflowProvider);
      expect(initialDevices.length, equals(3));
      expect(initialDevices[0].isSubmitted, isFalse);

      // Submit Form 9 for bf-1
      container.read(backflowProvider.notifier).submitForm9('bf-1');
      final updatedDevices = container.read(backflowProvider);
      expect(updatedDevices.firstWhere((d) => d.id == 'bf-1').isSubmitted, isTrue);

      // Add a new device
      final newDevice = BackflowDevice(
        id: 'bf-test-4',
        serialNumber: 'SN-TEST-4',
        brand: 'Watts',
        modelName: 'RPZ',
        sizeDn: 50,
        deviceType: 'RPZD',
        location: 'Irrigation',
        upstreamPressureKpa: 490,
        firstCheckValueKpa: 38,
        reliefValveOpeningKpa: 16,
        secondCheckValueKpa: 9,
        testerName: 'Jack Czek',
        testerLicence: 'QBCC-1509923',
        testDate: DateTime.now(),
      );

      container.read(backflowProvider.notifier).addDevice(newDevice);
      final finalDevices = container.read(backflowProvider);
      expect(finalDevices.length, equals(4));
      expect(finalDevices.last.id, equals('bf-test-4'));
    });
  });
}
