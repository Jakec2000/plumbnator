/// Structured representation of Australian/Queensland plumbing standards clauses.
library;

/// Model representing a single standard or regulation clause.
class PlumbingStandardClause {
  /// The code identifier (e.g., 'AS/NZS 3500.2:2021').
  final String standardCode;

  /// The clause number (e.g., 'Clause 4.4').
  final String clauseNumber;

  /// The title of the clause (e.g., 'Minimum Soil Cover').
  final String title;

  /// The category (e.g., 'Drainage', 'Water Supply', 'Backflow', 'QLD Regulations').
  final String category;

  /// A detailed summary of the clause.
  final String summaryText;

  /// Key metrics/tolerances associated with the clause.
  final List<String> technicalMetrics;

  /// Precise compliance checklist for AI auditing.
  final List<String> complianceChecklist;

  /// Creates a [PlumbingStandardClause] instances.
  const PlumbingStandardClause({
    required this.standardCode,
    required this.clauseNumber,
    required this.title,
    required this.category,
    required this.summaryText,
    required this.technicalMetrics,
    required this.complianceChecklist,
  });

  /// Converts the clause to a readable prompt string.
  String toPromptString() {
    return '''
Standard: $standardCode
Clause: $clauseNumber
Title: $title
Category: $category
Summary: $summaryText
Metrics: ${technicalMetrics.join(', ')}
Checklist: ${complianceChecklist.join('; ')}
''';
  }
}

/// Seeded database registry containing precise statutory plumbing standards.
class PlumbingStandardsRegistry {
  /// The complete list of statutory plumbing standards clauses.
  static const List<PlumbingStandardClause> clauses = [
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 3.4',
      title: 'Maximum Static Water Pressure',
      category: 'Water Supply',
      summaryText: 'Ensures the static water pressure at any outlet inside a building does not exceed the structural limit to prevent water hammer and fixture failures.',
      technicalMetrics: [
        'Max static outlet pressure: 500 kPa',
        'Pressure limiting valve (PLV) must be installed if boundary pressure exceeds 500 kPa',
      ],
      complianceChecklist: [
        'Boundary supply pressure measured.',
        'PLV installed if pressure > 500 kPa.',
        'PLV set-point verified.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 5.2',
      title: 'Water Service Pipe Lagging and Thermal Insulation',
      category: 'Water Supply',
      summaryText: 'Mandates insulation on metal pipes to prevent thermal loss, condensation, or freezing depending on climatic exposure.',
      technicalMetrics: [
        'DN20 and larger copper pipes require insulation',
        'Minimum insulation R-value for heated water services: R-0.3 to R-0.6',
      ],
      complianceChecklist: [
        'Copper pipe sizing verified.',
        'Continuous lagging installed on heated pipes.',
        'Insulation thickness and material R-value checked.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 4.4 & Section 9',
      title: 'Minimum Cover Over Underground PVC Pipes',
      category: 'Drainage',
      summaryText: 'Ensures underground sanitary sewer or storm pipelines are buried at sufficient depths to prevent damage from local vehicle or foot traffic.',
      technicalMetrics: [
        'Domestic Yards (No traffic): 300 mm minimum cover',
        'Residential Driveways (Light traffic): 450 mm minimum cover',
        'Heavy Traffic / Roadways (Unpaved): 750 mm minimum cover',
        'Under Concrete Slabs: 100 mm minimum concrete/soil cushion',
      ],
      complianceChecklist: [
        'Trench depth measured prior to bedding.',
        'Ground condition (domestic, driveway, unpaved road) determined.',
        'Calculated soil cover matches minimum category threshold.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Table 6.1',
      title: 'Minimum Sanitary Pipeline Grades',
      category: 'Drainage',
      summaryText: 'Defines strict gradient percentages based on sewer pipe diameter to guarantee adequate self-cleansing velocity and flow.',
      technicalMetrics: [
        'DN80 Sewer Pipeline: Minimum grade 2.50% (1:40 drop)',
        'DN100 Sewer Pipeline: Minimum grade 1.65% (1:60 drop)',
        'DN150 Sewer Pipeline: Minimum grade 1.20% (1:80 drop)',
      ],
      complianceChecklist: [
        'Diameter of drainage pipe verified.',
        'Gradient measured via laser level or inclinometer.',
        'Calculated grade equals or exceeds table minimum.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 6.5',
      title: 'Sanitary Stack Venting Termination Heights',
      category: 'Drainage',
      summaryText: 'Specifies height limits for sanitary stack terminal vent cowls above roofing or nearby openable windows to control sewer gas escape.',
      technicalMetrics: [
        'Termination above roof line: 150 mm minimum',
        'Distance to any openable window/door: 3.0 m minimum unless extended 600mm above window head',
      ],
      complianceChecklist: [
        'Roof outlet cowl termination height checked.',
        'Horizontal clearance from doors, windows, or balconies measured.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 1.9 & Clause 5.3',
      title: 'Hot Water Delivery Temperature Ceilings',
      category: 'Water Supply',
      summaryText: 'Enforces strict temperature ceilings at sanitary fixtures primarily used for personal hygiene to protect users from scalding risks.',
      technicalMetrics: [
        'Sanitary Outlets (Showers, Baths, Basins): 50°C maximum limit',
        'Aged Care, Early Childhood, and Disability Services: 45°C maximum limit',
        'Kitchen/Laundry Outlets: Valve bypass allowed (50-60°C hot water)',
      ],
      complianceChecklist: [
        'Tempering valve or thermostatic mixing valve installed.',
        'Personal hygiene outlet temperature tested and recorded.',
        'Correct valve bypass paths verified.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 4.2',
      title: 'Water Heater Storage Set-Point Temperature',
      category: 'Water Supply',
      summaryText: 'Establishes a lower-bound storage temperature within hot water cylinders to completely prevent the colonization and growth of Legionella bacteria.',
      technicalMetrics: [
        'Storage tank core temperature: 60°C minimum set-point',
      ],
      complianceChecklist: [
        'Storage tank thermostat setting inspected.',
        'Heating cycle tested to reach at least 60°C.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS 2845.3',
      clauseNumber: 'Section 4 - RPZD Valve Tolerances',
      title: 'Reduced Pressure Zone Device (RPZD) Testing Limits',
      category: 'Backflow',
      summaryText: 'Enforces physical pressure drop thresholds within high-hazard testable backflow prevention devices.',
      technicalMetrics: [
        'First Check Valve pressure drop: 35 kPa minimum drop',
        'Relief Valve opening pressure point: 14 kPa minimum point',
        'Second Check Valve pressure drop: 7 kPa minimum drop',
      ],
      complianceChecklist: [
        'Upstream supply pressure verified (> 150 kPa).',
        'Test kit attached and air purged.',
        'Check valve drops and relief port opening point logged.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      clauseNumber: 'Form 9 Timelines',
      title: 'Form 9 Backflow Prevention Testing',
      category: 'QLD Regulations',
      summaryText: 'Mandates the annual testing registration schedule of high-hazard backflow valves with the local government council.',
      technicalMetrics: [
        'Form 9 Backflow Test Certificate lodgement: Within 10 business days of test',
        'Must be commissioned and tested annually by a licensed tester',
      ],
      complianceChecklist: [
        'Testing performed by certified Backflow Tester.',
        'Form 9 completed with serials and pressures.',
        'Lodged with local council within 10-day window.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'QBCC Regulations',
      clauseNumber: 'Form 4 Lodgements',
      title: 'QBCC Form 4 Lodgement Timelines',
      category: 'QLD Regulations',
      summaryText: 'Details statutory rules and deadlines for submitting notifiable work forms to the Queensland Building and Construction Commission.',
      technicalMetrics: [
        'Form 4 Lodgement window: Within 10 business days of completing work',
        'Requires listing authentic WaterMark material numbers and client address',
      ],
      complianceChecklist: [
        'Notifiable plumbing/drainage work completed.',
        'Form 4 drafted with correct details.',
        'Submitted to QBCC portal within 10 business days.',
      ],
    ),
  ];

  /// Builds a combined textual representation of the standards database for AI injection.
  static String buildRegistryText() {
    return clauses.map((c) => c.toPromptString()).join('\n---\n');
  }
}
