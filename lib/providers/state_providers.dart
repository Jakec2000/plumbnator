import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/database_service.dart';

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
}

/// Provider for plumbing jobs state.
final jobsProvider = NotifierProvider<JobsNotifier, List<PlumbingJob>>(JobsNotifier.new);

/// State structure for the Hydraulic Sizing Calculator.
class SizingState {
  final Map<String, int> fixtureCounts;
  final double runLength; // Trench length in meters
  final double gradePercentage; // E.g., 1.65% or 2.50%

  const SizingState({
    required this.fixtureCounts,
    required this.runLength,
    required this.gradePercentage,
  });

  /// Factory for default calculator state.
  factory SizingState.initial() {
    return const SizingState(
      fixtureCounts: {
        'Water Closet (WC)': 0,
        'Basin': 0,
        'Shower': 0,
        'Kitchen Sink': 0,
        'Washing Machine': 0,
      },
      runLength: 15.0,
      gradePercentage: 1.65,
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

  /// Creates a copy of SizingState with optional overrides.
  SizingState copyWith({
    Map<String, int>? fixtureCounts,
    double? runLength,
    double? gradePercentage,
  }) {
    return SizingState(
      fixtureCounts: fixtureCounts ?? this.fixtureCounts,
      runLength: runLength ?? this.runLength,
      gradePercentage: gradePercentage ?? this.gradePercentage,
    );
  }
}

/// Riverpod Notifier for the Sizing Calculator state.
class SizingNotifier extends Notifier<SizingState> {
  @override
  SizingState build() {
    return SizingState.initial();
  }

  /// Updates a fixture count.
  void updateFixtureCount(String fixture, int count) {
    final counts = Map<String, int>.from(state.fixtureCounts);
    counts[fixture] = count.clamp(0, 50);
    state = state.copyWith(fixtureCounts: counts);
  }

  /// Updates the run length.
  void updateRunLength(double length) {
    state = state.copyWith(runLength: length.clamp(1.0, 500.0));
  }

  /// Updates the grade percentage.
  void updateGradePercentage(double grade) {
    state = state.copyWith(gradePercentage: grade.clamp(0.5, 10.0));
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
    ];
  }

  /// Sign off a SWMS profile by plumber's name.
  void signSwms(String id, String plumberName) {
    state = [
      for (final profile in state)
        if (profile.id == id) profile.sign(plumberName) else profile
    ];
  }
}

/// Provider for WHS SWMS list.
final swmsProvider = NotifierProvider<SwmsNotifier, List<SwmsProfile>>(SwmsNotifier.new);
