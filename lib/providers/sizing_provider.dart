import 'package:flutter_riverpod/flutter_riverpod.dart';



/// Available calculation modes for the hydraulic compliance sizer.
enum SizingMode { drainage, waterSupply, laserGrade }

/// State structure for the Hydraulic Sizing Calculator.
class SizingState {
  final SizingMode sizingMode;
  final Map<String, int> fixtureCounts;
  final Map<String, int> waterFixtureCounts;
  final double runLength; // Trench length in meters
  final double gradePercentage; // E.g., 1.65% or 2.50%
  final double setupStaffReading; // Setup staff reading at start (mm)
  final double excavationOffset;  // Trench bed offset (mm)

  const SizingState({
    required this.sizingMode,
    required this.fixtureCounts,
    required this.waterFixtureCounts,
    required this.runLength,
    required this.gradePercentage,
    required this.setupStaffReading,
    required this.excavationOffset,
  });

  /// Factory for default calculator state.
  factory SizingState.initial() {
    return const SizingState(
      sizingMode: SizingMode.drainage,
      fixtureCounts: {
        'Water Closet (WC)': 0,
        'Basin': 0,
        'Shower': 0,
        'Kitchen Sink': 0,
        'Washing Machine': 0,
      },
      waterFixtureCounts: {
        'WC Cistern (Dual Flush)': 0,
        'Basin Tap': 0,
        'Shower Rose': 0,
        'Kitchen Sink Tap': 0,
        'Washing Machine Tap': 0,
        'Hose Tap (DN20)': 0,
        'Bath Tap': 0,
      },
      runLength: 15.0,
      gradePercentage: 1.65,
      setupStaffReading: 1500.0,
      excavationOffset: 100.0,
    );
  }

  /// Calculates total Fixture Units (FUs) based on AS/NZS 3500.2 loading values.
  int get totalFixtureUnits {
    // AS/NZS 3500.2 Table 6.1 loading values
    const weights = {
      'Water Closet (WC)': 4,
      'Basin': 1,
      'Shower': 2,
      'Kitchen Sink': 3,
      'Washing Machine': 3,
    };

    int sum = 0;
    fixtureCounts.forEach((fixture, count) {
      sum += count * (weights[fixture] ?? 0);
    });
    return sum;
  }

  /// Suggests the minimum required drainage pipe size (DN) based on AS/NZS 3500.2 limit.
  int get minimumPipeSize {
    final fus = totalFixtureUnits;
    if (fus <= 10) return 80;
    if (fus <= 30) return 100;
    return 150;
  }

  /// Suggests compliant minimum grade (%) based on AS/NZS 3500.2.
  double get minimumCompliantGrade {
    final dn = minimumPipeSize;
    if (dn == 80) return 2.50; // 1:40
    if (dn == 100) return 1.65; // 1:60
    return 1.20; // 1:80 for DN150
  }

  /// Computes the required height drop (fall) over the run length.
  double get requiredFallMm {
    return (runLength * 1000) * (gradePercentage / 100);
  }

  /// Calculates the downstream pipe invert laser staff reading (mm).
  double get downstreamInvertStaffReading {
    return setupStaffReading + requiredFallMm;
  }

  /// Calculates the downstream trench bed excavation laser staff reading (mm).
  double get downstreamTrenchStaffReading {
    return downstreamInvertStaffReading + excavationOffset;
  }

  /// Calculates total Loading Units (LUs) for water supply based on AS/NZS 3500.1 Table 3.2.
  int get totalWaterLoadingUnits {
    const weights = {
      'WC Cistern (Dual Flush)': 2,
      'Basin Tap': 1,
      'Shower Rose': 2,
      'Kitchen Sink Tap': 3,
      'Washing Machine Tap': 3,
      'Hose Tap (DN20)': 3,
      'Bath Tap': 4,
    };

    int sum = 0;
    waterFixtureCounts.forEach((fixture, count) {
      sum += count * (weights[fixture] ?? 0);
    });
    return sum;
  }

  /// Suggests minimum compliant main pipe diameter (DN) based on AS/NZS 3500.1 Loading Units.
  int get recommendedWaterPipeSize {
    final lu = totalWaterLoadingUnits;
    if (lu == 0) return 0;
    if (lu <= 8) return 15;
    if (lu <= 20) return 20;
    if (lu <= 50) return 25;
    if (lu <= 100) return 32;
    return 40;
  }

  /// Computes approximate flow rate (L/s) based on AS/NZS 3500.1 loading unit conversion guidelines.
  double get estimatedWaterFlowRate {
    final lu = totalWaterLoadingUnits;
    if (lu == 0) return 0.0;
    if (lu <= 5) return 0.15 + (lu - 1) * 0.05;
    if (lu <= 15) return 0.35 + (lu - 5) * 0.03;
    if (lu <= 50) return 0.65 + (lu - 15) * 0.015;
    return 1.18 + (lu - 50) * 0.008;
  }

  /// Creates a copy of SizingState with optional overrides.
  SizingState copyWith({
    SizingMode? sizingMode,
    Map<String, int>? fixtureCounts,
    Map<String, int>? waterFixtureCounts,
    double? runLength,
    double? gradePercentage,
    double? setupStaffReading,
    double? excavationOffset,
  }) {
    return SizingState(
      sizingMode: sizingMode ?? this.sizingMode,
      fixtureCounts: fixtureCounts ?? this.fixtureCounts,
      waterFixtureCounts: waterFixtureCounts ?? this.waterFixtureCounts,
      runLength: runLength ?? this.runLength,
      gradePercentage: gradePercentage ?? this.gradePercentage,
      setupStaffReading: setupStaffReading ?? this.setupStaffReading,
      excavationOffset: excavationOffset ?? this.excavationOffset,
    );
  }
}

/// Riverpod Notifier for the Sizing Calculator state.
class SizingNotifier extends Notifier<SizingState> {
  @override
  SizingState build() {
    return SizingState.initial();
  }

  /// Toggles between drainage and water supply sizing modes.
  void updateSizingMode(SizingMode mode) {
    state = state.copyWith(sizingMode: mode);
  }

  /// Updates a drainage fixture count.
  void updateFixtureCount(String fixture, int count) {
    final counts = Map<String, int>.from(state.fixtureCounts);
    counts[fixture] = count.clamp(0, 50);
    state = state.copyWith(fixtureCounts: counts);
  }

  /// Updates a water fixture count.
  void updateWaterFixtureCount(String fixture, int count) {
    final counts = Map<String, int>.from(state.waterFixtureCounts);
    counts[fixture] = count.clamp(0, 50);
    state = state.copyWith(waterFixtureCounts: counts);
  }

  /// Updates the run length.
  void updateRunLength(double length) {
    state = state.copyWith(runLength: length.clamp(1.0, 500.0));
  }

  /// Updates the grade percentage.
  void updateGradePercentage(double grade) {
    state = state.copyWith(gradePercentage: grade.clamp(0.5, 10.0));
  }

  /// Updates the laser setup staff reading.
  void updateSetupStaffReading(double val) {
    state = state.copyWith(setupStaffReading: val.clamp(100.0, 5000.0));
  }

  /// Updates the bedding and excavation depth offset.
  void updateExcavationOffset(double val) {
    state = state.copyWith(excavationOffset: val.clamp(0.0, 1000.0));
  }

  /// Resets sizing inputs to zero/initial states.
  void reset() {
    state = SizingState.initial();
  }
}

/// Provider for hydraulic sizing calculator.
final sizingProvider = NotifierProvider<SizingNotifier, SizingState>(SizingNotifier.new);

