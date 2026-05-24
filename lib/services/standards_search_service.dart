import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StandardsSearchService {
  static final StandardsSearchService _instance = StandardsSearchService._internal();
  factory StandardsSearchService() => _instance;
  StandardsSearchService._internal();

  Map<String, dynamic>? _standardsData;

  /// Loads the parsed standards JSON file.
  /// Uses compute to decode the large JSON file in a background isolate to prevent UI jank.
  Future<void> loadStandards() async {
    if (_standardsData != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/standards/parsed_standards.json');
      // Compute parses the JSON in a separate isolate
      _standardsData = await compute(_parseJson, jsonString);
    } catch (e) {
      debugPrint('Error loading plumbing standards: $e');
    }
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Searches the loaded standards for the given keywords.
  /// Returns a concatenated string of the most relevant chunks.
  String searchStandards(List<String> keywords) {
    if (_standardsData == null || keywords.isEmpty) {
      return 'No specific regulatory standards loaded or requested.';
    }

    final lowerKeywords = keywords.map((k) => k.toLowerCase()).toList();
    List<Map<String, dynamic>> matches = [];

    _standardsData!.forEach((key, value) {
      final chunks = value['chunks'] as List<dynamic>? ?? [];
      final title = value['title'] ?? 'Unknown Standard';

      for (var chunk in chunks) {
        String chunkStr = chunk.toString();
        String chunkLower = chunkStr.toLowerCase();

        int matchCount = 0;
        for (var kw in lowerKeywords) {
          if (chunkLower.contains(kw)) {
            matchCount++;
          }
        }

        if (matchCount > 0) {
          matches.add({
            'title': title,
            'content': chunkStr,
            'score': matchCount,
          });
        }
      }
    });

    // Sort by match count descending
    matches.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Limit to top 15 chunks to avoid exceeding the AI's context window
    final topMatches = matches.take(15).toList();

    if (topMatches.isEmpty) {
      return 'No specific clauses found for the detected features. Please refer to general AS/NZS 3500 requirements.';
    }

    StringBuffer sb = StringBuffer();
    for (var match in topMatches) {
      sb.writeln('Source: ${match['title']}');
      sb.writeln(match['content']);
      sb.writeln('---');
    }

    return sb.toString();
  }
}
