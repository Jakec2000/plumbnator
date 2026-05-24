import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/services/standards_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock the asset bundle load for the test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final String jsonStr = jsonEncode({
        "plumbing_codes/dummy.pdf": {
          "title": "Dummy AS/NZS 3500",
          "chunks": [
            "Hot water tanks must be tempered to 50 degrees maximum.",
            "Water pipes must have proper lagging.",
            "Drainage systems require 1:60 gradient minimum."
          ]
        }
      });
      return ByteData.sublistView(utf8.encode(jsonStr));
    });
  });

  test('StandardsSearchService should load and return correct results for keywords', () async {
    final service = StandardsSearchService();
    await service.loadStandards();

    // Search with a specific keyword
    final result1 = service.searchStandards(['tempered']);
    expect(result1, contains('Source: Dummy AS/NZS 3500'));
    expect(result1, contains('Hot water tanks must be tempered to 50 degrees maximum.'));
    expect(result1, isNot(contains('proper lagging')));

    // Search with multiple keywords
    final result2 = service.searchStandards(['drainage', 'gradient']);
    expect(result2, contains('Drainage systems require 1:60 gradient minimum.'));

    // Search with non-existent keyword
    final result3 = service.searchStandards(['xyz123']);
    expect(result3, contains('No specific clauses found'));
  });
}
