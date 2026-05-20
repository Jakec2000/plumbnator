import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
            color: isSelected ? const Color(0xFF00E6FF).withOpacity(0.08) : Colors.white.withOpacity(0.01),
            border: Border.all(color: color.withOpacity(isSelected ? 0.3 : 0.1)),
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

  /// Category filter chips for static library index.
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

  /// Renders the conversational Q&A assistant chat tab.
  Widget _buildChatAssistantTab() {
    final assistantState = ref.watch(assistantProvider);
    return Column(
      children: [
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
        ? const Color(0xFF00E6FF).withOpacity(0.06) 
        : const Color(0xFF0A0F1D).withOpacity(0.6);
    final borderCol = isUser 
        ? const Color(0xFF00E6FF).withOpacity(0.2) 
        : Colors.white.withOpacity(0.04);

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
              child: SelectableText(
                msg.text,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
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
      'What is QLD Form 4 timeline?'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prompts.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(p, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              backgroundColor: const Color(0xFF0A0F1D).withOpacity(0.5),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
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
      borderColor: Colors.white.withOpacity(0.05),
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
        color: const Color(0xFFFF416C).withOpacity(0.1),
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
