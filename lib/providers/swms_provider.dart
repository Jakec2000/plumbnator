import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';



/// Riverpod Notifier for SWMS profiles.
class SwmsNotifier extends Notifier<List<SwmsProfile>> {
  @override
  List<SwmsProfile> build() {
    return [
      const SwmsProfile(
        id: 'swms-1',
        taskName: 'Hot Work / Copper Silver-Brazing',
        hazards: [
          'Fire or explosion from flammable atmospheres or materials',
          'Skin burns from contact with hot pipes/torches',
          'Inhalation of toxic metal fumes (silver solder/flux)',
        ],
        controlMeasures: [
          'Clear area within 10m of hot work of all flammables',
          'Ensure working Dry Powder extinguisher is on-hand',
          'Wear compliant leather gloves and shade-5 safety glasses',
          'Use mechanical ventilation or compliant respirator',
        ],
      ),
      const SwmsProfile(
        id: 'swms-2',
        taskName: 'Excavation & Trenching (> 1.5m)',
        hazards: [
          'Trench collapse causing engulfment/suffocation',
          'Striking underground services (electrical, gas, water)',
          'Falls into trenches by workers or equipment',
        ],
        controlMeasures: [
          'Obtain Dial Before You Dig (BYDA) report prior to breaking ground',
          'Install structural shoring, battering or shielding for trenches > 1.5m',
          'Place spoil heap at least 1.0m away from the trench edge',
          'Install visual barricades and secure entry ladders',
        ],
      ),
      const SwmsProfile(
        id: 'swms-3',
        taskName: 'Working at Heights / Roof Plumbing',
        hazards: [
          'Falls from height / roof edge (severe injury or death)',
          'Unsecured or poorly positioned access ladders slipping',
          'Falling tools or roofing materials striking people below',
        ],
        controlMeasures: [
          'Install physical edge protection or compliant scaffolding complying with AS/NZS 1576',
          'Secure and lash ladder at a 4:1 slope, extending 1m above landing step',
          'Wear and attach certified harness to AS/NZS 1891 anchorage point',
          'Establish a clearly barricaded exclusion zone directly below work area',
        ],
      ),
      const SwmsProfile(
        id: 'swms-4',
        taskName: 'Confined Space Entry - Sewers & Main Holes',
        hazards: [
          'Toxic atmospheric contaminants (H2S, CO) or oxygen deficiency',
          'Engulfment or drowning from sudden water or sewerage surge',
          'Difficulty of rescue or evacuation in case of emergency',
        ],
        controlMeasures: [
          'Conduct gas testing using calibrated multi-gas detector prior to entry',
          'Implement continuous mechanical ventilation during occupancy',
          'Station a trained standby person outside with retrieval harness and winch',
          'Establish a formal confined space entry permit system complying with AS 2865',
        ],
      ),
      const SwmsProfile(
        id: 'swms-5',
        taskName: 'High-Pressure Sewer Jetting Operations',
        hazards: [
          'High-pressure water whip causing severe tissue puncture or amputation',
          'Exposure to biohazards or infectious pathogens from aerosolized sewage',
          'Hose recoil or blowback at pipe openings',
        ],
        controlMeasures: [
          'Wear face shields, heavy-duty waterproof gauntlets, and safety boots',
          'Never operate the high-pressure jet pump without hose fully inserted in drain (> 300mm)',
          'Use a foot control valve to enable instantaneous water pressure shut-off',
          'Ensure a secondary operator is stationed nearby to monitor pump telemetry',
        ],
      ),
    ];
  }

  /// Sign off a SWMS profile by plumber's name.
  void signSwms(String id, String plumberName) {
    state = [
      for (final profile in state)
        if (profile.id == id) profile.sign(plumberName) else profile
    ];
  }

  /// Appends a custom bespoke SWMS profile to the state list.
  void addCustomSwms(String taskName, List<String> hazards, List<String> controlMeasures) {
    final newId = 'swms-${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = SwmsProfile(
      id: newId,
      taskName: taskName,
      hazards: hazards,
      controlMeasures: controlMeasures,
    );
    state = [...state, newProfile];
  }
}

/// Provider for WHS SWMS list.
final swmsProvider = NotifierProvider<SwmsNotifier, List<SwmsProfile>>(SwmsNotifier.new);

