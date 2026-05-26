/// Model class representing the result of an AI vision compliance analysis.
class ComplianceResult {
  final bool isCompliant;
  final double confidenceScore;
  final List<String> issues;
  final List<String> clauses;
  final List<Map<String, dynamic>> hotspots;
  final DateTime timestamp;
  final bool isManualFlag;
  final String? imageUrl;
  final String? alignmentCategory;
  final String? measuredDeviation;

  const ComplianceResult({
    required this.isCompliant,
    required this.confidenceScore,
    required this.issues,
    required this.clauses,
    required this.hotspots,
    required this.timestamp,
    this.isManualFlag = false,
    this.imageUrl,
    this.alignmentCategory,
    this.measuredDeviation,
  });

  /// Factory constructor to create a ComplianceResult from JSON/Map representation.
  factory ComplianceResult.fromJson(Map<String, dynamic> json) {
    return ComplianceResult(
      isCompliant: json['isCompliant'] as bool? ?? false,
      confidenceScore: (json['confidenceScore'] as num? ?? 0.0).toDouble(),
      issues: List<String>.from(json['issues'] as List? ?? []),
      clauses: List<String>.from(json['clauses'] as List? ?? []),
      hotspots: List<Map<String, dynamic>>.from(
        (json['hotspots'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isManualFlag: json['isManualFlag'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      alignmentCategory: json['alignmentCategory'] as String?,
      measuredDeviation: json['measuredDeviation'] as String?,
    );
  }

  /// Converts the ComplianceResult to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'isCompliant': isCompliant,
      'confidenceScore': confidenceScore,
      'issues': issues,
      'clauses': clauses,
      'hotspots': hotspots,
      'timestamp': timestamp.toIso8601String(),
      'isManualFlag': isManualFlag,
      'imageUrl': imageUrl,
      'alignmentCategory': alignmentCategory,
      'measuredDeviation': measuredDeviation,
    };
  }

  /// Creates a copy of this result with overridden values.
  ComplianceResult copyWith({
    bool? isCompliant,
    double? confidenceScore,
    List<String>? issues,
    List<String>? clauses,
    List<Map<String, dynamic>>? hotspots,
    DateTime? timestamp,
    bool? isManualFlag,
    String? imageUrl,
    String? alignmentCategory,
    String? measuredDeviation,
  }) {
    return ComplianceResult(
      isCompliant: isCompliant ?? this.isCompliant,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      issues: issues ?? this.issues,
      clauses: clauses ?? this.clauses,
      hotspots: hotspots ?? this.hotspots,
      timestamp: timestamp ?? this.timestamp,
      isManualFlag: isManualFlag ?? this.isManualFlag,
      imageUrl: imageUrl ?? this.imageUrl,
      alignmentCategory: alignmentCategory ?? this.alignmentCategory,
      measuredDeviation: measuredDeviation ?? this.measuredDeviation,
    );
  }
}
