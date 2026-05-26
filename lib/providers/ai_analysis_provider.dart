import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/compliance_result.dart';
import '../services/ai_analysis_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



/// State model for AI Vision analysis tracking.
class AiAnalysisState {
  final bool isLoading;
  final String? error;
  final ComplianceResult? result;
  final bool canAnalyze;
  final int dailyRemaining;

  const AiAnalysisState({
    required this.isLoading,
    this.error,
    this.result,
    required this.canAnalyze,
    required this.dailyRemaining,
  });

  factory AiAnalysisState.initial() {
    return const AiAnalysisState(
      isLoading: false,
      canAnalyze: true,
      dailyRemaining: 5,
    );
  }

  AiAnalysisState copyWith({
    bool? isLoading,
    String? error,
    ComplianceResult? result,
    bool? canAnalyze,
    int? dailyRemaining,
  }) {
    return AiAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow nullifying error
      result: result ?? this.result,
      canAnalyze: canAnalyze ?? this.canAnalyze,
      dailyRemaining: dailyRemaining ?? this.dailyRemaining,
    );
  }
}

class AiAnalysisNotifier extends Notifier<AiAnalysisState> {
  final AiAnalysisService _aiService = AiAnalysisService();

  @override
  AiAnalysisState build() {
    // Asynchronously load initial rate limit state
    _refreshRateLimit();
    return AiAnalysisState.initial();
  }

  Future<void> _refreshRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final isGold = prefs.getBool('is_gold_member') ?? false;
    if (isGold) {
      state = state.copyWith(
        canAnalyze: true,
        dailyRemaining: 99999,
      );
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString('rate_limiter_date');
    final count = prefs.getInt('rate_limiter_count') ?? 0;
    
    final currentCount = storedDate == today ? count : 0;
    final remaining = (5 - currentCount).clamp(0, 5);
    
    state = state.copyWith(
      canAnalyze: remaining > 0,
      dailyRemaining: remaining,
    );
  }

  /// Upgrades the user account to the Plumbnator Gold tier, unlocking unlimited analyses.
  Future<void> upgradeToGold() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_gold_member', true);
    await _refreshRateLimit();
  }

  Future<void> runAnalysis(List<int> imageBytes, {bool persist = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _aiService.analyzePlumbingInstallation(
        imageBytes: imageBytes,
        persist: persist,
      );
      await _refreshRateLimit();
      state = state.copyWith(isLoading: false, result: res);
    } on RateLimitExceededException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Analysis failed. Fallback active.');
    }
  }

  void reset() {
    state = state.copyWith(result: null, error: null);
    _refreshRateLimit();
  }

  Future<void> flagResultManually() async {
    if (state.result != null) {
      final updated = state.result!.copyWith(isManualFlag: true);
      // Persist the flagged status to firestore if needed
      await _aiService.saveResultToFirestore(updated);
      state = state.copyWith(result: updated);
    }
  }
}

final aiAnalysisProvider = NotifierProvider<AiAnalysisNotifier, AiAnalysisState>(AiAnalysisNotifier.new);

