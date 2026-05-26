import 'ai_takeoff_service.dart';
import 'supabase_client_service.dart';

/// An engine that enforces AS/NZS 3500 rules on raw material extractions.
/// Uses high-fidelity remote standard lookups from the Supabase pgvector vault.
class ComplianceRulesEngine {
  /// Enforces plumbing standards against a list of extracted items.
  Future<List<TakeoffItem>> enforceStandards(List<TakeoffItem> rawItems) async {
    // 1. Query remote standards using Supabase Client Service
    final supabase = SupabaseClientService();
    final List<TakeoffItem> finalBoM = List.from(rawItems);
    
    int totalPvcLength = 0;
    int wcCount = 0;

    for (final item in rawItems) {
      if (item.name.contains('PVC Pipe (meters)')) {
        totalPvcLength += item.quantity;
      }
      if (item.name.contains('WC Pan')) {
        wcCount += item.quantity;
      }
    }

    // Rule 1: AS/NZS 3500.2 - Minimum bracket spacing for 100mm PVC is 1.2m
    if (totalPvcLength > 0) {
      final standards = await supabase.searchRemoteStandards('Clip Spacings for PVC Pipes');
      String clipReason = 'AS/NZS 3500.2 Clause Table 4.3: Maximum Clip Spacings for PVC Pipes is 1.2 m maximum spacing.';
      if (standards.isNotEmpty) {
        final match = standards.first;
        clipReason = '${match.standardCode} ${match.clauseNumber}: ${match.title} - ${match.summaryText} (Span: 1.2m maximum)';
      }
      
      int requiredBrackets = (totalPvcLength / 1.2).ceil();
      finalBoM.add(TakeoffItem(
        name: '100mm Stand-off Brackets',
        quantity: requiredBrackets,
        category: 'Compliance',
        complianceReason: clipReason,
      ));
    }

    // Rule 2: AS/NZS 3500.2 - Inspection Openings (IO) are required at the base of every stack and every 30m of main drain.
    if (wcCount > 0) {
      final standards = await supabase.searchRemoteStandards('Inspection Opening IO Spacing Intervals');
      String ioReason = 'AS/NZS 3500.2 Clause 13.2: IO required at base of soil/waste stack.';
      if (standards.isNotEmpty) {
        final match = standards.first;
        ioReason = '${match.standardCode} ${match.clauseNumber}: ${match.title} - ${match.summaryText}';
      }

      finalBoM.add(TakeoffItem(
        name: '100mm Inspection Opening (IO)',
        quantity: wcCount,
        category: 'Compliance',
        complianceReason: ioReason,
      ));
    }

    // Rule 3: AS/NZS 3500 - Primer/Solvent Cement for PVC fittings
    if (rawItems.any((i) => i.category == 'Fitting')) {
      finalBoM.add(TakeoffItem(
        name: 'Type P PVC Solvent Cement & Primer (500ml)',
        quantity: 1,
        category: 'Compliance',
        complianceReason: 'Manufacturer specs & AS/NZS 3500: High-pressure Type P solvent required for secure jointing.',
      ));
    }

    return finalBoM;
  }
}
