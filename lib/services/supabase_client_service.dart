import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/standards_registry.dart';

/// Service interfacing with the Supabase pgvector database for real-time semantic queries.
/// Falls back to local standard search if cloud keys or connection are unavailable.
class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  // Load environmental keys
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool _initialized = false;

  /// Initializes Supabase configuration with client secrets if present.
  static Future<void> init() async {
    if (_initialized) return;
    if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
        );
        _initialized = true;
      } catch (_) {
        // Gracefully allow local search on failure
      }
    }
  }

  /// Queries the remote Supabase standards embeddings via cosine similarity match.
  /// Generates the query embedding via Google Generative Language REST interface first.
  Future<List<PlumbingStandardClause>> searchRemoteStandards(
    String query, {
    double threshold = 0.3,
    int count = 10,
  }) async {
    await init();

    if (!_initialized || _geminiApiKey.isEmpty) {
      return _localSearch(query);
    }

    try {
      final embedding = await _getEmbedding(query);
      final List<dynamic> result = await Supabase.instance.client.rpc(
        'match_standards',
        params: {
          'query_embedding': embedding,
          'match_threshold': threshold,
          'match_count': count,
        },
      );

      if (result.isEmpty) {
        return _localSearch(query);
      }

      return result.map((item) {
        return PlumbingStandardClause(
          standardCode: item['standard_code'] as String? ?? '',
          clauseNumber: item['clause_number'] as String? ?? '',
          title: item['title'] as String? ?? '',
          category: item['category'] as String? ?? '',
          summaryText: item['summary_text'] as String? ?? '',
          technicalMetrics: List<String>.from(item['technical_metrics'] as List? ?? []),
          complianceChecklist: List<String>.from(item['compliance_checklist'] as List? ?? []),
        );
      }).toList();
    } catch (_) {
      return _localSearch(query);
    }
  }

  /// Generates a 768-dimension vector embedding via Gemini REST API.
  Future<List<double>> _getEmbedding(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=$_geminiApiKey'
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'models/text-embedding-004',
        'content': {
          'parts': [{'text': text}]
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> values = data['embedding']['values'];
      return values.map((e) => (e as num).toDouble()).toList();
    } else {
      throw Exception('Failed to generate embedding: ${response.statusCode}');
    }
  }

  /// Local token-matching search fallback if offline/uncertified.
  List<PlumbingStandardClause> _localSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final tokens = lowerQuery.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    if (tokens.isEmpty) {
      return PlumbingStandardsRegistry.clauses.take(5).toList();
    }

    final List<MapEntry<PlumbingStandardClause, int>> scored = [];
    for (final clause in PlumbingStandardsRegistry.clauses) {
      int score = 0;
      final text = [
        clause.standardCode,
        clause.clauseNumber,
        clause.title,
        clause.category,
        clause.summaryText,
        ...clause.technicalMetrics,
        ...clause.complianceChecklist,
      ].join(' ').toLowerCase();

      for (final token in tokens) {
        if (text.contains(token)) {
          score++;
        }
      }
      if (score > 0) {
        scored.add(MapEntry(clause, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}
