import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/compliance_result.dart';
import '../services/database_service.dart';
import '../services/ai_analysis_service.dart';
import '../services/rate_limiter_service.dart';
import '../services/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;


/// Notifier that manages the plumbing jobs state and hooks into DatabaseService.
class JobsNotifier extends Notifier<List<PlumbingJob>> {
  final DatabaseService _db = DatabaseService();

  @override
  List<PlumbingJob> build() {
    final initialList = [
      PlumbingJob(
        id: '1',
        title: 'Hot Water System Replacement',
        clientName: 'Sarah Jenkins',
        address: '142 Boundary St, West End QLD 4101',
        dateCompleted: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Pending Lodgement',
        complianceScore: 0.95,
        issues: const ['Tempering valve tested at 48.5°C (Compliant)'],
      ),
      PlumbingJob(
        id: '2',
        title: 'Underground Drainage Extension',
        clientName: 'Brisbane City Builders',
        address: '89 Albert St, Brisbane City QLD 4000',
        dateCompleted: DateTime.now().subtract(const Duration(days: 12)),
        status: 'Overdue Form 4',
        complianceScore: 0.70,
        issues: const ['Missing as-constructed drainage plan upload', 'DN100 pipe gradient under 1.65%'],
      ),
      PlumbingJob(
        id: '3',
        title: 'Bathroom Renovations (Ensuite)',
        clientName: 'Michael Chang',
        address: '22 Gympie Rd, Chermside QLD 4032',
        dateCompleted: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Draft',
        complianceScore: 0.85,
        issues: const [],
      ),
    ];

    _db.populateSandboxSeed(initialList);
    _db.streamJobs().listen((jobs) {
      state = jobs;
    });

    return _db.isSandboxActive ? initialList : const [];
  }

  /// Adds a new plumbing job to the list and syncs to database.
  Future<void> addJob(PlumbingJob job) async {
    await _db.saveJob(job);
    if (_db.isSandboxActive) {
      state = [...state, job];
    }
  }

  /// Toggles the Form 4 lodgement status of a job and persists in database.
  Future<void> lodgeForm4(String id) async {
    final job = state.firstWhere((j) => j.id == id);
    final updated = job.copyWith(
      status: 'Lodged',
      form4Submitted: true,
      complianceScore: 1.0,
    );
    await _db.saveJob(updated);
    if (_db.isSandboxActive) {
      state = [
        for (final j in state)
          if (j.id == id) updated else j
      ];
    }
  }

  /// Saves and updates a plumbing job in database and state cache.
  Future<void> saveJob(PlumbingJob job) async {
    await _db.saveJob(job);
    if (_db.isSandboxActive) {
      state = [
        for (final j in state)
          if (j.id == job.id) job else j
      ];
    }
  }
}

/// Provider for plumbing jobs state.
final jobsProvider = NotifierProvider<JobsNotifier, List<PlumbingJob>>(JobsNotifier.new);

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

/// State model for AI Vision analysis tracking.
class AiAnalysisState {
  final bool isLoading;
  final String? error;
  final ComplianceResult? result;
  final bool canAnalyze;
  final int dailyRemaining;

  const AiAnalysisState({
    required this.isLoading,
    this.error,
    this.result,
    required this.canAnalyze,
    required this.dailyRemaining,
  });

  factory AiAnalysisState.initial() {
    return const AiAnalysisState(
      isLoading: false,
      canAnalyze: true,
      dailyRemaining: 5,
    );
  }

  AiAnalysisState copyWith({
    bool? isLoading,
    String? error,
    ComplianceResult? result,
    bool? canAnalyze,
    int? dailyRemaining,
  }) {
    return AiAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow nullifying error
      result: result ?? this.result,
      canAnalyze: canAnalyze ?? this.canAnalyze,
      dailyRemaining: dailyRemaining ?? this.dailyRemaining,
    );
  }
}

class AiAnalysisNotifier extends Notifier<AiAnalysisState> {
  final AiAnalysisService _aiService = AiAnalysisService();

  @override
  AiAnalysisState build() {
    // Asynchronously load initial rate limit state
    _refreshRateLimit();
    return AiAnalysisState.initial();
  }

  Future<void> _refreshRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final isGold = prefs.getBool('is_gold_member') ?? false;
    if (isGold) {
      state = state.copyWith(
        canAnalyze: true,
        dailyRemaining: 99999,
      );
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString('rate_limiter_date');
    final count = prefs.getInt('rate_limiter_count') ?? 0;
    
    final currentCount = storedDate == today ? count : 0;
    final remaining = (5 - currentCount).clamp(0, 5);
    
    state = state.copyWith(
      canAnalyze: remaining > 0,
      dailyRemaining: remaining,
    );
  }

  /// Upgrades the user account to the Plumbnator Gold tier, unlocking unlimited analyses.
  Future<void> upgradeToGold() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_gold_member', true);
    await _refreshRateLimit();
  }

  Future<void> runAnalysis(List<int> imageBytes, {bool persist = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _aiService.analyzePlumbingInstallation(
        imageBytes: imageBytes,
        persist: persist,
      );
      await _refreshRateLimit();
      state = state.copyWith(isLoading: false, result: res);
    } on RateLimitExceededException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Analysis failed. Fallback active.');
    }
  }

  void reset() {
    state = state.copyWith(result: null, error: null);
    _refreshRateLimit();
  }

  Future<void> flagResultManually() async {
    if (state.result != null) {
      final updated = state.result!.copyWith(isManualFlag: true);
      // Persist the flagged status to firestore if needed
      await _aiService.saveResultToFirestore(updated);
      state = state.copyWith(result: updated);
    }
  }
}

final aiAnalysisProvider = NotifierProvider<AiAnalysisNotifier, AiAnalysisState>(AiAnalysisNotifier.new);

/// Riverpod Notifier for the global navigation index.
class NavNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);

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

/// Represents a message in the AI standards assistant chat history.
class AssistantMessage {
  /// The text content of the message.
  final String text;

  /// Whether the message is sent by the user (true) or the AI assistant (false).
  final bool isUser;

  /// The timestamp of the message.
  final DateTime timestamp;

  /// Creates a new [AssistantMessage] instance.
  const AssistantMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// The Riverpod state for the AI standards Q&A assistant.
class AssistantState {
  /// The list of conversation messages.
  final List<AssistantMessage> messages;

  /// Whether the assistant is currently loading a response.
  final bool isLoading;

  /// Optional error message.
  final String? error;

  /// The currently selected AI model engine.
  final String selectedModel;

  /// Creates an [AssistantState] instance.
  const AssistantState({
    required this.messages,
    required this.isLoading,
    required this.selectedModel,
    this.error,
  });

  /// Factory for the initial state of the assistant.
  factory AssistantState.initial() {
    return AssistantState(
      messages: [
        AssistantMessage(
          text: 'Hello! I am the Plumbnator compliance assistant. Ask me anything about AS/NZS 3500 plumbing standards or Queensland QBCC notifiable work regulations.',
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
      isLoading: false,
      selectedModel: 'Grok 4.3',
    );
  }

  /// Creates a copy of the state with overridden values.
  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
    String? error,
    String? selectedModel,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      selectedModel: selectedModel ?? this.selectedModel,
      error: error,
    );
  }
}

/// Riverpod Notifier managing Q&A assistant chat sessions.
class AssistantNotifier extends Notifier<AssistantState> {
  final GeminiService _geminiService = GeminiService();

  @override
  AssistantState build() {
    return AssistantState.initial();
  }

  /// Changes the active AI model engine.
  void selectModel(String model) {
    state = state.copyWith(selectedModel: model);
  }

  /// Sends a question to the AI standards model and records the response.
  Future<void> sendQuestion(String question) async {
    if (question.trim().isEmpty) return;

    final userMsg = AssistantMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final answer = await _geminiService.askStandardsQuestion(
        question,
        model: state.selectedModel,
      );
      final aiMsg = AssistantMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to receive a response from AI. Please try again.',
      );
    }
  }

  /// Clears the conversation history back to the initial message.
  void clearHistory() {
    state = AssistantState.initial().copyWith(selectedModel: state.selectedModel);
  }
}

/// Provider for the AI standards assistant state.
final assistantProvider = NotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);

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





