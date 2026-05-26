import 'package:flutter_riverpod/flutter_riverpod.dart';



/// State structure for the Solar & Heat Pump Compliance Sizer.
class SolarComplianceState {
  final String zone; // 'Zone 1' (Tropical), 'Zone 2' (Brisbane), 'Zone 3' (Darling Downs)
  final String techType; // 'Solar Flat Plate', 'Solar Evacuated Tubes', 'Heat Pump'
  final int bedrooms; // 1 to 5 (5 means 5+)
  final int occupants; // 1 to 10
  final double dailyDemand; // L/day
  final double collectorTilt; // degrees
  final String orientation; // 'North', 'East', 'West', 'South'
  final double setpointTemp; // °C
  final int ptrRatingKpa; // kPa (e.g. 850)
  final int ecvRatingKpa; // kPa (e.g. 700)
  final int plvSettingKpa; // kPa (e.g. 500)
  final double shadingFactor; // % (0 to 80)
  final bool heatTrapInstalled; // AS/NZS 3500.4 Cl 8.2.2
  final bool hasFrostProtection; // AS/NZS 3500.4 Cl 8.5
  final double boundaryDistance; // meters (QLD EPA Noise limits)
  final bool isInternal; // Cylinder location
  final bool safeTrayInstalled; // AS/NZS 3500.4 Cl 4.6
  final bool reliefIsCopper; // AS/NZS 3500.4 Cl 5.12
  final bool duoValveInstalled; // AS/NZS 3500.4 Cl 5.2
  final String facilityType; // 'Standard' (50°C), 'Special' (45°C TMV limits)

  const SolarComplianceState({
    required this.zone,
    required this.techType,
    required this.bedrooms,
    required this.occupants,
    required this.dailyDemand,
    required this.collectorTilt,
    required this.orientation,
    required this.setpointTemp,
    required this.ptrRatingKpa,
    required this.ecvRatingKpa,
    required this.plvSettingKpa,
    required this.shadingFactor,
    required this.heatTrapInstalled,
    required this.hasFrostProtection,
    required this.boundaryDistance,
    required this.isInternal,
    required this.safeTrayInstalled,
    required this.reliefIsCopper,
    required this.duoValveInstalled,
    required this.facilityType,
  });

  /// Factory for default compliant initial state.
  factory SolarComplianceState.initial() {
    return const SolarComplianceState(
      zone: 'Zone 2',
      techType: 'Solar Flat Plate',
      bedrooms: 3,
      occupants: 4,
      dailyDemand: 250.0,
      collectorTilt: 30.0,
      orientation: 'North',
      setpointTemp: 60.0,
      ptrRatingKpa: 850,
      ecvRatingKpa: 700,
      plvSettingKpa: 500,
      shadingFactor: 0.0,
      heatTrapInstalled: true,
      hasFrostProtection: false,
      boundaryDistance: 5.0,
      isInternal: false,
      safeTrayInstalled: false,
      reliefIsCopper: true,
      duoValveInstalled: true,
      facilityType: 'Standard',
    );
  }

  /// Calculates demand volume from bedroom limits.
  double get calculatedDemandFromBedrooms {
    if (bedrooms <= 2) return 150.0;
    if (bedrooms <= 4) return 250.0;
    return 350.0;
  }

  /// Calculates demand volume from occupants count.
  double get calculatedDemandFromOccupants => occupants * 75.0;

  /// Legionella control compliance under AS/NZS 3500.4 Cl 4.2.
  bool get isLegionellaCompliant => setpointTemp >= 60.0;

  /// Mains pressure limit check under AS/NZS 3500.4/1 Cl 5.4.
  bool get isPlvCompliant => plvSettingKpa <= 500;

  /// ECV delta gap coordination (ECV rating >= PLV + 100 kPa).
  bool get isEcvCompliant => ecvRatingKpa >= (plvSettingKpa + 100);

  /// PTR delta gap coordination (PTR rating >= ECV + 150 kPa).
  bool get isPtrCompliant => ptrRatingKpa >= (ecvRatingKpa + 150);

  /// Checks full valve chain clearance compliance.
  bool get isValveChainCompliant => isPlvCompliant && isEcvCompliant && isPtrCompliant;

  /// Suggests the insulation R-value required for external piping.
  double get requiredInsulationRValue => zone == 'Zone 3' ? 0.6 : 0.3;

  /// Gives structural recommendations for pipe insulation wrapper under Section 8.
  String get insulationRecommendation => zone == 'Zone 3'
      ? 'Min 25mm closed-cell rubber sleeve (R0.6 required due to frost)'
      : 'Min 13mm closed-cell polyolefin sleeve (R0.3 compliant)';

  /// Frost freeze compliance under AS/NZS 3500.4 Cl 8.5.
  bool get isFrostCompliant => zone != 'Zone 3' || hasFrostProtection;

  /// Heat trap thermosiphon compliance under Cl 8.2.2.
  bool get isHeatTrapCompliant => heatTrapInstalled;

  /// Safe tray overflow drainage compliance under Cl 4.6.
  bool get isSafeTrayCompliant => !isInternal || safeTrayInstalled;

  /// Relief line metallic copper material check under Cl 5.12.
  bool get isReliefLineCompliant => reliefIsCopper;

  /// Combined inlet Duo valve check under Cl 5.2.
  bool get isDuoValveCompliant => duoValveInstalled;

  /// QLD Environmental Protection Regulation acoustic compliance.
  bool get isAcousticCompliant => techType != 'Heat Pump' || boundaryDistance >= 3.0;

  /// Cyclone Region C/D mount framing required under AS/NZS 1170.2.
  bool get requiresCycloneMounting => zone == 'Zone 1' && techType != 'Heat Pump';

  /// QLD WHS safety harness compliance rules on high pitch.
  bool get requiresWhsRoofHarness => collectorTilt > 30.0 && techType != 'Heat Pump';

  /// Maximum tempered hot water delivery limit under PCA B2.
  int get maxTargetDeliveryTemp => facilityType == 'Special' ? 45 : 50;

  /// Aggregate sizer compliance flag.
  bool get isFullyCompliant =>
      isLegionellaCompliant &&
      isValveChainCompliant &&
      isFrostCompliant &&
      isHeatTrapCompliant &&
      isSafeTrayCompliant &&
      isReliefLineCompliant &&
      isDuoValveCompliant &&
      isAcousticCompliant;

  /// Estimates the Coefficient of Performance based on QLD climate zone ambient averages.
  double get estimatedCop {
    if (techType != 'Heat Pump') return 0.0;
    if (zone == 'Zone 1') return 4.5;
    if (zone == 'Zone 2') return 4.0;
    return 3.2; // Zone 3 (Darling Downs) lower average
  }

  /// Calculates collector orientation efficiency penalty scale.
  double get orientationFactor {
    switch (orientation) {
      case 'North':
        return 1.0;
      case 'East':
      case 'West':
        return techType == 'Solar Evacuated Tubes' ? 0.85 : 0.80;
      default:
        return techType == 'Solar Evacuated Tubes' ? 0.45 : 0.40;
    }
  }

  /// Computes annual electricity reduction in kilowatt hours (kWh).
  double get annualEnergySavingsKwh {
    final demandFactor = dailyDemand / 250.0;
    final baseEnergy = 3600.0 * demandFactor;
    if (techType == 'Heat Pump') {
      final cop = estimatedCop;
      return cop > 0 ? baseEnergy - (baseEnergy / cop) : 0.0;
    }
    final eff = techType == 'Solar Evacuated Tubes' ? 0.75 : 0.65;
    return baseEnergy * eff * orientationFactor * (1.0 - shadingFactor / 100.0);
  }

  /// Annual financial yield savings ($ AUD) at 33c per kWh average tariff.
  double get annualSavingsAud => annualEnergySavingsKwh * 0.33;

  /// Estimated reduction in greenhouse emissions (kg CO2) at QLD grid factor of 0.85.
  double get annualCarbonReductionKg => annualEnergySavingsKwh * 0.85;

  /// Computes the Small-scale Technology Certificates (STCs) rebate asset count.
  double get calculatedStcs {
    final baseStcs = zone == 'Zone 1' ? 28.0 : zone == 'Zone 2' ? 26.0 : 24.0;
    final demandFactor = dailyDemand / 250.0;
    final stcs = baseStcs * demandFactor * orientationFactor * (1.0 - shadingFactor / 100.0);
    return stcs.clamp(0.0, 60.0);
  }

  /// Calculated rebate in AUD ($38 per certificate).
  double get estimatedStcRebate => calculatedStcs * 38.0;

  /// Returns optimized daily auxiliary boost cycle suggestion advice.
  String get recommendedBoostSchedule {
    if (techType == 'Heat Pump') {
      return 'Run compressor 10:00 AM - 3:00 PM to capture highest ambient temperature for maximum COP efficiency.';
    }
    return 'Schedule electric element to boost 1:00 PM - 2:00 PM (maximizes peak solar thermal absorption) or 5:00 AM - 6:00 AM for early trade shifts.';
  }

  /// Clones compliance sizer state overrides.
  SolarComplianceState copyWith({
    String? zone,
    String? techType,
    int? bedrooms,
    int? occupants,
    double? dailyDemand,
    double? collectorTilt,
    String? orientation,
    double? setpointTemp,
    int? ptrRatingKpa,
    int? ecvRatingKpa,
    int? plvSettingKpa,
    double? shadingFactor,
    bool? heatTrapInstalled,
    bool? hasFrostProtection,
    double? boundaryDistance,
    bool? isInternal,
    bool? safeTrayInstalled,
    bool? reliefIsCopper,
    bool? duoValveInstalled,
    String? facilityType,
  }) {
    return SolarComplianceState(
      zone: zone ?? this.zone,
      techType: techType ?? this.techType,
      bedrooms: bedrooms ?? this.bedrooms,
      occupants: occupants ?? this.occupants,
      dailyDemand: dailyDemand ?? this.dailyDemand,
      collectorTilt: collectorTilt ?? this.collectorTilt,
      orientation: orientation ?? this.orientation,
      setpointTemp: setpointTemp ?? this.setpointTemp,
      ptrRatingKpa: ptrRatingKpa ?? this.ptrRatingKpa,
      ecvRatingKpa: ecvRatingKpa ?? this.ecvRatingKpa,
      plvSettingKpa: plvSettingKpa ?? this.plvSettingKpa,
      shadingFactor: shadingFactor ?? this.shadingFactor,
      heatTrapInstalled: heatTrapInstalled ?? this.heatTrapInstalled,
      hasFrostProtection: hasFrostProtection ?? this.hasFrostProtection,
      boundaryDistance: boundaryDistance ?? this.boundaryDistance,
      isInternal: isInternal ?? this.isInternal,
      safeTrayInstalled: safeTrayInstalled ?? this.safeTrayInstalled,
      reliefIsCopper: reliefIsCopper ?? this.reliefIsCopper,
      duoValveInstalled: duoValveInstalled ?? this.duoValveInstalled,
      facilityType: facilityType ?? this.facilityType,
    );
  }
}

/// Riverpod notifier managing compliance sizer telemetry and operations.
class SolarComplianceNotifier extends Notifier<SolarComplianceState> {
  @override
  SolarComplianceState build() {
    return SolarComplianceState.initial();
  }

  void updateZone(String zone) => state = state.copyWith(zone: zone);
  void updateTech(String tech) => state = state.copyWith(techType: tech);
  void updateBedrooms(int beds) => state = state.copyWith(bedrooms: beds);
  void updateOccupants(int occs) => state = state.copyWith(occupants: occs);
  void updateDemand(double demand) => state = state.copyWith(dailyDemand: demand);
  void updateTilt(double tilt) => state = state.copyWith(collectorTilt: tilt);
  void updateOrientation(String orientation) => state = state.copyWith(orientation: orientation);
  void updateSetpoint(double setpoint) => state = state.copyWith(setpointTemp: setpoint);
  void updatePtr(int ptr) => state = state.copyWith(ptrRatingKpa: ptr);
  void updateEcv(int ecv) => state = state.copyWith(ecvRatingKpa: ecv);
  void updatePlv(int plv) => state = state.copyWith(plvSettingKpa: plv);
  void updateShading(double shading) => state = state.copyWith(shadingFactor: shading);
  void updateHeatTrap(bool val) => state = state.copyWith(heatTrapInstalled: val);
  void updateFrost(bool val) => state = state.copyWith(hasFrostProtection: val);
  void updateBoundary(double boundary) => state = state.copyWith(boundaryDistance: boundary);
  void updateInternal(bool val) => state = state.copyWith(isInternal: val);
  void updateSafeTray(bool val) => state = state.copyWith(safeTrayInstalled: val);
  void updateReliefCopper(bool val) => state = state.copyWith(reliefIsCopper: val);
  void updateDuoValve(bool val) => state = state.copyWith(duoValveInstalled: val);
  void updateFacility(String facility) => state = state.copyWith(facilityType: facility);

  /// Synchronizes volume demand using standard occupants coefficients.
  void setDemandFromOccupants() {
    state = state.copyWith(dailyDemand: state.calculatedDemandFromOccupants);
  }

  /// Synchronizes volume demand using standard bedroom guidelines.
  void setDemandFromBedrooms() {
    state = state.copyWith(dailyDemand: state.calculatedDemandFromBedrooms);
  }

  /// Resets sizer inputs to defaults.
  void reset() => state = SolarComplianceState.initial();
}

/// Provider for Solar & Heat Pump Compliance state.
final solarComplianceProvider = NotifierProvider<SolarComplianceNotifier, SolarComplianceState>(SolarComplianceNotifier.new);

