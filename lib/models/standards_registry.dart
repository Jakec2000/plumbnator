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
    // --- AS/NZS 3500.1 (Water Services) ---
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 3.4',
      title: 'Maximum Static Water Pressure',
      category: 'Water Supply',
      summaryText: 'Ensures the static water pressure at any outlet inside a building does not exceed the structural limit to prevent water hammer, pipe bursts, and fixture failures.',
      technicalMetrics: [
        'Max static outlet pressure: 500 kPa',
        'Pressure limiting valve (PLV) must be installed if boundary pressure exceeds 500 kPa',
        'Exceptions apply only to dedicated fire service outlets',
      ],
      complianceChecklist: [
        'Boundary supply pressure measured.',
        'PLV installed if pressure > 500 kPa.',
        'PLV set-point verified and locked.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 5.2',
      title: 'Water Service Pipe Lagging and Thermal Insulation',
      category: 'Water Supply',
      summaryText: 'Mandates continuous insulation on metal pipes to prevent thermal loss, condensation, or freezing depending on regional climatic exposure.',
      technicalMetrics: [
        'DN20 and larger copper pipes require insulation',
        'Minimum insulation R-value for heated water services: R-0.3 to R-0.6',
        'Lagging thickness must be at least 9mm in high-risk frost areas',
      ],
      complianceChecklist: [
        'Copper pipe sizing verified.',
        'Continuous lagging installed on heated pipes.',
        'Insulation thickness and material R-value checked.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 3.3.2',
      title: 'Flow Velocity Limits in Pipes',
      category: 'Water Supply',
      summaryText: 'Limits design flow velocity inside main water pathways to prevent internal pipe wall erosion, excessive noise, and dangerous hydraulic surges.',
      technicalMetrics: [
        'Maximum flow velocity for copper pipes: 2.0 m/s',
        'Maximum flow velocity for plastic (PEX, poly) pipes: 3.0 m/s',
      ],
      complianceChecklist: [
        'Calculated nominal flow rates cross-referenced.',
        'Internal flow velocities checked against material limits.',
        'Acoustic insulation and hydraulic arrestors added where velocity exceeds 1.5 m/s.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 14.2.3',
      title: 'Backflow Prevention Hazard Ratings',
      category: 'Backflow',
      summaryText: 'Classifies premises into High, Medium, and Low cross-connection hazards and mandates suitable testing valve devices to secure city mains.',
      technicalMetrics: [
        'High Hazard: Requires Reduced Pressure Zone Device (RPZD) or break tank with registered air gap',
        'Medium Hazard: Requires Double Check Valve (DCV) device',
        'Low Hazard: Requires Dual Check Valve or non-return valves',
      ],
      complianceChecklist: [
        'Premise cross-connection risk rating determined.',
        'Appropriate testing/non-testable device selected.',
        'Clearance and ventilation spacing for valve drainage verified.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.1:2021',
      clauseNumber: 'Clause 11.2',
      title: 'Water Meter Spacing and Clearances',
      category: 'Water Supply',
      summaryText: 'Mandates minimum spacing, heights, and physical accessibility clearances for primary and sub-water meters at properties.',
      technicalMetrics: [
        'Minimum meter ground clearance: 150 mm',
        'Minimum clear spacing between parallel sub-meters: 150 mm',
        'Must be located within 1.0 m of the front property boundary',
      ],
      complianceChecklist: [
        'Meter assembly setback from property boundary measured.',
        'Vertical and lateral access clearances confirmed.',
        'Protective casing/cage added if susceptible to vehicular damage.',
      ],
    ),

    // --- AS/NZS 3500.2 (Sanitary Drainage) ---
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 4.4 & Section 9',
      title: 'Minimum Cover Over Underground PVC Pipes',
      category: 'Drainage',
      summaryText: 'Ensures underground sanitary sewer or storm pipelines are buried at sufficient depths to prevent damage from heavy vehicles, soil shifting, or foot traffic.',
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
      summaryText: 'Defines strict gradient percentages based on sewer pipe diameter to guarantee adequate self-cleansing velocity and sweep.',
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
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Table 4.3',
      title: 'Maximum Clip Spacings for PVC Pipes',
      category: 'Drainage',
      summaryText: 'Specifies the maximum allowable distance between pipe brackets or clips to ensure PVC sanitary drainage pipes do not sag or lose their required gradient.',
      technicalMetrics: [
        'DN40 to DN50 PVC pipes: 1.2 m maximum spacing (graded/horizontal)',
        'DN65 to DN100 PVC pipes: 1.5 m maximum spacing (graded/horizontal)',
        'DN150 PVC pipes: 2.0 m maximum spacing (graded/horizontal)',
        'Vertical stacks: 2.5 m maximum spacing for DN100 and above',
      ],
      complianceChecklist: [
        'Pipe diameter verified.',
        'Distance between clips measured.',
        'Spacings confirmed within allowable AS/NZS table limits.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 4.6.2',
      title: 'Fixture Discharge Pipe Sizing',
      category: 'Drainage',
      summaryText: 'Mandates minimum diameter for sanitary discharge lines based on cumulative Fixture Unit (FU) allocations to prevent drain backup.',
      technicalMetrics: [
        'Water Closet (Toilet): DN100 (100mm) minimum',
        'Kitchen Sink / Laundry Trough: DN50 (50mm) minimum',
        'Hand Basin: DN40 (40mm) minimum',
        'Maximum accumulated drainage load: calculated via fixture load factor tables',
      ],
      complianceChecklist: [
        'Cumulative fixture unit drainage load calculated.',
        'Minimum line diameter designated for each run.',
        'Grade adjustments verified if fixture load is altered.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 3.4',
      title: 'Trench Excavation and Shoring Limits',
      category: 'Drainage',
      summaryText: 'Implements site-safety mandates for trench works to safeguard plumbers from trench collapse or burial.',
      technicalMetrics: [
        'Trench depth threshold for shoring: 1.5 m maximum vertical face',
        'Trench width: Minimum 200 mm wider than pipe diameter',
        'Shoring, benching, or shielding required in all trenches > 1.5 m',
      ],
      complianceChecklist: [
        'Trench depth assessed.',
        'Shoring shields or benching slopes implemented for runs > 1.5m.',
        'Excavated soil placed at least 1.0 m away from trench edges.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 4.7.1',
      title: 'Boundary Trap Installations',
      category: 'Drainage',
      summaryText: 'Governs installations of primary boundary sewer isolation traps at the property perimeter to prevent main line sewer gas entering local networks.',
      technicalMetrics: [
        'Must be installed within property boundary near mains connection point',
        'Requires a sealed inspection shaft (IS) extended to ground level',
        'Must incorporate a fresh air inlet (FAI) cowl where required by local authorities',
      ],
      complianceChecklist: [
        'Boundary trap location set and excavation verified.',
        'Riser shaft extended to finished surface levels.',
        'Gastight access plugs fitted and pressure-sealed.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 13.2',
      title: 'Inspection Opening (IO) Spacing Intervals',
      category: 'Drainage',
      summaryText: 'Establishes the maximum allowable distance between access points for cleaning and camera inspection along main drain pipelines.',
      technicalMetrics: [
        'Maximum straight run interval: 30 m spacing between IOs',
        'Required at every change of direction exceeding 45 degrees',
        'Mandatory at the base of every soil stack or waste stack',
      ],
      complianceChecklist: [
        'Total pipe run lengths mapped.',
        'IO junctions added at intervals <= 30m.',
        'Junction angles measured and IO bases verified.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.2:2021',
      clauseNumber: 'Clause 4.8.4',
      title: 'Junction Connections in Main Drains',
      category: 'Drainage',
      summaryText: 'Prohibits the use of sharp, square connections to main sanitary pathways to prevent solids build-up and recurring plumbing chokes.',
      technicalMetrics: [
        'Connections must be made using sweep junctions or 45-degree wyes',
        '90-degree square tee connections are strictly prohibited on sanitary drainage lines',
      ],
      complianceChecklist: [
        'Junction materials inspected prior to solvent welding.',
        'All connections verified as wye/45-degree or sweeping fittings.',
        'Flow directional arrows aligned correctly.',
      ],
    ),

    // --- AS/NZS 3500.3 (Stormwater) ---
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.3:2021',
      clauseNumber: 'Table 5.2',
      title: 'Stormwater Pipe Catchment Sizing',
      category: 'Stormwater',
      summaryText: 'Calculates the required stormwater drain pipe diameter relative to roof catchment areas and regional rainfall intensities.',
      technicalMetrics: [
        'DN90 Stormwater Pipeline: Serves up to 60 m² roof area (at 1:100)',
        'DN100 Stormwater Pipeline: Serves up to 130 m² roof area (at 1:100)',
        'Sizing must handle 1-in-100-year Annual Recurrence Interval (ARI) events',
      ],
      complianceChecklist: [
        'Total roof catchment area calculated.',
        'Regional 100-yr ARI rainfall rate mapped.',
        'Pipeline diameter set matching or exceeding flow demand.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.3:2021',
      clauseNumber: 'Table 3.1',
      title: 'Box Gutter Minimum Widths and Sizing',
      category: 'Stormwater',
      summaryText: 'Implements structural parameters for commercial box gutters to prevent building roof overflows during torrential downpours.',
      technicalMetrics: [
        'Minimum box gutter width: 200 mm',
        'Minimum installation gradient: 1:200 (0.50% grade)',
        'Must feature integrated overflow sumps or high-flow rainheads',
      ],
      complianceChecklist: [
        'Gutter tray width measured.',
        'Fall gradient calibrated and verified with leveling gear.',
        'Dedicated emergency overflow lines routed clear of soffits.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.3:2021',
      clauseNumber: 'Clause 8.2',
      title: 'Downpipe Spacing and Roof Area Loadings',
      category: 'Stormwater',
      summaryText: 'Dictates the maximum distance between vertical roof water downpipes to secure gutters from overflowing into wall voids.',
      technicalMetrics: [
        'Maximum eaves gutter length per downpipe: 12.0 m run length',
        'Downpipe cross-sectional area: must match outlet flow design limits',
      ],
      complianceChecklist: [
        'Eaves gutter runs segmented.',
        'Downpipe drop locations mapped within the 12m limit.',
        'Downpipe connection expansion offsets incorporated.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.3:2021',
      clauseNumber: 'Clause 3.5',
      title: 'Rainwater Tank Overflow Outlets',
      category: 'Stormwater',
      summaryText: 'Ensures rainwater storage overflows are piped correctly back into municipal stormwater mains without causing property erosion or water backup.',
      technicalMetrics: [
        'Overflow outlet pipe: must match or exceed the tank inlet pipe diameter',
        'Air gap required on town water top-up connections to prevent backflow',
      ],
      complianceChecklist: [
        'Inlet and outlet diameters verified for diameter parity.',
        'Town water feed isolated with compliant air gap.',
        'Overflow line plumbed to legal point of discharge.',
      ],
    ),

    // --- AS/NZS 3500.4 (Heated Water Services) ---
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 1.9 & Clause 5.3',
      title: 'Hot Water Delivery Temperature Ceilings',
      category: 'Solar / Hot Water',
      summaryText: 'Enforces strict temperature ceilings at personal hygiene fixtures (showers, baths, hand basins) to prevent immediate severe scalding.',
      technicalMetrics: [
        'Sanitary Outlets (Showers, Baths, Basins): 50°C maximum limit',
        'Aged Care, Early Childhood, and Disability Services: 45°C maximum limit',
        'Kitchen/Laundry Outlets: Bypass allowed up to 60°C',
      ],
      complianceChecklist: [
        'Tempering valve or thermostatic mixing valve (TMV) installed.',
        'Outlet temperature calibrated, measured, and logged.',
        'Separated hot water delivery loops verified.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 4.2',
      title: 'Water Heater Storage Set-Point Temperature',
      category: 'Solar / Hot Water',
      summaryText: 'Establishes a minimum storage temperature within hot water vessels to prevent colonization of Legionella bacteria.',
      technicalMetrics: [
        'Storage tank core temperature: 60°C minimum set-point',
      ],
      complianceChecklist: [
        'Storage tank thermostat setting inspected.',
        'Heating cycle tested to verify target core heat of 60°C.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 7.2',
      title: 'Solar Hot Water Collector Mounting',
      category: 'Solar / Hot Water',
      summaryText: 'Implements structural, wind load, and hydraulic safety directives for mounting solar water heating thermal collectors on pitched roofs.',
      technicalMetrics: [
        'Mounting frames: must be engineered and certified to AS 1170.2 (wind loads)',
        'Copper or high-temp piping required for collector loops',
        'Integrated cold water expansion control valve (ECV) mandatory',
      ],
      complianceChecklist: [
        'Wind load ratings verified for building location.',
        'High-temperature rated plumbing loops installed.',
        'Expansion control valve routed to a safe point of discharge.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 8.2.2',
      title: 'Heat Trap Loops on Water Heaters',
      category: 'Solar / Hot Water',
      summaryText: 'Requires the installation of physical thermal siphon traps (heat traps) on storage hot water tanks to prevent hot water from circulating upwards and wasting energy.',
      technicalMetrics: [
        'Heat trap loop: minimum 150 mm vertical drop depth',
        'Must be installed on both inlet and outlet storage pipes',
      ],
      complianceChecklist: [
        'Physical vertical drop of piping measured at inlet/outlet.',
        'Thermal siphon flow loop verified.',
        'Insulated copper pipe wraps completed over heat trap bends.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 4.6',
      title: 'Safe Tray Requirements for Heaters',
      category: 'Solar / Hot Water',
      summaryText: 'Mandates the use of protective drainage trays beneath hot water units installed inside roofs or cupboards to prevent structural flooding.',
      technicalMetrics: [
        'Mandatory if leakage can cause structural or plasterboard ceiling damage',
        'Drain line sizing: DN50 minimum diameter',
        'Drain line route: must discharge to a conspicuous outside location',
      ],
      complianceChecklist: [
        'Safe tray centered under the heating cylinder.',
        'DN50 gravity drain line connected to bottom tray outlet.',
        'Conspicuous drainage exit point checked and free from blockages.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 3500.4:2021',
      clauseNumber: 'Clause 5.12',
      title: 'Copper Relief Line Valving and Outlets',
      category: 'Solar / Hot Water',
      summaryText: 'Mandates pressure and temperature relief valve (PTRV) drain line routing to avoid steam or boiling water discharge onto people.',
      technicalMetrics: [
        'Must use metallic pipes (copper only) for all relief lines',
        'Line diameter: DN15 or DN20 to match relief valve thread size',
        'Termination point: must feature a downward vertical drop and drain visibly above a gully or onto grass',
      ],
      complianceChecklist: [
        'Plastic piping avoided on relief ports.',
        'Discharge line fall angle checked and uninterrupted.',
        'Termination location verified as safe and fully visible.',
      ],
    ),

    // --- AS/NZS 5601.1 (Gas Installations) ---
    PlumbingStandardClause(
      standardCode: 'AS/NZS 5601.1:2023',
      clauseNumber: 'Clause 6.3',
      title: 'Gas Installation Ventilation in Enclosures',
      category: 'Gas',
      summaryText: 'Determines the minimum supply of fresh combustion air required for gas-burning appliances inside tightly-sealed rooms.',
      technicalMetrics: [
        'Type A non-flued appliances: 10 cm² free area per MJ/hr rating',
        'Must feature two separate openings (high and low levels)',
        'Combustion ventilation must draw directly from outdoor air sources',
      ],
      complianceChecklist: [
        'Cumulative megajoule (MJ) load computed.',
        'Vent opening calculations completed.',
        'Physical high and low draft path grills fitted and cleared.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 5601.1:2023',
      clauseNumber: 'Table 4.1',
      title: 'Gas Pipeline Allowable Pressure Drops',
      category: 'Gas',
      summaryText: 'Restricts the permitted frictional friction pressure losses in gas pipe networks to maintain correct burner flame geometry at appliances.',
      technicalMetrics: [
        'Natural Gas (NG) systems: Maximum 0.075 kPa drop (meter to appliance)',
        'LPG systems: Maximum 0.25 kPa drop (regulator to appliance)',
      ],
      complianceChecklist: [
        'Pipe run lengths and total appliance megajoule load calculated.',
        'Pipe diameter sized to prevent excessive pressure drops.',
        'Manometer pressure drop test performed and recorded.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 5601.1:2023',
      clauseNumber: 'Clause 5.6',
      title: 'Gas Line Piping Support Spacings',
      category: 'Gas',
      summaryText: 'Enforces minimum support structures for gas distribution piping to prevent mechanical stress, line sag, and joint leaks.',
      technicalMetrics: [
        'DN20 Copper Gas Pipe: Max 2.0 m spacing (horizontal), 2.5 m (vertical)',
        'DN25 Steel Gas Pipe: Max 2.5 m spacing (horizontal), 3.0 m (vertical)',
        'Support clips must isolate dissimilar metals to avoid galvanic corrosion',
      ],
      complianceChecklist: [
        'Gas line clip intervals measured.',
        'Rubber-lined or non-conductive clips used on copper pipes touching steel structural members.',
        'Line sag tested under structural weight.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS/NZS 5601.1:2023',
      clauseNumber: 'Clause 6.10.1.1',
      title: 'Gas Cooktop Clearances to Combustibles',
      category: 'Gas',
      summaryText: 'Dictates minimum separation dimensions between gas cooktop burner crowns and overhead extraction fans or cupboards to avert fire hazards.',
      technicalMetrics: [
        'Minimum vertical clearance to Rangehood: 600 mm',
        'Minimum vertical clearance to Exhaust Fan: 750 mm',
        'Minimum horizontal clearance to combustible wall surface: 200 mm',
      ],
      complianceChecklist: [
        'Pitched distance from burner grates to rangehood filters measured.',
        'Lateral clearances verified against splashback walls.',
        'Combustible materials shielded or set back.',
      ],
    ),

    // --- AS 2441 (Fire Hose Reels & Services) ---
    PlumbingStandardClause(
      standardCode: 'AS 2441-2005',
      clauseNumber: 'Clause 4.2',
      title: 'Fire Hose Reel Hydraulic Flow Rates',
      category: 'Fire Services',
      summaryText: 'Specifies water flow and system pressure thresholds for emergency fire hose reel installations in multi-residential or commercial buildings.',
      technicalMetrics: [
        'Minimum flow rate: 0.33 L/s at nozzle outlet',
        'Minimum static pressure: 220 kPa at the reel valve connection',
        'Maximum length of fire hose: 36.0 m',
      ],
      complianceChecklist: [
        'System booster and pump flow rates tested.',
        'Flow pressure gauge attached to fire hose reel test nozzle.',
        'Discharge logged exceeding 0.33 Litres per second.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'AS 2441-2005',
      clauseNumber: 'Clause 2.3',
      title: 'Fire Water Service Backflow Isolation',
      category: 'Fire Services',
      summaryText: 'Requires containment backflow devices at property boundaries for dedicated fire sprinkler and hose reel lines to protect town mains from stagnation.',
      technicalMetrics: [
        'Requires an approved Double Check Valve (DCV) assembly',
        'Must incorporate testable shut-off valves and strainers',
      ],
      complianceChecklist: [
        'DCV rated for fire service flows installed at main boundary.',
        'Annual test schedules established and reported.',
        'By-pass systems configured without illegal connection paths.',
      ],
    ),

    // --- AS 2845.3 (Backflow Testing) ---
    PlumbingStandardClause(
      standardCode: 'AS 2845.3',
      clauseNumber: 'Section 4 - RPZD Valve Tolerances',
      title: 'RPZD Valve Test Tolerances',
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

    // --- QBCC & QLD Statutory Regulations ---
    PlumbingStandardClause(
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      clauseNumber: 'Form 9 Timelines',
      title: 'Form 9 Backflow Prevention Testing',
      category: 'QLD Regulations',
      summaryText: 'Mandates the annual testing registration schedule of high-hazard backflow valves with the local Queensland government council.',
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
    PlumbingStandardClause(
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      clauseNumber: 'Form 1 Permit Applications',
      title: 'Form 1 Permit Work Applications',
      category: 'QLD Regulations',
      summaryText: 'Governs the statutory requirement to apply for local council development permits prior to commencing major plumbing or drainage works in Queensland.',
      technicalMetrics: [
        'Permit approval mandatory prior to initiating work',
        'Applies to all new sanitary drainage, commercial fittings, and major structural changes',
        'Permit documentation requires complete hydraulic plans certified by an engineer',
      ],
      complianceChecklist: [
        'Hydraulic drawings and elevations finalized.',
        'Form 1 drafted and fee paid to local government council.',
        'Permit approval certificate obtained and displayed on site before breaking ground.',
      ],
    ),
    PlumbingStandardClause(
      standardCode: 'QBCC Regulations',
      clauseNumber: 'Form 12 Aspect Certificates',
      title: 'Form 12 Aspect Certificate Lodgements',
      category: 'QLD Regulations',
      summaryText: 'Details requirements for the certifying licensed plumber to sign off on specific components of work (e.g. soil testing, slab drainage) in Queensland.',
      technicalMetrics: [
        'Required for concrete slab pre-pours and under-slab drainage lines',
        'Must be lodged with the building certifier within 5 business days of inspection',
      ],
      complianceChecklist: [
        'Visual inspect and hydrostatic pressure test completed on lines.',
        'Form 12 signed and license number attached.',
        'Submitted to principal building certifier within the statutory 5-day window.',
      ],
    ),
  ];

  /// Builds a combined textual representation of the standards database for AI injection.
  static String buildRegistryText() {
    return clauses.map((c) => c.toPromptString()).join('\n---\n');
  }
}
