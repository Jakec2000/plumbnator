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

