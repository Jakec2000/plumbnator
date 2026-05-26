import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;



/// State structure for Stormwater Drainage & Gutter Sizer (AS/NZS 3500.3).
class StormwaterComplianceState {
  final double roofLength;
  final double roofWidth;
  final double roofPitch; // degrees
  final String rainfallZone; // 'Brisbane', 'Cairns', 'Toowoomba'
  final String gutterType; // 'Eaves Gutter', 'Box Gutter'
  final String gutterProfile; // 'Quad PVC' (Cheapest), 'Colorbond Slotted' (Premium)
  final String downpipeStyle; // 'Round', 'Rectangular'
  final double boxGutterSlope; // e.g. 100 for 1:100, 200 for 1:200, 500 for 1:500
  final bool slottedOverflow;
  final bool rainheadOverflow;
  final int downpipeCount;

  const StormwaterComplianceState({
    required this.roofLength,
    required this.roofWidth,
    required this.roofPitch,
    required this.rainfallZone,
    required this.gutterType,
    required this.gutterProfile,
    required this.downpipeStyle,
    required this.boxGutterSlope,
    required this.slottedOverflow,
    required this.rainheadOverflow,
    required this.downpipeCount,
  });

  /// Factory for default compliant initial state.
  factory StormwaterComplianceState.initial() {
    return const StormwaterComplianceState(
      roofLength: 15.0,
      roofWidth: 8.0,
      roofPitch: 22.5,
      rainfallZone: 'Brisbane',
      gutterType: 'Eaves Gutter',
      gutterProfile: 'Quad PVC',
      downpipeStyle: 'Round',
      boxGutterSlope: 200.0,
      slottedOverflow: true,
      rainheadOverflow: false,
      downpipeCount: 2,
    );
  }

  /// Calculates effective roof area in square meters.
  double get effectiveCatchmentArea {
    final slopeRad = roofPitch * math.pi / 180.0;
    return roofLength * roofWidth * (1.0 + 0.5 * math.tan(slopeRad));
  }

  /// Gets rainfall intensity in mm/hr based on selected zone.
  double get rainfallIntensity {
    if (rainfallZone == 'Cairns') return 320.0;
    if (rainfallZone == 'Toowoomba') return 250.0;
    return 280.0; // Brisbane
  }

  /// Calculates total flow rate in L/s.
  double get totalFlowRate {
    return (rainfallIntensity * effectiveCatchmentArea) / 3600.0;
  }

  /// Calculates flow rate per downpipe in L/s.
  double get flowRatePerDownpipe {
    return downpipeCount > 0 ? totalFlowRate / downpipeCount : totalFlowRate;
  }

  /// Calculates downstream downpipe sizer recommended size.
  String get recommendedDownpipeSize {
    final flow = flowRatePerDownpipe;
    if (downpipeStyle == 'Round') {
      if (flow <= 3.5) return 'DN90';
      if (flow <= 5.0) return 'DN100';
      return 'DN150';
    } else {
      if (flow <= 3.0) return '100x50 mm';
      if (flow <= 4.5) return '100x75 mm';
      return '125x125 mm';
    }
  }

  /// Checks if downpipe style capacity is fully compliant.
  bool get isDownpipeCompliant {
    final flow = flowRatePerDownpipe;
    if (downpipeStyle == 'Round') return flow <= 12.0;
    return flow <= 10.0;
  }

  /// Checks if gutter carrying capacity is fully compliant.
  bool get isGutterCapacityCompliant {
    final flow = flowRatePerDownpipe;
    if (gutterType == 'Eaves Gutter') {
      if (gutterProfile == 'Quad PVC') return flow <= 1.5;
      return flow <= 3.2; // Colorbond Slotted
    }
    return boxGutterSlope <= 200.0; // Box gutter is failed if 1:500 slope is chosen
  }

  /// Checks if box gutter slope conforms.
  bool get isBoxGutterSlopeCompliant {
    return gutterType != 'Box Gutter' || boxGutterSlope <= 200.0;
  }

  /// Checks if overflow relief elements are installed.
  bool get isOverflowReliefCompliant {
    if (gutterType == 'Eaves Gutter') return slottedOverflow;
    return rainheadOverflow;
  }

  /// Checks full compliance status.
  bool get isFullyCompliant {
    return isDownpipeCompliant &&
        isGutterCapacityCompliant &&
        isBoxGutterSlopeCompliant &&
        isOverflowReliefCompliant;
  }

  /// Returns recommended premium upgrade suggestion.
  String get upgradeRecommendation {
    if (gutterProfile == 'Quad PVC') {
      return 'Upgrade to Premium Colorbond Slotted Gutter with overflow weirs (reduces blockage overflow risk).';
    }
    return 'Gutter system is premium-optimized with slotted steel channels and heavy duty brackets.';
  }

  /// Returns cheapest option material ledger cost.
  double get cheapestEstimatedCost {
    final runs = roofLength * 2.0;
    return (runs * 18.0) + (downpipeCount * 45.0); // Standard PVC rates
  }

  /// Returns premium option material ledger cost.
  double get premiumEstimatedCost {
    final runs = roofLength * 2.0;
    return (runs * 48.0) + (downpipeCount * 125.0) + 250.0; // Colorbond rates + weirs
  }

  /// Clones stormwater compliance state overrides.
  StormwaterComplianceState copyWith({
    double? roofLength,
    double? roofWidth,
    double? roofPitch,
    String? rainfallZone,
    String? gutterType,
    String? gutterProfile,
    String? downpipeStyle,
    double? boxGutterSlope,
    bool? slottedOverflow,
    bool? rainheadOverflow,
    int? downpipeCount,
  }) {
    return StormwaterComplianceState(
      roofLength: roofLength ?? this.roofLength,
      roofWidth: roofWidth ?? this.roofWidth,
      roofPitch: roofPitch ?? this.roofPitch,
      rainfallZone: rainfallZone ?? this.rainfallZone,
      gutterType: gutterType ?? this.gutterType,
      gutterProfile: gutterProfile ?? this.gutterProfile,
      downpipeStyle: downpipeStyle ?? this.downpipeStyle,
      boxGutterSlope: boxGutterSlope ?? this.boxGutterSlope,
      slottedOverflow: slottedOverflow ?? this.slottedOverflow,
      rainheadOverflow: rainheadOverflow ?? this.rainheadOverflow,
      downpipeCount: downpipeCount ?? this.downpipeCount,
    );
  }
}

/// Riverpod Notifier for Stormwater Compliance State.
class StormwaterComplianceNotifier extends Notifier<StormwaterComplianceState> {
  @override
  StormwaterComplianceState build() {
    return StormwaterComplianceState.initial();
  }

  void updateLength(double len) => state = state.copyWith(roofLength: len);
  void updateWidth(double w) => state = state.copyWith(roofWidth: w);
  void updatePitch(double p) => state = state.copyWith(roofPitch: p);
  void updateZone(String z) => state = state.copyWith(rainfallZone: z);
  void updateGutterType(String gt) => state = state.copyWith(gutterType: gt);
  void updateGutterProfile(String gp) => state = state.copyWith(gutterProfile: gp);
  void updateDownpipeStyle(String ds) => state = state.copyWith(downpipeStyle: ds);
  void updateSlope(double s) => state = state.copyWith(boxGutterSlope: s);
  void updateSlotted(bool val) => state = state.copyWith(slottedOverflow: val);
  void updateRainhead(bool val) => state = state.copyWith(rainheadOverflow: val);
  void updateDownpipeCount(int count) => state = state.copyWith(downpipeCount: count.clamp(1, 10));
  void reset() => state = StormwaterComplianceState.initial();
}

/// Riverpod Provider for Stormwater Sizer.
final stormwaterComplianceProvider = NotifierProvider<StormwaterComplianceNotifier, StormwaterComplianceState>(StormwaterComplianceNotifier.new);

