/// Data models representing the core domain of Plumbnator QLD.
library;

/// Represents a plumbing job with compliance state and attributes.
class PlumbingJob {
  final String id;
  final String title;
  final String clientName;
  final String address;
  final DateTime dateCompleted;
  final String status; // 'Draft', 'Pending', 'Lodged'
  final double complianceScore;
  final List<String> issues;
  final bool form4Submitted;

  const PlumbingJob({
    required this.id,
    required this.title,
    required this.clientName,
    required this.address,
    required this.dateCompleted,
    required this.status,
    required this.complianceScore,
    required this.issues,
    this.form4Submitted = false,
  });

  /// Computes days left under the statutory QBCC 10-business-day lodgement limit.
  int get daysUntilOverdue {
    final deadline = dateCompleted.add(const Duration(days: 14)); // Roughly 10 business days
    return deadline.difference(DateTime.now()).inDays;
  }

  /// Checks if the job is overdue for Form 4 lodgement.
  bool get isOverdue => !form4Submitted && daysUntilOverdue < 0;

  /// Creates a copy of the PlumbingJob with updated values.
  PlumbingJob copyWith({
    String? status,
    double? complianceScore,
    List<String>? issues,
    bool? form4Submitted,
  }) {
    return PlumbingJob(
      id: id,
      title: title,
      clientName: clientName,
      address: address,
      dateCompleted: dateCompleted,
      status: status ?? this.status,
      complianceScore: complianceScore ?? this.complianceScore,
      issues: issues ?? this.issues,
      form4Submitted: form4Submitted ?? this.form4Submitted,
    );
  }
}

/// Represents a safety risk profile for high-risk Safe Work Method Statements.
class SwmsProfile {
  final String id;
  final String taskName;
  final List<String> hazards;
  final List<String> controlMeasures;
  final bool isSigned;
  final String? signedBy;
  final DateTime? signedAt;

  const SwmsProfile({
    required this.id,
    required this.taskName,
    required this.hazards,
    required this.controlMeasures,
    this.isSigned = false,
    this.signedBy,
    this.signedAt,
  });

  /// Signs off the SWMS.
  SwmsProfile sign(String plumberName) {
    return SwmsProfile(
      id: id,
      taskName: taskName,
      hazards: hazards,
      controlMeasures: controlMeasures,
      isSigned: true,
      signedBy: plumberName,
      signedAt: DateTime.now(),
    );
  }
}
