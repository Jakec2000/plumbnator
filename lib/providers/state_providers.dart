import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/compliance_result.dart';
import '../services/database_service.dart';
import '../services/ai_analysis_service.dart';
import '../services/rate_limiter_service.dart';
import '../services/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Creates an [AssistantState] instance.
  const AssistantState({
    required this.messages,
    required this.isLoading,
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
    );
  }

  /// Creates a copy of the state with overridden values.
  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
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
      final answer = await _geminiService.askStandardsQuestion(question);
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
    state = AssistantState.initial();
  }
}

/// Provider for the AI standards assistant state.
final assistantProvider = NotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);



