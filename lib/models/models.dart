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
  final String? drainageSketchBase64;

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
    this.drainageSketchBase64,
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
    String? drainageSketchBase64,
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
      drainageSketchBase64: drainageSketchBase64 ?? this.drainageSketchBase64,
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

/// Represents a backflow prevention device with testing parameters under AS 2845.3.
class BackflowDevice {
  final String id;
  final String serialNumber;
  final String brand;
  final String modelName;
  final int sizeDn; // e.g. 20, 25, 32, 50
  final String deviceType; // 'RPZD' or 'Double Check Valve'
  final String location;
  final double upstreamPressureKpa;
  final double firstCheckValueKpa;
  final double reliefValveOpeningKpa; // Only used for RPZD
  final double secondCheckValueKpa;
  final String testerName;
  final String testerLicence;
  final DateTime testDate;
  final bool isSubmitted;

  const BackflowDevice({
    required this.id,
    required this.serialNumber,
    required this.brand,
    required this.modelName,
    required this.sizeDn,
    required this.deviceType,
    required this.location,
    required this.upstreamPressureKpa,
    required this.firstCheckValueKpa,
    required this.reliefValveOpeningKpa,
    required this.secondCheckValueKpa,
    required this.testerName,
    required this.testerLicence,
    required this.testDate,
    this.isSubmitted = false,
  });

  /// Evaluates whether the device passes testing standards under AS 2845.3.
  bool get passesInspection {
    if (deviceType == 'RPZD') {
      // RPZD criteria:
      // 1. First check valve drop >= 35 kPa
      // 2. Relief valve opening pressure >= 14 kPa
      // 3. Second check valve drop >= 7 kPa
      return firstCheckValueKpa >= 35.0 &&
          reliefValveOpeningKpa >= 14.0 &&
          secondCheckValueKpa >= 7.0;
    } else {
      // Double Check Valve criteria:
      // 1. First check valve drop >= 7 kPa
      // 2. Second check valve drop >= 7 kPa
      return firstCheckValueKpa >= 7.0 && secondCheckValueKpa >= 7.0;
    }
  }

  /// Copies this device with updated submission status.
  BackflowDevice copyWith({
    bool? isSubmitted,
  }) {
    return BackflowDevice(
      id: id,
      serialNumber: serialNumber,
      brand: brand,
      modelName: modelName,
      sizeDn: sizeDn,
      deviceType: deviceType,
      location: location,
      upstreamPressureKpa: upstreamPressureKpa,
      firstCheckValueKpa: firstCheckValueKpa,
      reliefValveOpeningKpa: reliefValveOpeningKpa,
      secondCheckValueKpa: secondCheckValueKpa,
      testerName: testerName,
      testerLicence: testerLicence,
      testDate: testDate,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
