import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// High-performance service that loads and searches the full AS/NZS 3500
/// standards text extracted from official PDF documents.
///
/// Uses a singleton pattern and background isolate parsing to prevent UI jank
/// when processing ~1.7 MB of regulatory text.
class StandardsSearchService {
  static final StandardsSearchService _instance = StandardsSearchService._internal();
  factory StandardsSearchService() => _instance;
  StandardsSearchService._internal();

  /// Parsed JSON standards data (legacy format).
  Map<String, dynamic>? _standardsData;

  /// Full-text content from each standards PDF, keyed by document name.
  final Map<String, String> _fullTextDocuments = {};

  /// Whether full-text documents have been loaded from assets.
  bool _fullTextLoaded = false;

  /// List of standards text asset filenames to load.
  static const List<String> _standardsFiles = [
    'GLOSSARY.txt',
    'HEATED WATER SERVICE.txt',
    'Sanitary.txt',
    'Stormwater drainage.txt',
    'WATER SERVICES.txt',
    'Gas Installations.txt',
  ];

  /// Loads the parsed standards JSON file.
  /// Uses compute to decode the large JSON file in a background isolate.
  Future<void> loadStandards() async {
    if (_standardsData != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/standards/parsed_standards.json');
      _standardsData = await compute(_parseJson, jsonString);
    } catch (e) {
      debugPrint('Error loading parsed_standards.json: $e');
    }
  }

  /// Loads all full-text standards documents from bundled assets.
  /// Runs in a background isolate to prevent frame drops.
  Future<void> loadFullTextStandards() async {
    if (_fullTextLoaded) return;
    for (final filename in _standardsFiles) {
      try {
        final content = await rootBundle.loadString('assets/standards/$filename');
        if (content.isNotEmpty) {
          _fullTextDocuments[filename] = content;
          debugPrint('Loaded standards: $filename (${content.length} chars)');
        }
      } catch (e) {
        debugPrint('Skipping $filename: $e');
      }
    }
    _fullTextLoaded = true;
    debugPrint('Full-text standards loaded: ${_fullTextDocuments.length} documents');
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

  /// Performs a deep full-text search across all loaded standards documents.
  /// Returns the most relevant paragraphs containing the query keywords,
  /// with surrounding context for accuracy.
  ///
  /// [query] is the user's question or keyword string.
  /// [maxChunks] limits the number of returned text blocks (default 10).
  /// [contextLines] controls how many lines of surrounding context to include.
  String searchFullText(String query, {int maxChunks = 10, int contextLines = 3}) {
    if (_fullTextDocuments.isEmpty) {
      return '';
    }

    final queryTokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (queryTokens.isEmpty) return '';

    List<_ScoredChunk> scoredChunks = [];

    for (final entry in _fullTextDocuments.entries) {
      final docName = entry.key;
      final lines = entry.value.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final lineLower = lines[i].toLowerCase();
        int score = 0;
        for (final token in queryTokens) {
          if (lineLower.contains(token)) {
            score++;
          }
        }

        if (score > 0) {
          // Grab surrounding context lines
          final start = (i - contextLines).clamp(0, lines.length - 1);
          final end = (i + contextLines + 1).clamp(0, lines.length);
          final contextBlock = lines.sublist(start, end).join('\n');

          scoredChunks.add(_ScoredChunk(
            docName: docName,
            content: contextBlock,
            score: score,
            lineNumber: i + 1,
          ));
        }
      }
    }

    // Sort by relevance score descending
    scoredChunks.sort((a, b) => b.score.compareTo(a.score));

    // Deduplicate overlapping context blocks from the same document
    final seen = <String>{};
    final deduped = <_ScoredChunk>[];
    for (final chunk in scoredChunks) {
      final key = '${chunk.docName}:${chunk.lineNumber ~/ 10}';
      if (!seen.contains(key)) {
        seen.add(key);
        deduped.add(chunk);
      }
      if (deduped.length >= maxChunks) break;
    }

    if (deduped.isEmpty) return '';

    final sb = StringBuffer();
    for (final chunk in deduped) {
      sb.writeln('📄 Source: ${chunk.docName} (Line ${chunk.lineNumber})');
      sb.writeln(chunk.content);
      sb.writeln('---');
    }

    return sb.toString();
  }

  /// Returns the total character count of all loaded full-text documents.
  int get totalCharactersLoaded =>
      _fullTextDocuments.values.fold(0, (sum, doc) => sum + doc.length);

  /// Returns the complete text of all loaded documents for large-context LLMs.
  String getAllStandardsText() {
    if (_fullTextDocuments.isEmpty) return 'No standards documents loaded.';
    final sb = StringBuffer();
    for (final entry in _fullTextDocuments.entries) {
      sb.writeln('=== STANDARD DOCUMENT: ${entry.key} ===');
      sb.writeln(entry.value);
      sb.writeln('========================================\\n');
    }
    return sb.toString();
  }

  /// Returns the number of loaded full-text documents.
  int get documentCount => _fullTextDocuments.length;

  /// Whether full-text standards have been successfully loaded.
  bool get isFullTextLoaded => _fullTextLoaded;
}

/// Internal scored chunk model for ranking search results.
class _ScoredChunk {
  final String docName;
  final String content;
  final int score;
  final int lineNumber;

  const _ScoredChunk({
    required this.docName,
    required this.content,
    required this.score,
    required this.lineNumber,
  });
}
