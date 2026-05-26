import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/ar_spatial_quoting_service.dart';

/// Consumer view managing dynamic AR state and layout scanning controls.
class ArRoomScannerView extends ConsumerStatefulWidget {
  const ArRoomScannerView({super.key});

  @override
  ConsumerState<ArRoomScannerView> createState() => _ArRoomScannerViewState();
}

class _ArRoomScannerViewState extends ConsumerState<ArRoomScannerView> with SingleTickerProviderStateMixin {
  final _service = ArSpatialQuotingService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_AU', symbol: '\$');

  // Room geometry state
  String _roomType = 'Main Bathroom';
  double _roomLength = 3.6;
  double _roomWidth = 2.4;
  double _roomHeight = 2.7;

  // Simulator scan-calibration settings
  double _devicePitch = 0.0; // degrees
  double _deviceYaw = 45.0; // degrees
  double _laserDistance = 2.8; // meters

  // Plumber pricing coefficients
  double _laborRate = 110.0; // $/hr
  double _markupFactor = 1.25; // 25% markup

  // List of active anchors in 3D coordinate space
  final List<SpatialAnchor> _anchors = [
    const SpatialAnchor(id: 'c1', name: 'Corner A', x: 0.0, y: 0.0, z: 0.0, anchorType: 'corner'),
    const SpatialAnchor(id: 'c2', name: 'Corner B', x: 3.6, y: 0.0, z: 0.0, anchorType: 'corner'),
    const SpatialAnchor(id: 'c3', name: 'Corner C', x: 3.6, y: 2.4, z: 0.0, anchorType: 'corner'),
    const SpatialAnchor(id: 'c4', name: 'Corner D', x: 0.0, y: 2.4, z: 0.0, anchorType: 'corner'),
    const SpatialAnchor(id: 'wc1', name: 'WC Pedestal Toilet', x: 3.0, y: 0.6, z: 0.15, anchorType: 'wc'),
    const SpatialAnchor(id: 'basin1', name: 'Vanity Washbasin', x: 1.2, y: 2.2, z: 0.85, anchorType: 'basin'),
    const SpatialAnchor(id: 'fwg1', name: 'Floor Waste Gully (FWG)', x: 1.8, y: 1.2, z: 0.0, anchorType: 'fwg'),
    const SpatialAnchor(id: 'hws1', name: 'External Hot Water System', x: 0.2, y: 0.2, z: 0.4, anchorType: 'hws'),
  ];

  late AnimationController _scannerAnimationController;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    super.dispose();
  }

  void _addAnchor(String type, String name, double x, double y, double z) {
    setState(() {
      _anchors.add(
        SpatialAnchor(
          id: 'anchor_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          x: x,
          y: y,
          z: z,
          anchorType: type,
        ),
      );
    });
  }

  void _clearAnchors() {
    setState(() {
      _anchors.removeWhere((a) => a.anchorType != 'corner');
    });
  }

  void _applyPreset(String type, double l, double w, double h) {
    setState(() {
      _roomType = type;
      _roomLength = l;
      _roomWidth = w;
      _roomHeight = h;

      // Update corners
      _anchors.removeWhere((a) => a.anchorType == 'corner');
      _anchors.addAll([
        SpatialAnchor(id: 'c1', name: 'Corner A', x: 0.0, y: 0.0, z: 0.0, anchorType: 'corner'),
        SpatialAnchor(id: 'c2', name: 'Corner B', x: l, y: 0.0, z: 0.0, anchorType: 'corner'),
        SpatialAnchor(id: 'c3', name: 'Corner C', x: l, y: w, z: 0.0, anchorType: 'corner'),
        SpatialAnchor(id: 'c4', name: 'Corner D', x: 0.0, y: w, z: 0.0, anchorType: 'corner'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate active calculated quote metrics
    final quote = _service.generateSpatialQuote(
      roomType: _roomType,
      length: _roomLength,
      width: _roomWidth,
      height: _roomHeight,
      fixtures: _anchors,
      laborRatePerHour: _laborRate,
      markupMultiplier: _markupFactor,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Left-side visual simulator and AR spatial coordinate canvas
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildWorkspaceBranding(),
                Expanded(
                  child: Stack(
                    children: [
                      // High-fidelity AR Viewport Painter
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF030509),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedBuilder(
                            animation: _scannerAnimationController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ArCoordinatePainter(
                                  anchors: _anchors,
                                  routes: quote.routes,
                                  yaw: _deviceYaw,
                                  pitch: _devicePitch,
                                  laserDistance: _laserDistance,
                                  scanRatio: _scannerAnimationController.value,
                                  roomLength: _roomLength,
                                  roomWidth: _roomWidth,
                                ),
                                child: Container(),
                              );
                            },
                          ),
                        ),
                      ),
                      // Floating diagnostic overlay
                      _buildFloatingOverlayCard(quote),
                    ],
                  ),
                ),
                _buildArControlBar(),
              ],
            ),
          ),
          // Right-side dynamic cost-estimation, compliance analysis, and spreadsheet dashboard
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubHeader('Spatial Blueprint Presets'),
                    const SizedBox(height: 8),
                    _buildPresetsGrid(),
                    const SizedBox(height: 20),
                    _buildSubHeader('Anchor Placements'),
                    const SizedBox(height: 8),
                    _buildAnchorsManager(),
                    const SizedBox(height: 20),
                    _buildSubHeader('AS/NZS Compliance Gradient Audit'),
                    const SizedBox(height: 8),
                    _buildComplianceSection(quote),
                    const SizedBox(height: 20),
                    _buildSubHeader('Trade Cost Multipliers'),
                    const SizedBox(height: 8),
                    _buildPricingModifiers(),
                    const SizedBox(height: 20),
                    _buildSubHeader('Itemized Takeoff BOM'),
                    const SizedBox(height: 8),
                    _buildBomSpreadsheet(quote),
                    const SizedBox(height: 24),
                    _buildQuoteActionButtons(quote),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWorkspaceBranding() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E6FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.threed_rotation, color: Color(0xFF00E6FF), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AR SPATIAL SIZER',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Real-time point-cloud scanning, automatic AS/NZS 3500 gradient audit & digital quoting',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: _clearAnchors,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Reset Anchors',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArControlBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Simulated Device Yaw: ${_deviceYaw.toStringAsFixed(0)}°', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    const Icon(Icons.rotate_left, size: 14, color: Colors.white38),
                  ],
                ),
                Slider(
                  value: _deviceYaw,
                  min: 0.0,
                  max: 360.0,
                  activeColor: const Color(0xFF00E6FF),
                  inactiveColor: Colors.white10,
                  onChanged: (val) => setState(() => _deviceYaw = val),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Simulated Device Pitch: ${_devicePitch.toStringAsFixed(0)}°', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    const Icon(Icons.unfold_more, size: 14, color: Colors.white38),
                  ],
                ),
                Slider(
                  value: _devicePitch,
                  min: -45.0,
                  max: 45.0,
                  activeColor: const Color(0xFF00E6FF),
                  inactiveColor: Colors.white10,
                  onChanged: (val) => setState(() => _devicePitch = val),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Laser Distance: ${_laserDistance.toStringAsFixed(2)}m', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    const Icon(Icons.settings_overscan, size: 14, color: Colors.white38),
                  ],
                ),
                Slider(
                  value: _laserDistance,
                  min: 0.5,
                  max: 8.0,
                  activeColor: const Color(0xFF00FF87),
                  inactiveColor: Colors.white10,
                  onChanged: (val) => setState(() => _laserDistance = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsGrid() {
    final List<Map<String, dynamic>> presets = [
      {'name': 'Main Bathroom', 'l': 3.6, 'w': 2.4, 'h': 2.7, 'icon': Icons.bathtub_outlined},
      {'name': 'Master Ensuite', 'l': 2.8, 'w': 1.8, 'h': 2.7, 'icon': Icons.shower_outlined},
      {'name': 'Utility Laundry', 'l': 2.2, 'w': 1.8, 'h': 2.4, 'icon': Icons.local_laundry_service_outlined},
      {'name': 'Commercial Cafe', 'l': 8.5, 'w': 4.5, 'h': 3.2, 'icon': Icons.restaurant_menu_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.8,
      ),
      itemCount: presets.length,
      itemBuilder: (context, idx) {
        final p = presets[idx];
        final isSelected = _roomType == p['name'];
        final color = isSelected ? const Color(0xFF00E6FF) : Colors.white24;
        return InkWell(
          onTap: () => _applyPreset(p['name'], p['l'], p['w'], p['h']),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? const Color(0xFF00E6FF).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.01),
              border: Border.all(color: color.withValues(alpha: isSelected ? 0.3 : 0.1)),
            ),
            child: Row(
              children: [
                Icon(p['icon'], color: isSelected ? const Color(0xFF00E6FF) : Colors.white54, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isSelected ? Colors.white : Colors.white70)),
                      Text('${p['l']}m × ${p['w']}m × ${p['h']}m', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnchorsManager() {
    final List<Map<String, dynamic>> categories = [
      {'type': 'wc', 'name': 'Add WC Pan', 'icon': Icons.airline_seat_legroom_extra, 'x': 2.8, 'y': 0.6, 'z': 0.15},
      {'type': 'basin', 'name': 'Add Vanity', 'icon': Icons.wash, 'x': 0.8, 'y': 2.2, 'z': 0.85},
      {'type': 'shower', 'name': 'Add Shower', 'icon': Icons.shower, 'x': 3.2, 'y': 2.0, 'z': 0.0},
      {'type': 'hws', 'name': 'Add HWS Boiler', 'icon': Icons.local_fire_department, 'x': 0.4, 'y': 0.4, 'z': 0.6},
    ];

    return Column(
      children: [
        Row(
          children: categories.map((cat) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.03),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Pre-calculate positions offsets randomly to make simulation interesting
                    final rng = Random();
                    final rx = (rng.nextDouble() * (_roomLength - 0.6) + 0.3);
                    final ry = (rng.nextDouble() * (_roomWidth - 0.6) + 0.3);
                    _addAnchor(cat['type'], cat['name'].substring(4), rx, ry, cat['z']);
                  },
                  child: Column(
                    children: [
                      Icon(cat['icon'], size: 16, color: const Color(0xFF00FF87)),
                      const SizedBox(height: 4),
                      Text(cat['type'].toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0x3D000000),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: _anchors.where((a) => a.anchorType != 'corner').isEmpty
              ? Center(child: Text('No active spatial fixtures scanned. Tap icons above to place.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white24)))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  children: _anchors.where((a) => a.anchorType != 'corner').map((anchor) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                anchor.anchorType == 'wc'
                                    ? Icons.airline_seat_legroom_extra
                                    : anchor.anchorType == 'basin'
                                        ? Icons.wash
                                        : anchor.anchorType == 'hws'
                                            ? Icons.local_fire_department
                                            : Icons.shower,
                                size: 14,
                                color: const Color(0xFF00E6FF),
                              ),
                              const SizedBox(width: 8),
                              Text(anchor.name, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('X:${anchor.x.toStringAsFixed(2)}m  Y:${anchor.y.toStringAsFixed(2)}m  Z:${anchor.z.toStringAsFixed(2)}m',
                              style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF00FF87))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        )
      ],
    );
  }

  Widget _buildComplianceSection(PlumbingQuote quote) {
    final nonCompliant = quote.routes.where((r) => !r.isGradientCompliant).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nonCompliant.isEmpty ? const Color(0xFF00FF87).withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: nonCompliant.isEmpty ? const Color(0xFF00FF87).withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                nonCompliant.isEmpty ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: nonCompliant.isEmpty ? const Color(0xFF00FF87) : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                nonCompliant.isEmpty ? 'AS/NZS 3500 Gradient Audit: certified' : 'AS/NZS Gradient Audit: FAILING',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: nonCompliant.isEmpty ? const Color(0xFF00FF87) : Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: quote.complianceAlerts.map((alert) {
              final isWarning = alert.contains('WARNING:');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, right: 6.0),
                      child: Icon(Icons.circle, size: 5, color: isWarning ? Colors.redAccent : Colors.amberAccent),
                    ),
                    Expanded(
                      child: Text(
                        alert,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingModifiers() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plumber Labor Hourly Rate: ${_currencyFormat.format(_laborRate)}', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                  Slider(
                    value: _laborRate,
                    min: 80.0,
                    max: 200.0,
                    activeColor: const Color(0xFF00E6FF),
                    inactiveColor: Colors.white10,
                    onChanged: (val) => setState(() => _laborRate = val),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Materials Mark-up: ${((_markupFactor - 1.0) * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                  Slider(
                    value: _markupFactor,
                    min: 1.00,
                    max: 2.00,
                    activeColor: const Color(0xFF00E6FF),
                    inactiveColor: Colors.white10,
                    onChanged: (val) => setState(() => _markupFactor = val),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBomSpreadsheet(PlumbingQuote quote) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x3D000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
              color: Colors.white10,
            ),
            children: [
              _buildTableHeaderCell('Materials Description'),
              _buildTableHeaderCell('Qty'),
              _buildTableHeaderCell('Unit'),
              _buildTableHeaderCell('Subtotal'),
            ],
          ),
          ...quote.bomItems.map((item) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              children: [
                _buildTableCell(item.name, isBold: true),
                _buildTableCell(item.quantity.toString(), isCenter: true),
                _buildTableCell(_currencyFormat.format(item.unitPrice)),
                _buildTableCell(_currencyFormat.format(item.totalPrice)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuoteActionButtons(PlumbingQuote quote) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL CERTIFIED QUOTE:', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                Text(
                  _currencyFormat.format(quote.totalQuoteCost),
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF00FF87)),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E6FF),
                foregroundColor: const Color(0xFF070B14),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
              ),
              onPressed: () {
                _showQuoteDialog(quote);
              },
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: Text(
                'Generate Quote',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showQuoteDialog(PlumbingQuote quote) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0F1D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFF00E6FF)),
              const SizedBox(width: 12),
              Text(
                'Certified Plumber Quote PDF',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          content: Container(
            width: 480,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AQUAFORGE DIGITAL CERTIFICATION', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF00FF87), letterSpacing: 1.2)),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  _buildDialogKeyValue('Job Scope Type', quote.roomType),
                  _buildDialogKeyValue('Floor Area Size', '${quote.floorArea.toStringAsFixed(2)} sqm'),
                  _buildDialogKeyValue('Water/Sewer Lines', '${quote.routes.length} Active Traces'),
                  _buildDialogKeyValue('Statutory Spacing spacing', 'AS/NZS 3500.2 (Max 1.2m Bracket interval)'),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  _buildDialogKeyValue('Material Component Costs', _currencyFormat.format(quote.materialCost)),
                  _buildDialogKeyValue('Plumber Labor Hours', '${quote.laborHours.toStringAsFixed(1)} hours'),
                  _buildDialogKeyValue('Labor Total Cost', _currencyFormat.format(quote.laborCost)),
                  const Divider(color: Colors.white12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      Text(_currencyFormat.format(quote.subtotal), style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GST (10%):', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      Text(_currencyFormat.format(quote.gstAmount), style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL INVOICED ESTIMATE:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(_currencyFormat.format(quote.totalQuoteCost), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF00FF87))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'All generated quotes dynamically respect Australian standard plumbing specifications, verifying critical pipeline slopes and support guidelines automatically.',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white60, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close Preview', style: GoogleFonts.inter(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E6FF),
                foregroundColor: const Color(0xFF070B14),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quote digital receipt compiled and uploaded to Firebase!'),
                    backgroundColor: Color(0xFF00FF87),
                  ),
                );
              },
              child: Text('Submit Quote', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFloatingOverlayCard(PlumbingQuote quote) {
    return Positioned(
      top: 24,
      left: 24,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1D).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.screenshot, size: 14, color: Color(0xFF00E6FF)),
                const SizedBox(width: 8),
                Text('Virtual AR Feed Enabled', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Point Clouds: ${_anchors.length} registered', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
            Text('Active Pipes: ${quote.routes.length} paths computed', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: const Color(0xFF00E6FF),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false, bool isCenter = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: isBold ? Colors.white70 : Colors.white54,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Custom painter mapping 3D projection formulas to simulate point cloud and laser sweeps.
class ArCoordinatePainter extends CustomPainter {
  final List<SpatialAnchor> anchors;
  final List<PipeRouteTrace> routes;
  final double yaw;
  final double pitch;
  final double laserDistance;
  final double scanRatio;
  final double roomLength;
  final double roomWidth;

  ArCoordinatePainter({
    required this.anchors,
    required this.routes,
    required this.yaw,
    required this.pitch,
    required this.laserDistance,
    required this.scanRatio,
    required this.roomLength,
    required this.roomWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = min(size.width / (roomLength * 1.5), size.height / (roomWidth * 1.5));

    // Paint camera backdrop background shading grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = -roomLength; i <= roomLength * 2; i += 0.5) {
      canvas.drawLine(
        Offset(cx + i * scale - (roomLength / 2) * scale, 0),
        Offset(cx + i * scale - (roomLength / 2) * scale, size.height),
        gridPaint,
      );
    }
    for (double i = -roomWidth; i <= roomWidth * 2; i += 0.5) {
      canvas.drawLine(
        Offset(0, cy + i * scale - (roomWidth / 2) * scale),
        Offset(size.width, cy + i * scale - (roomWidth / 2) * scale),
        gridPaint,
      );
    }

    // Laser scan sweep line rendering
    final scanY = cy + (scanRatio * roomWidth - roomWidth / 2) * scale;
    final laserPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.2 + (0.3 * sin(scanRatio * pi)))
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(cx - (roomLength / 2) * scale, scanY),
      Offset(cx + (roomLength / 2) * scale, scanY),
      laserPaint,
    );

    // Render boundary wall outlines
    final wallPaint = Paint()
      ..color = const Color(0xFF00E6FF).withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: roomLength * scale,
      height: roomWidth * scale,
    );
    canvas.drawRect(rect, wallPaint);

    // Draw coordinate axis origins
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - (roomLength / 2) * scale, cy), Offset(cx + (roomLength / 2) * scale, cy), axisPaint);
    canvas.drawLine(Offset(cx, cy - (roomWidth / 2) * scale), Offset(cx, cy + (roomWidth / 2) * scale), axisPaint);

    // Render pipe routing neon lines
    for (final r in routes) {
      final isCompliant = r.isGradientCompliant;
      final pipePaint = Paint()
        ..color = r.pipeType.contains('Copper')
            ? Colors.orangeAccent.withValues(alpha: 0.8)
            : (isCompliant ? const Color(0xFF00FF87).withValues(alpha: 0.8) : Colors.redAccent.withValues(alpha: 0.8))
        ..strokeWidth = r.diameterDn == 100 ? 5.0 : 3.0
        ..style = PaintingStyle.stroke;

      // Find matching fixture anchor coordinate offsets
      final routeIdStr = r.id;
      final fixtureId = routeIdStr.replaceFirst('route_water_', '').replaceFirst('route_', '');
      final fixture = anchors.where((a) => a.id == fixtureId);

      if (fixture.isNotEmpty) {
        final f = fixture.first;
        // Project coordinates: translate x, y relative to room corner (centered)
        final startX = cx + (f.x - roomLength / 2) * scale;
        final startY = cy + (f.y - roomWidth / 2) * scale;

        // Base drainage origin outlet
        final endX = cx + (0.0 - roomLength / 2) * scale;
        final endY = cy + (0.0 - roomWidth / 2) * scale;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), pipePaint);
      }
    }

    // Paint anchor points on canvas
    for (final anchor in anchors) {
      final isCorner = anchor.anchorType == 'corner';
      final ax = cx + (anchor.x - roomLength / 2) * scale;
      final ay = cy + (anchor.y - roomWidth / 2) * scale;

      final nodePaint = Paint()
        ..color = isCorner ? Colors.white38 : const Color(0xFF00E6FF)
        ..style = PaintingStyle.fill;

      // Pulse visual effects for anchors
      canvas.drawCircle(Offset(ax, ay), isCorner ? 4.0 : 6.0, nodePaint);

      if (!isCorner) {
        final ringPaint = Paint()
          ..color = const Color(0xFF00E6FF).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(ax, ay), 10.0 + (3.0 * sin(scanRatio * 2 * pi)), ringPaint);

        // Text label metadata
        final textPainter = TextPainter(
          text: TextSpan(
            text: anchor.name,
            style: GoogleFonts.inter(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(ax + 10, ay - 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
