import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';



/// Riverpod Notifier for the Backflow Prevention Device state.
class BackflowNotifier extends Notifier<List<BackflowDevice>> {
  @override
  List<BackflowDevice> build() {
    return [
      BackflowDevice(
        id: 'bf-1',
        serialNumber: 'BF-88902-Z',
        brand: 'Conbraco / Apollo',
        modelName: 'RPZ 4A',
        sizeDn: 50,
        deviceType: 'RPZD',
        location: 'Main Front Boundary Site 1',
        upstreamPressureKpa: 520.0,
        firstCheckValueKpa: 42.0,
        reliefValveOpeningKpa: 18.0,
        secondCheckValueKpa: 12.0,
        testerName: 'Jack Czek',
        testerLicence: 'QBCC-1509923',
        testDate: DateTime.now().subtract(const Duration(days: 2)),
        isSubmitted: false,
      ),
      BackflowDevice(
        id: 'bf-2',
        serialNumber: 'BF-33411-X',
        brand: 'Watts Regulator',
        modelName: '007 Double Check',
        sizeDn: 25,
        deviceType: 'Double Check Valve',
        location: 'Level 1 Kitchenette Feed',
        upstreamPressureKpa: 450.0,
        firstCheckValueKpa: 5.0, // Fails AS 2845.3 limit of 7.0 kPa
        reliefValveOpeningKpa: 0.0,
        secondCheckValueKpa: 8.0,
        testerName: 'Sarah Jenkins',
        testerLicence: 'QBCC-2248810',
        testDate: DateTime.now().subtract(const Duration(days: 15)),
        isSubmitted: false,
      ),
      BackflowDevice(
        id: 'bf-3',
        serialNumber: 'BF-99201-A',
        brand: 'Febco',
        modelName: '825Y RPZ',
        sizeDn: 80,
        deviceType: 'RPZD',
        location: 'Boiler Make-up Line',
        upstreamPressureKpa: 510.0,
        firstCheckValueKpa: 45.0,
        reliefValveOpeningKpa: 22.0,
        secondCheckValueKpa: 10.0,
        testerName: 'Jack Czek',
        testerLicence: 'QBCC-1509923',
        testDate: DateTime.now().subtract(const Duration(days: 30)),
        isSubmitted: true,
      ),
    ];
  }

  /// Adds a new backflow device record.
  void addDevice(BackflowDevice device) {
    state = [...state, device];
  }

  /// Submits the Form 9 to council.
  void submitForm9(String id) {
    state = [
      for (final device in state)
        if (device.id == id) device.copyWith(isSubmitted: true) else device
    ];
  }

  /// Resets backflow data.
  void reset() {
    ref.invalidateSelf();
  }
}

final backflowProvider = NotifierProvider<BackflowNotifier, List<BackflowDevice>>(BackflowNotifier.new);

