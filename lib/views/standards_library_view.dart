import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/glass_card.dart';
import '../providers/state_providers.dart';

/// Representation of a regulatory compliance reference model.
class StandardRef {
  /// The title of the standard guidelines.
  final String title;

  /// The standard identifier or code clause.
  final String standardCode;

  /// The category grouping.
  final String category;

  /// Brief description of the standard purpose.
  final String description;

  /// List of essential tolerance metrics.
  final List<String> keyMetrics;

  /// Creates a [StandardRef] instance.
  const StandardRef({
    required this.title,
    required this.standardCode,
    required this.category,
    required this.description,
    required this.keyMetrics,
  });
}

/// A searchable statutory reference library with integrated AI Standards Q&A Assistant.
class StandardsLibraryView extends ConsumerStatefulWidget {
  /// Creates a [StandardsLibraryView] instance.
  const StandardsLibraryView({super.key});

  @override
  ConsumerState<StandardsLibraryView> createState() => _StandardsLibraryViewState();
}

class _StandardsLibraryViewState extends ConsumerState<StandardsLibraryView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _assistantInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  String _selectedCategory = 'All';
  String _searchQuery = '';
  int _activeTab = 0; // 0 for Index, 1 for AI Assistant

  /// Pre-seeded database of Queensland regulatory standards guidelines.
  final List<StandardRef> _standards = const [
    // --- Drainage ---
    StandardRef(
      title: 'Minimum Drainage Pipe Cover',
      standardCode: 'AS/NZS 3500.2 Clause 4.4',
      category: 'Drainage',
      description: 'Minimum physical soil cover depth over underground PVC lines to resist traffic damage.',
      keyMetrics: [
        'Domestic Yards (No Traffic): 300 mm minimum',
        'Driveways & Vehicle Pavements: 450 mm minimum',
        'Heavy Roadways (Unpaved): 750 mm minimum',
        'Protected under Concrete Slabs: 100 mm minimum',
      ],
    ),
    StandardRef(
      title: 'Drainage Pipeline Grades',
      standardCode: 'AS/NZS 3500.2 Table 6.1',
      category: 'Drainage',
      description: 'Strict installation fall grades for sanitary sewer lines to secure self-cleansing velocities.',
      keyMetrics: [
        'DN80 Sewer Run: Min grade 2.50% (1:40)',
        'DN100 Sewer Run: Min grade 1.65% (1:60)',
        'DN150 Sewer Run: Min grade 1.20% (1:80)',
      ],
    ),
    StandardRef(
      title: 'Sanitary Stack Vent Heights',
      standardCode: 'AS/NZS 3500.2 Clause 6.5',
      category: 'Drainage',
      description: 'Height limits for sanitary vent terminals above roofs and away from openable windows.',
      keyMetrics: [
        'Termination above roof line: 150 mm minimum',
        'Clearance to openable windows/doors: 3.0 m minimum unless 600mm above window head',
      ],
    ),
    StandardRef(
      title: 'PVC Clip Spacing Limits',
      standardCode: 'AS/NZS 3500.2 Table 4.3',
      category: 'Drainage',
      description: 'Maximum allowable spacing for support brackets to prevent PVC line sagging.',
      keyMetrics: [
        'DN40 to DN50 PVC: Max 1.2 m spacing',
        'DN65 to DN100 PVC: Max 1.5 m spacing',
        'DN150 PVC: Max 2.0 m spacing',
        'Vertical stacks: Max 2.5 m spacing',
      ],
    ),
    StandardRef(
      title: 'Fixture Discharge Pipe Sizing',
      standardCode: 'AS/NZS 3500.2 Clause 4.6.2',
      category: 'Drainage',
      description: 'Minimum internal sizing for fixture branches based on fixture unit (FU) discharge.',
      keyMetrics: [
        'Water Closet (Toilet): DN100 minimum size',
        'Kitchen Sinks & Laundry Troughs: DN50 minimum size',
        'Hand Basin: DN40 minimum size',
      ],
    ),
    StandardRef(
      title: 'Trench Shoring Safety Limits',
      standardCode: 'AS/NZS 3500.2 Clause 3.4',
      category: 'Drainage',
      description: 'Mandatory structural shoring requirements for sewer trench excavations.',
      keyMetrics: [
        'Shoring Trigger Depth: > 1.5 m vertical trench face',
        'Trench Width: Min 200 mm wider than pipe outer diameter',
        'Soil Spoils: Stacked min 1.0 m clear of trench edge',
      ],
    ),
    StandardRef(
      title: 'Boundary Trap Requirements',
      standardCode: 'AS/NZS 3500.2 Clause 4.7.1',
      category: 'Drainage',
      description: 'Isolating property sewer lines from public mains to arrest gas entering homes.',
      keyMetrics: [
        'Location: Must sit inside property near boundary line',
        'Riser Shaft: Sealed, gas-tight inspection shaft to surface',
        'Fresh Air Inlet: Fitted with cowl where council mandated',
      ],
    ),
    StandardRef(
      title: 'Inspection Opening (IO) Intervals',
      standardCode: 'AS/NZS 3500.2 Clause 13.2',
      category: 'Drainage',
      description: 'Maximum spacing between clear-out openings on straight sewer pipeline runs.',
      keyMetrics: [
        'Straight runs: Max 30 m spacing between IO access points',
        'Direction changes: Mandatory if angle exceeds 45 degrees',
        'Stack points: Mandatory at bases of all soil and waste stacks',
      ],
    ),
    StandardRef(
      title: 'Drainage Junction Sweeps',
      standardCode: 'AS/NZS 3500.2 Clause 4.8.4',
      category: 'Drainage',
      description: 'Prohibiting sharp square branches to avoid line obstructions and plumbing blockages.',
      keyMetrics: [
        'Permissible fittings: Sweep junctions or 45-degree wyes',
        'Prohibited: 90-degree square tee junctions on sanitary drains',
      ],
    ),

    // --- Water Supply ---
    StandardRef(
      title: 'Static Water Outlet Pressure Cap',
      standardCode: 'AS/NZS 3500.1 Clause 3.4',
      category: 'Water Supply',
      description: 'Maximum static water pressure at any outlet inside buildings to protect valves.',
      keyMetrics: [
        'Max static outlet pressure: 500 kPa',
        'Remedy: Install pressure limiting valve (PLV) at boundary',
        'Exemptions: Dedicated fire service runs',
      ],
    ),
    StandardRef(
      title: 'Pipe Lagging & Insulation',
      standardCode: 'AS/NZS 3500.1 Clause 5.2',
      category: 'Water Supply',
      description: 'Insulation bounds for water piping to stop heat loss, freezing, or condensation.',
      keyMetrics: [
        'DN20+ Copper Pipes: Lagging required',
        'Insulation Value: R-0.3 to R-0.6 minimum',
        'Frost Regions: 9mm thick protection required',
      ],
    ),
    StandardRef(
      title: 'Flow Velocity Speed Caps',
      standardCode: 'AS/NZS 3500.1 Clause 3.3.2',
      category: 'Water Supply',
      description: 'Velocity bounds inside pipelines to prevent copper erosion and acoustic noise.',
      keyMetrics: [
        'Copper pipelines: Max velocity 2.0 m/s',
        'Plastic pipelines (PEX/Poly): Max velocity 3.0 m/s',
      ],
    ),
    StandardRef(
      title: 'Water Meter Connection Spacing',
      standardCode: 'AS/NZS 3500.1 Clause 11.2',
      category: 'Water Supply',
      description: 'Accessibility and spacing limits for sub-meters and property boundaries.',
      keyMetrics: [
        'Meter Ground Clearance: Min 150 mm height',
        'Sub-meter Spacing: Min 150 mm clear space between parallel meters',
        'Boundary Setback: Max 1.0 m distance from front boundary line',
      ],
    ),

    // --- Backflow ---
    StandardRef(
      title: 'Backflow Hazard Device Ratings',
      standardCode: 'AS/NZS 3500.1 Clause 14.2.3',
      category: 'Backflow',
      description: 'Device matching logic based on cross-connection hazard threat to potable mains.',
      keyMetrics: [
        'High Hazard: Reduced Pressure Zone Device (RPZD) or air gap',
        'Medium Hazard: Double Check Valve (DCV) assembly',
        'Low Hazard: Dual Check Valve or non-return valves',
      ],
    ),
    StandardRef(
      title: 'RPZD Valve Test Tolerances',
      standardCode: 'AS 2845.3 Section 4',
      category: 'Backflow',
      description: 'Minimum hydraulic pressure differentials required during annual backflow certification.',
      keyMetrics: [
        'First Check Valve: Min 35 kPa drop across seating',
        'Relief Port Opening: Must open at or before 14 kPa point',
        'Second Check Valve: Min 7 kPa drop across seating',
      ],
    ),

    // --- Stormwater ---
    StandardRef(
      title: 'Stormwater Pipe Sizing',
      standardCode: 'AS/NZS 3500.3 Table 5.2',
      category: 'Stormwater',
      description: 'Minimum pipe dimensions for roof and yard runoff based on catchment metrics.',
      keyMetrics: [
        'DN90 Max Catchment: 60 m² (at 1:100 grade)',
        'DN100 Max Catchment: 130 m² (at 1:100 grade)',
        'ARI Compliance: Must manage 1-in-100-year rainfall event',
      ],
    ),
    StandardRef(
      title: 'Box Gutter Dimensions',
      standardCode: 'AS/NZS 3500.3 Table 3.1',
      category: 'Stormwater',
      description: 'Design requirements for box gutters to stop internal overflowing.',
      keyMetrics: [
        'Minimum width: 200 mm width tray',
        'Minimum grade: 1:200 (0.50% fall)',
        'Safety: Overflow sumps or side rainheads mandatory',
      ],
    ),
    StandardRef(
      title: 'Downpipe Layout Spacings',
      standardCode: 'AS/NZS 3500.3 Clause 8.2',
      category: 'Stormwater',
      description: 'Spacing limits for downpipe placement to ensure fast gutter drainage.',
      keyMetrics: [
        'Max Gutter length per downpipe: 12.0 m spacing',
        'Cross-sectional sizing: Custom mapped to rain intensity',
      ],
    ),
    StandardRef(
      title: 'Rainwater Tank Overflow Outlets',
      standardCode: 'AS/NZS 3500.3 Clause 3.5',
      category: 'Stormwater',
      description: 'Plumbing limits for rainwater vessel overflow pipes to avert localized erosion.',
      keyMetrics: [
        'Overflow Outlet Pipe: Min matching diameter of inlet line',
        'Potable Feed Top-up: Isolated using registered air gap',
      ],
    ),

    // --- Gas ---
    StandardRef(
      title: 'Gas Installation Ventilation',
      standardCode: 'AS/NZS 5601.1 Clause 6.3',
      category: 'Gas',
      description: 'Fresh combustion ventilation criteria for gas appliances in tight zones.',
      keyMetrics: [
        'Type A non-flued: 10 cm² free area per MJ/hr rating',
        'Grid openings: Two separate ducts (one high, one low)',
      ],
    ),
    StandardRef(
      title: 'Gas Pipe Design Pressure Drop',
      standardCode: 'AS/NZS 5601.1 Table 4.1',
      category: 'Gas',
      description: 'Maximum pressure drop limits inside gas piping to protect burner flame profiles.',
      keyMetrics: [
        'Natural Gas (NG): Max 0.075 kPa drop',
        'LPG systems: Max 0.25 kPa drop',
      ],
    ),
    StandardRef(
      title: 'Gas Pipe Clip Spacing',
      standardCode: 'AS/NZS 5601.1 Clause 5.6',
      category: 'Gas',
      description: 'Maximum spacing for gas lines to prevent mechanical line stresses.',
      keyMetrics: [
        'DN20 Copper Gas Pipe: Max 2.0 m horizontal / 2.5 m vertical',
        'DN25 Steel Gas Pipe: Max 2.5 m horizontal / 3.0 m vertical',
      ],
    ),
    StandardRef(
      title: 'Gas Cooktop Fire Clearances',
      standardCode: 'AS/NZS 5601.1 Clause 6.10.1.1',
      category: 'Gas',
      description: 'Safe vertical distances from burner crowns to combustible cupboards.',
      keyMetrics: [
        'Vertical to Rangehood: 600 mm minimum clearance',
        'Vertical to Exhaust Fan: 750 mm minimum clearance',
        'Horizontal to Combustibles: 200 mm minimum clearance',
      ],
    ),

    // --- Solar / Hot Water ---
    StandardRef(
      title: 'Tempering Valve Limits',
      standardCode: 'AS/NZS 3500.4 Clause 1.9',
      category: 'Solar / Hot Water',
      description: 'Maximum temperature limits for personal hygiene outlets to stop scalding.',
      keyMetrics: [
        'Sanitary Outlets (Showers/Baths): 50°C maximum',
        'Aged Care & Child Care facilities: 45°C maximum',
        'Kitchen/Laundry Outlets: 60°C bypass permitted',
      ],
    ),
    StandardRef(
      title: 'Legionella Storage Set-point',
      standardCode: 'AS/NZS 3500.4 Clause 4.2',
      category: 'Solar / Hot Water',
      description: 'Core storage temperatures to arrest bacterial growth in cylinders.',
      keyMetrics: [
        'Minimum tank core temperature: 60°C set-point',
      ],
    ),
    StandardRef(
      title: 'Solar Collector Mountings',
      standardCode: 'AS/NZS 3500.4 Clause 7.2',
      category: 'Solar / Hot Water',
      description: 'Directives for secure installation of solar thermal units on pitched roofs.',
      keyMetrics: [
        'Mount certification: Compliant with AS 1170.2 wind load checks',
        'Expansion Valve (ECV): Cold water expansion release valve mandatory',
      ],
    ),
    StandardRef(
      title: 'Thermal siphon Heat Traps',
      standardCode: 'AS/NZS 3500.4 Clause 8.2.2',
      category: 'Solar / Hot Water',
      description: 'Mandatory heat traps to prevent passive heat rising into cold inlets.',
      keyMetrics: [
        'Vertical drop depth: Min 150 mm loop drop',
        'Applications: Both hot inlet and cold outlet pipes',
      ],
    ),
    StandardRef(
      title: 'Heater Safe Tray Rules',
      standardCode: 'AS/NZS 3500.4 Clause 4.6',
      category: 'Solar / Hot Water',
      description: 'Overflow trays beneath units placed in ceiling spaces or cabinets.',
      keyMetrics: [
        'Tray Drainage sizing: DN50 minimum diameter',
        'Exit point: Routed to a conspicuous external location',
      ],
    ),
    StandardRef(
      title: 'PTRV Copper Relief Outlets',
      standardCode: 'AS/NZS 3500.4 Clause 5.12',
      category: 'Solar / Hot Water',
      description: 'Safe drainage lines for heater relief valves to avoid steam accidents.',
      keyMetrics: [
        'Material type: Strictly copper piping (no plastics)',
        'Pipe Sizing: DN15 or DN20 sizing',
        'Discharge: Facing downwards above gully or onto lawns',
      ],
    ),

    // --- Fire Services ---
    StandardRef(
      title: 'Fire Reel Flow Rate',
      standardCode: 'AS 2441-2005 Clause 4.2',
      category: 'Fire Services',
      description: 'Minimum hydraulic criteria for building emergency fire hose reels.',
      keyMetrics: [
        'Flow rate: Min 0.33 L/s at nozzle outlet',
        'Static Pressure: Min 220 kPa at connection point',
        'Hose length: Max 36.0 m',
      ],
    ),
    StandardRef(
      title: 'Fire Mains Containment',
      standardCode: 'AS 2441-2005 Clause 2.3',
      category: 'Fire Services',
      description: 'Mandatory boundary backflow prevention for dedicated fire services.',
      keyMetrics: [
        'Required device: Testable Double Check Valve (DCV) assembly',
        'Accessories: Dual shut-off isolating valves and strainers',
      ],
    ),

    // --- QBCC / QLD Regs ---
    StandardRef(
      title: 'Form 9 Backflow Certification',
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      category: 'QBCC / QLD Regs',
      description: 'Queensland guidelines for annual testing of high-hazard backflow check valves.',
      keyMetrics: [
        'Form 9 lodgement: Within 10 business days of test completion',
        'Testing interval: Every 12 months by an endorsed backflow technician',
      ],
    ),
    StandardRef(
      title: 'QBCC Form 4 Submission Timelines',
      standardCode: 'QBCC Regulations',
      category: 'QBCC / QLD Regs',
      description: 'Statutory deadline to submit notifiable work certificates with the commission.',
      keyMetrics: [
        'Lodgement Window: Within 10 business days',
        'Requirements: WaterMark materials list and client address details',
      ],
    ),
    StandardRef(
      title: 'Form 1 Permit Applications',
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      category: 'QBCC / QLD Regs',
      description: 'Council permit authorizations required before launching commercial or major works.',
      keyMetrics: [
        'Approval: Mandated BEFORE breaking ground or installing drains',
        'Documents: Architectural floorplans and engineer calculations',
      ],
    ),
    StandardRef(
      title: 'Form 12 Aspect Sign-offs',
      standardCode: 'QBCC Regulations',
      category: 'QBCC / QLD Regs',
      description: 'Aspect sign-off certificates required for structural under-slab works.',
      keyMetrics: [
        'Lodgement: Within 5 business days of inspection',
        'Applies to: Concrete slab pre-pours and property boundary connections',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _assistantInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTabSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _activeTab == 0
                ? SingleChildScrollView(child: _buildStandardsIndexTab())
                : _buildChatAssistantTab(),
          ),
        ],
      ),
    );
  }

  /// Page title and subtitle block.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STANDARDS REFERENCE LIBRARY',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Searchable index of AS/NZS 3500 & Queensland statutory plumbing standards',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        if (_activeTab == 1)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white54, size: 22),
            tooltip: 'Clear Chat History',
            onPressed: () {
              ref.read(assistantProvider.notifier).clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation history cleared.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Tab selector switching between Search Index and AI Q&A Assistant.
  Widget _buildTabSelector() {
    return Row(
      children: [
        _buildTabButton(0, 'Regulatory Index', Icons.list_alt),
        const SizedBox(width: 12),
        _buildTabButton(1, 'AI Standards Assistant', Icons.psychology),
      ],
    );
  }

  /// Helper rendering individual tab selection buttons.
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    final color = isSelected ? const Color(0xFF00E6FF) : Colors.white24;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? const Color(0xFF00E6FF).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.01),
            border: Border.all(color: color.withValues(alpha: isSelected ? 0.3 : 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF00E6FF) : Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Combines sizer filter chips and cards into the static index tab.
  Widget _buildStandardsIndexTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchPanel(),
        const SizedBox(height: 16),
        _buildCategoryChips(),
        const SizedBox(height: 20),
        _buildStandardsList(),
      ],
    );
  }

  /// Standard search panel input.
  Widget _buildSearchPanel() {
    return GlassCard(
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search clearance codes, temperatures, grades or timelines...',
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00E6FF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
      ),
    );
  }

  /// Category filter chips for static library index.
  Widget _buildCategoryChips() {
    final categories = ['All', 'Drainage', 'Water Supply', 'Backflow', 'QBCC / QLD Regs', 'Stormwater', 'Gas', 'Solar / Hot Water', 'Fire Services'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF00E6FF),
            backgroundColor: const Color(0xFF0A0F1D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategory = cat;
                });
              }
            },
          ),
        );
      }).toList(),
    ),
    );
  }

  /// Renders filtered list of standards.
  Widget _buildStandardsList() {
    final filtered = _standards.where((s) {
      final matchesCategory = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesSearch = s.title.toLowerCase().contains(_searchQuery) ||
          s.standardCode.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery) ||
          s.keyMetrics.any((metric) => metric.toLowerCase().contains(_searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No regulatory standards found matching your filter criteria.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white24),
        ),
      );
    }

    return Column(
      children: filtered.map((s) => _buildStandardCard(s)).toList(),
    );
  }

  /// Renders a single standard reference card.
  Widget _buildStandardCard(StandardRef s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        borderColor: Colors.white.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.title,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFF00E6FF).withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    s.standardCode,
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E6FF), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              s.description,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
            const Divider(color: Colors.white12, height: 24),
            ...s.keyMetrics.map((metric) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: Color(0xFF00FF87), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        metric,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Model selector allowing the plumber to choose their AI engine.
  Widget _buildModelSelector(AssistantState state) {
    final models = const ['Grok 4.3', 'Gemini 1.5 Flash', 'GPT-4o'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_suggest_outlined, color: Colors.white30, size: 14),
          const SizedBox(width: 8),
          Text(
            'Brain Engine:',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: models.map((m) {
                  final isSelected = state.selectedModel == m;
                  Color activeColor = const Color(0xFF00E6FF);
                  if (m.contains('Grok')) activeColor = const Color(0xFF00FF87);
                  if (m.contains('GPT')) activeColor = const Color(0xFF00FFCC);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () {
                        ref.read(assistantProvider.notifier).selectModel(m);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? activeColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activeColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              m,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders the conversational Q&A assistant chat tab.
  Widget _buildChatAssistantTab() {
    final assistantState = ref.watch(assistantProvider);
    return Column(
      children: [
        _buildModelSelector(assistantState),
        const SizedBox(height: 10),
        Expanded(child: _buildChatMessageList(assistantState)),
        if (assistantState.error != null) _buildAssistantError(assistantState.error!),
        const SizedBox(height: 8),
        _buildQuickPromptChips(assistantState),
        const SizedBox(height: 8),
        _buildChatInput(assistantState),
      ],
    );
  }

  /// Scrollable container rendering dialogue message tiles.
  Widget _buildChatMessageList(AssistantState state) {
    return ListView.builder(
      controller: _chatScrollController,
      itemCount: state.messages.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (ctx, idx) {
        return _buildChatMessageTile(state.messages[idx]);
      },
    );
  }

  /// Renders a single conversation chat bubble.
  Widget _buildChatMessageTile(AssistantMessage msg) {
    final isUser = msg.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final cardBg = isUser 
        ? const Color(0xFF00E6FF).withValues(alpha: 0.06) 
        : const Color(0xFF0A0F1D).withValues(alpha: 0.6);
    final borderCol = isUser 
        ? const Color(0xFF00E6FF).withValues(alpha: 0.2) 
        : Colors.white.withValues(alpha: 0.04);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isUser ? Icons.person_outline : Icons.psychology_outlined,
                  color: isUser ? const Color(0xFF00FF87) : const Color(0xFF00E6FF), size: 14),
              const SizedBox(width: 6),
              Text(
                isUser ? 'YOU (Licensed Plumber)' : 'AI COMPLIANCE ASSISTANT',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundGradient: [cardBg, cardBg],
            borderColor: borderCol,
            borderRadius: 12,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: MarkdownBody(
                data: msg.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                  strong: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  code: GoogleFonts.sourceCodePro(
                    fontSize: 12,
                    color: const Color(0xFF00FFCC),
                    backgroundColor: Colors.black26,
                  ),
                  h3: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E6FF),
                  ),
                  h4: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  listBullet: const TextStyle(color: Color(0xFF00E6FF)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive quick-suggestion chips that submit standard questions instantly.
  Widget _buildQuickPromptChips(AssistantState state) {
    final prompts = [
      'What is PVC cover limit?',
      'Tell me static water limits',
      'What is QLD Form 4 timeline?',
      'DN100 drainage grade?',
      'Tempering valve limits?',
      'Stormwater pipe sizing?',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prompts.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(p, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              backgroundColor: const Color(0xFF0A0F1D).withValues(alpha: 0.5),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: state.isLoading 
                  ? null 
                  : () => _submitQuestion(p),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Glassmorphic chat input area with send/loading indications.
  Widget _buildChatInput(AssistantState state) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      borderColor: Colors.white.withValues(alpha: 0.05),
      borderRadius: 12,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _assistantInputController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Ask about AS/NZS 3500 gradients, cover, tempering...',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 12.5),
                border: InputBorder.none,
              ),
              onSubmitted: state.isLoading ? null : (val) => _submitQuestion(val),
            ),
          ),
          const SizedBox(width: 8),
          state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E6FF)),
                )
              : IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF00E6FF), size: 20),
                  onPressed: () => _submitQuestion(_assistantInputController.text),
                ),
        ],
      ),
    );
  }

  /// Submission handler routing inputs to Riverpod and auto-scrolling to the bottom.
  void _submitQuestion(String question) {
    final text = question.trim();
    if (text.isEmpty) return;
    _assistantInputController.clear();
    ref.read(assistantProvider.notifier).sendQuestion(text);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Renders customized assistant error logs.
  Widget _buildAssistantError(String err) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF416C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF416C), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              err,
              style: GoogleFonts.inter(color: const Color(0xFFFF416C), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
