import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/models.dart';

/// Managed database service handling Cloud Firestore queries and sandbox memory fallbacks.
class DatabaseService {
  final List<PlumbingJob> _sandboxJobs = [];
  bool _useSandbox = true;

  /// Initializes Firestore settings and configures offline cache rules.
  DatabaseService() {
    _initializeDatabase();
  }

  /// Sets up offline caching on initial load.
  void _initializeDatabase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        _useSandbox = false;
      }
    } catch (e) {
      _useSandbox = true;
    }
  }

  /// Returns whether the database service is currently in local sandbox mode.
  bool get isSandboxActive => _useSandbox;

  /// Streams a real-time list of jobs from Firestore or local sandbox.
  Stream<List<PlumbingJob>> streamJobs() {
    if (_useSandbox) {
      return Stream.value(List<PlumbingJob>.from(_sandboxJobs));
    }

    return FirebaseFirestore.instance.collection('jobs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PlumbingJob(
          id: doc.id,
          title: data['title'] as String? ?? 'Untitled Job',
          clientName: data['clientName'] as String? ?? 'Generic Client',
          address: data['address'] as String? ?? '',
          dateCompleted: (data['dateCompleted'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['status'] as String? ?? 'Draft',
          complianceScore: (data['complianceScore'] as num?)?.toDouble() ?? 1.0,
          issues: List<String>.from(data['issues'] as List? ?? []),
          form4Submitted: data['form4Submitted'] as bool? ?? false,
        );
      }).toList();
    });
  }

  /// Saves a job either to Cloud Firestore or the local sandbox.
  Future<void> saveJob(PlumbingJob job) async {
    if (_useSandbox) {
      _sandboxJobs.removeWhere((j) => j.id == job.id);
      _sandboxJobs.add(job);
      return;
    }

    await FirebaseFirestore.instance.collection('jobs').doc(job.id).set({
      'title': job.title,
      'clientName': job.clientName,
      'address': job.address,
      'dateCompleted': Timestamp.fromDate(job.dateCompleted),
      'status': job.status,
      'complianceScore': job.complianceScore,
      'issues': job.issues,
      'form4Submitted': job.form4Submitted,
    });
  }

  /// populates the initial standard sandbox jobs.
  void populateSandboxSeed(List<PlumbingJob> seeds) {
    if (_sandboxJobs.isEmpty) {
      _sandboxJobs.addAll(seeds);
    }
  }
}
