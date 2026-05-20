import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';

/// Representation of a regulatory compliance reference model.
class StandardRef {
  final String title;
  final String standardCode;
  final String category;
  final String description;
  final List<String> keyMetrics;

  const StandardRef({
    required this.title,
    required this.standardCode,
    required this.category,
    required this.description,
    required this.keyMetrics,
  });
}

/// A searchable statutory reference library for AS/NZS 3500 and QBCC plumbing rules.
class StandardsLibraryView extends StatefulWidget {
  const StandardsLibraryView({super.key});

  @override
  State<StandardsLibraryView> createState() => _StandardsLibraryViewState();
}

class _StandardsLibraryViewState extends State<StandardsLibraryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  /// Pre-seeded database of Queensland regulatory standards guidelines.
  final List<StandardRef> _standards = const [
    StandardRef(
      title: 'Minimum Drainage Pipe Cover',
      standardCode: 'AS/NZS 3500.2 Clause 4.4',
      category: 'Drainage',
      description: 'Minimum physical cover over underground PVC pipes to prevent damage.',
      keyMetrics: [
        'Domestic Yards (No Traffic): 300 mm',
        'Driveways & Vehicle Pavements: 450 mm',
        'Protected under Concrete Slabs: 100 mm',
      ],
    ),
    StandardRef(
      title: 'Drainage Pipeline Grades',
      standardCode: 'AS/NZS 3500.2 Table 6.1',
      category: 'Drainage',
      description: 'Strict installation grades for sanitary sewer lines to ensure adequate flushing.',
      keyMetrics: [
        'DN80 Sewer Run: Min 2.50% (1:40)',
        'DN100 Sewer Run: Min 1.65% (1:60)',
        'DN150 Sewer Run: Min 1.20% (1:80)',
      ],
    ),
    StandardRef(
      title: 'Static Water Outlet Pressure Cap',
      standardCode: 'AS/NZS 3500.1 Clause 3.4',
      category: 'Water Supply',
      description: 'Maximum allowable static pressure inside residential or commercial buildings.',
      keyMetrics: [
        'Max static outlet pressure: 500 kPa',
        'Remedy if > 500 kPa: Install Pressure Limiting Valve (PLV)',
        'Exceptions: Fire service and dedicated bypass lines',
      ],
    ),
    StandardRef(
      title: 'Tempering Valve Limits',
      standardCode: 'AS/NZS 3500.4 Clause 1.9',
      category: 'Water Supply',
      description: 'Strict outlet temperature ceilings for hot water lines to prevent scalding.',
      keyMetrics: [
        'Sanitary Outlets (Showers/Baths): Max 50°C',
        'Early Education & Aged Care: Max 45°C',
        'Kitchen/Laundry Outlets: Valve bypass allowed (50-60°C)',
      ],
    ),
    StandardRef(
      title: 'QBCC Form 4 Lodgement Timelines',
      standardCode: 'QBCC Notifiable Work Regulation',
      category: 'QBCC / QLD Regs',
      description: 'Statutory deadline to submit Form 4 Notifiable Work lodgements with the QLD Regulator.',
      keyMetrics: [
        'Lodgement Window: Within 10 business days',
        'Trigger: Upon completion of the relevant physical works',
        'Enforcement: Fines apply to unlicensed or late submissions',
      ],
    ),
    StandardRef(
      title: 'Form 9 Backflow Prevention Testing',
      standardCode: 'Plumbing & Drainage Act 2018 (QLD)',
      category: 'QBCC / QLD Regs',
      description: 'Queensland guidelines for commissioning testable backflow prevention devices annually.',
      keyMetrics: [
        'Form 9 Lodgement: Within 10 business days of test',
        'Commissioning: Mandatory annually by licensed backflow tester',
        'Council Registry: Device serial numbers registered locally',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchPanel(),
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 20),
                _buildStandardsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Page title and subtitle block.
  Widget _buildHeader() {
    return Column(
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
    );
  }

  /// Search panel input.
  Widget _buildSearchPanel() {
    return GlassCard(
      borderColor: Colors.white.withOpacity(0.05),
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

  /// Category filter chips.
  Widget _buildCategoryChips() {
    final categories = ['All', 'Drainage', 'Water Supply', 'QBCC / QLD Regs'];

    return Row(
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
    );
  }

  /// Renders filtered standards cards.
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
        borderColor: Colors.white.withOpacity(0.05),
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
                    color: const Color(0xFF00E6FF).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFF00E6FF).withOpacity(0.2)),
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
}
