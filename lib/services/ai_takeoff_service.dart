import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'compliance_rules_engine.dart';

/// Represents an item extracted from a blueprint or generated via compliance rules.
class TakeoffItem {
  final String name;
  final int quantity;
  final String category; // 'Pipe', 'Fitting', 'Fixture', 'Compliance'
  final String? complianceReason;

  TakeoffItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.complianceReason,
  });
}

/// A service to interact with Gemini Pro Vision (simulated) for blueprint analysis
/// and integrate with the [ComplianceRulesEngine] for AS/NZS 3500 checks.
class AITakeoffService {
  final ComplianceRulesEngine _rulesEngine;

  AITakeoffService(this._rulesEngine);

  /// Analyzes a blueprint (simulated via filename) and returns a compliant Bill of Materials.
  Future<List<TakeoffItem>> generateCompliantBoM(String blueprintPath) async {
    // 1. Simulate API delay for Gemini Pro Vision analyzing the blueprint
    await Future.delayed(const Duration(seconds: 2));

    // 2. Mock raw extraction data (what Gemini would return)
    final rawExtraction = [
      TakeoffItem(name: '100mm DWV PVC Pipe (meters)', quantity: 24, category: 'Pipe'),
      TakeoffItem(name: '100mm 45° Junction', quantity: 3, category: 'Fitting'),
      TakeoffItem(name: '100mm 90° Bend', quantity: 5, category: 'Fitting'),
      TakeoffItem(name: 'WC Pan (P-Trap)', quantity: 2, category: 'Fixture'),
      TakeoffItem(name: 'Vanity Basin', quantity: 2, category: 'Fixture'),
    ];

    // 3. Pass raw data through the Compliance RAG / Rules Engine
    final compliantBoM = await _rulesEngine.enforceStandards(rawExtraction);

    return compliantBoM;
  }
}

final complianceRulesEngineProvider = Provider<ComplianceRulesEngine>((ref) {
  return ComplianceRulesEngine();
});

final aiTakeoffServiceProvider = Provider<AITakeoffService>((ref) {
  final rulesEngine = ref.read(complianceRulesEngineProvider);
  return AITakeoffService(rulesEngine);
});
