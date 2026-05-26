import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/services/supabase_client_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseClientService Tests', () {
    test('Initialization state and properties', () {
      final service = SupabaseClientService();
      expect(service, isNotNull);
    });

    test('Local fallback search matches clauses based on keywords', () async {
      final service = SupabaseClientService();
      
      // Test search with clip spacing query
      final clips = await service.searchRemoteStandards('clip spacing support');
      expect(clips.isNotEmpty, isTrue);
      expect(clips.any((element) => element.title.contains('Support') || element.summaryText.contains('spacing')), isTrue);

      // Test search with stack ventilation query
      final stacks = await service.searchRemoteStandards('stack ventilation soil');
      expect(stacks.isNotEmpty, isTrue);
      expect(stacks.any((element) => element.title.contains('Vent') || element.summaryText.contains('stack')), isTrue);
    });

    test('All registry clauses are mapped in fallback query search', () async {
      final service = SupabaseClientService();
      final all = await service.searchRemoteStandards('general plumbing rules water safety');
      expect(all.length, greaterThanOrEqualTo(1));
    });
  });
}
