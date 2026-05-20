import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plumbnator/models/models.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: As-Constructed Sanitary Drainage Sketcher Tests', () {
    test('PlumbingJob supports copying with drainageSketchBase64', () {
      final job = PlumbingJob(
        id: 'job-99',
        title: 'Sewer Line Overhaul',
        clientName: 'Commercial Depot',
        address: '50 Eagle St, Brisbane',
        dateCompleted: DateTime.now(),
        status: 'Draft',
        complianceScore: 0.95,
        issues: const [],
      );

      expect(job.drainageSketchBase64, isNull);

      final updatedJob = job.copyWith(
        drainageSketchBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      expect(updatedJob.drainageSketchBase64, isNotNull);
      expect(
        updatedJob.drainageSketchBase64,
        equals('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='),
      );
    });

    test('Riverpod jobsProvider retains and updates drainage sketch states', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Flush microtasks so streamJobs listen completes
      await Future.delayed(Duration.zero);

      // Verify original jobs loaded
      final initialJobs = container.read(jobsProvider);
      expect(initialJobs.isNotEmpty, isTrue);

      final targetJob = initialJobs.first;
      expect(targetJob.drainageSketchBase64, isNull);

      // Save a simulated canvas sketch
      const mockSketch = 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
      final updated = targetJob.copyWith(drainageSketchBase64: mockSketch);

      await container.read(jobsProvider.notifier).saveJob(updated);

      final currentJobs = container.read(jobsProvider);
      final savedJob = currentJobs.firstWhere((j) => j.id == targetJob.id);
      expect(savedJob.drainageSketchBase64, equals(mockSketch));
    });
  });
}
