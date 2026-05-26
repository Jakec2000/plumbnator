import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;



/// State structure for Gas Fitting Pipe Sizer & Ventilation Auditor (AS/NZS 5601.1).
class GasComplianceState {
  final String gasType; // 'Natural Gas', 'LPG'
  final String pipeMaterial; // 'Copper', 'PEX-AL-PEX'
  final double totalLoad; // MJ/h
  final double pipeLength; // meters
  final String pipeDiameter; // 'DN15', 'DN20', 'DN25', 'DN32', 'DN40'
  final double roomVolume; // m^3
  final double ventFreeArea; // mm^2
  final bool ventsProperlyPositioned;
  final bool hasSolenoidShutoff;
  final bool regulatorInstalled;

  const GasComplianceState({
    required this.gasType,
    required this.pipeMaterial,
    required this.totalLoad,
    required this.pipeLength,
    required this.pipeDiameter,
    required this.roomVolume,
    required this.ventFreeArea,
    required this.ventsProperlyPositioned,
    required this.hasSolenoidShutoff,
    required this.regulatorInstalled,
  });

  /// Factory for default compliant initial state.
  factory GasComplianceState.initial() {
    return const GasComplianceState(
      gasType: 'Natural Gas',
      pipeMaterial: 'Copper',
      totalLoad: 80.0,
      pipeLength: 15.0,
      pipeDiameter: 'DN20',
      roomVolume: 12.0,
      ventFreeArea: 25000.0,
      ventsProperlyPositioned: true,
      hasSolenoidShutoff: false,
      regulatorInstalled: true,
    );
  }

  /// Calculates inner diameter in mm based on material and outer diameter size label.
  double get innerDiameter {
    if (pipeMaterial == 'Copper') {
      switch (pipeDiameter) {
        case 'DN15': return 13.0;
        case 'DN25': return 23.5;
        case 'DN32': return 29.0;
        case 'DN40': return 38.0;
        default: return 18.0; // DN20
      }
    } else {
      // PEX-AL-PEX
      switch (pipeDiameter) {
        case 'DN15': return 11.5;
        case 'DN25': return 20.0;
        case 'DN32': return 26.0;
        case 'DN40': return 32.0;
        default: return 16.0; // DN20
      }
    }
  }

  /// Converts MJ/h to volumetric flow rate m^3/h.
  double get gasFlowRate {
    final divisor = gasType == 'Natural Gas' ? 38.0 : 95.0;
    return totalLoad / divisor;
  }

  /// Estimates pressure drop in kPa across pipeline run using Colebrook/Pole empirical curve.
  double get calculatedPressureDrop {
    final flow = gasFlowRate;
    final d = innerDiameter;
    final density = gasType == 'Natural Gas' ? 0.6 : 1.5;
    if (flow == 0.0 || d == 0.0) return 0.0;
    final drop = (math.pow(flow, 1.8) * pipeLength * density * 8200.0) / math.pow(d, 4.8);
    return drop.clamp(0.001, 5.0);
  }

  /// Gets maximum allowed statutory pressure drop in kPa.
  double get maxAllowedPressureDrop {
    return gasType == 'Natural Gas' ? 0.075 : 0.25;
  }

  /// Validates if the pipe pressure drop is within safety parameters.
  bool get isPressureDropCompliant {
    return calculatedPressureDrop <= maxAllowedPressureDrop;
  }

  /// Identifies if the target room counts as a confined space (Clause 6.4).
  bool get isConfinedSpace {
    return roomVolume < (0.07 * totalLoad);
  }

  /// Calculates required free ventilation aperture area in mm^2 (AS/NZS 5601.1 Table 6.3).
  double get requiredVentilationArea {
    if (!isConfinedSpace) return 0.0;
    return totalLoad * 300.0; // 300 mm^2 per MJ/h for direct outside vents
  }

  /// Validates room ventilation.
  bool get isVentilationCompliant {
    if (!isConfinedSpace) return true;
    return ventFreeArea >= requiredVentilationArea && ventsProperlyPositioned;
  }

  /// Validates regulator presence.
  bool get isRegulatorCompliant => regulatorInstalled;

  /// Checks full compliance status.
  bool get isFullyCompliant {
    return isPressureDropCompliant && isVentilationCompliant && isRegulatorCompliant;
  }

  /// Returns recommended premium upgrade suggestion.
  String get upgradeRecommendation {
    if (pipeMaterial == 'Copper') {
      return 'Upgrade to jacketed Multilayer PEX-AL-PEX pipe with automatic solenoid gas leak shutoff safety valves.';
    }
    return 'System is high fidelity with flexible safety solenoids and smart piping.';
  }

  /// Returns cheapest option material ledger cost.
  double get cheapestEstimatedCost {
    return (pipeLength * 25.0) + 120.0; // Standard Copper DN20 runs + standard fittings
  }

  /// Returns premium option material ledger cost.
  double get premiumEstimatedCost {
    return (pipeLength * 55.0) + 550.0; // PEX-AL-PEX + Solenoid shutdown package
  }

  /// Clones gas compliance state overrides.
  GasComplianceState copyWith({
    String? gasType,
    String? pipeMaterial,
    double? totalLoad,
    double? pipeLength,
    String? pipeDiameter,
    double? roomVolume,
    double? ventFreeArea,
    bool? ventsProperlyPositioned,
    bool? hasSolenoidShutoff,
    bool? regulatorInstalled,
  }) {
    return GasComplianceState(
      gasType: gasType ?? this.gasType,
      pipeMaterial: pipeMaterial ?? this.pipeMaterial,
      totalLoad: totalLoad ?? this.totalLoad,
      pipeLength: pipeLength ?? this.pipeLength,
      pipeDiameter: pipeDiameter ?? this.pipeDiameter,
      roomVolume: roomVolume ?? this.roomVolume,
      ventFreeArea: ventFreeArea ?? this.ventFreeArea,
      ventsProperlyPositioned: ventsProperlyPositioned ?? this.ventsProperlyPositioned,
      hasSolenoidShutoff: hasSolenoidShutoff ?? this.hasSolenoidShutoff,
      regulatorInstalled: regulatorInstalled ?? this.regulatorInstalled,
    );
  }
}

/// Riverpod Notifier for Gas Compliance State.
class GasComplianceNotifier extends Notifier<GasComplianceState> {
  @override
  GasComplianceState build() {
    return GasComplianceState.initial();
  }

  void updateGasType(String type) => state = state.copyWith(gasType: type);
  void updateMaterial(String mat) => state = state.copyWith(pipeMaterial: mat);
  void updateLoad(double load) => state = state.copyWith(totalLoad: load);
  void updateLength(double len) => state = state.copyWith(pipeLength: len);
  void updateDiameter(String dia) => state = state.copyWith(pipeDiameter: dia);
  void updateVolume(double vol) => state = state.copyWith(roomVolume: vol);
  void updateVentArea(double area) => state = state.copyWith(ventFreeArea: area);
  void updateVentPositioned(bool val) => state = state.copyWith(ventsProperlyPositioned: val);
  void updateSolenoid(bool val) => state = state.copyWith(hasSolenoidShutoff: val);
  void updateRegulator(bool val) => state = state.copyWith(regulatorInstalled: val);
  void reset() => state = GasComplianceState.initial();
}

/// Riverpod Provider for Gas Sizer.
final gasComplianceProvider = NotifierProvider<GasComplianceNotifier, GasComplianceState>(GasComplianceNotifier.new);

