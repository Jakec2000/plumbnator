import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/models/models.dart';
import 'package:plumbnator/services/database_service.dart';

void main() {
  group('Plumbnator QLD: DatabaseService Integration & Offline Sync Testing', () {
    test('Initializes in offline sandbox mode when Firebase apps list is empty', () {
      final service = DatabaseService();
      expect(service.isSandboxActive, isTrue);
    });

    test('Streams initial seed records successfully and allows saving updates', () async {
      final service = DatabaseService();
      final seed = [
        PlumbingJob(
          id: 'test-1',
          title: 'Drainage Test',
          clientName: 'Sarah QLD',
          address: '45 Creek Rd',
          dateCompleted: DateTime.now(),
          status: 'Draft',
          complianceScore: 0.90,
          issues: const [],
        ),
      ];

      service.populateSandboxSeed(seed);
      final list = await service.streamJobs().first;
      expect(list.length, equals(1));
      expect(list[0].id, equals('test-1'));

      final updated = list[0].copyWith(status: 'Lodged', form4Submitted: true);
      await service.saveJob(updated);

      final newList = await service.streamJobs().first;
      expect(newList[0].status, equals('Lodged'));
      expect(newList[0].form4Submitted, isTrue);
    });
  });
}
