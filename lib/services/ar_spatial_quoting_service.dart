import 'dart:math';

/// Represents a distinct 3D coordinate point captured in the AR scanning workspace.
class SpatialAnchor {
  final String id;
  final String name;
  final double x; // relative meters along horizontal X axis
  final double y; // relative meters along horizontal Y axis
  final double z; // height in meters along vertical Z axis
  final String anchorType; // 'corner', 'wc', 'basin', 'shower', 'fwg', 'hws'

  const SpatialAnchor({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.z,
    required this.anchorType,
  });

  /// Calculates the 3D Euclidean distance to another spatial anchor.
  double distanceTo(SpatialAnchor other) {
    return sqrt(
      pow(x - other.x, 2) + pow(y - other.y, 2) + pow(z - other.z, 2),
    );
  }

  /// Calculates the 2D horizontal projection distance.
  double horizontalDistanceTo(SpatialAnchor other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
}

/// Represents a designed pipe trace between fixtures calculated in 3D coordinate space.
class PipeRouteTrace {
  final String id;
  final String label;
  final String pipeType; // 'PVC Drainage', 'Copper Water Hot', 'Copper Water Cold'
  final double diameterDn; // DN size in mm (e.g., 100, 50, 20, 15)
  final double totalLength; // physical length in meters
  final double slopePercent; // calculated vertical drop percentage
  final int requiredClips; // support brackets calculated per AS/NZS 3500.2 rules
  final bool isGradientCompliant;
  final String standardCitation;

  const PipeRouteTrace({
    required this.id,
    required this.label,
    required this.pipeType,
    required this.diameterDn,
    required this.totalLength,
    required this.slopePercent,
    required this.requiredClips,
    required this.isGradientCompliant,
    required this.standardCitation,
  });
}

/// Represents an itemized line entry within the generated digital Bill of Materials.
class BomItem {
  final String name;
  final String category; // 'Pipe', 'Fitting', 'Bracket', 'Consumable'
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const BomItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

/// Complete compliance-audited commercial quote model generated via AR Room scan data.
class PlumbingQuote {
  final String id;
  final String roomType; // e.g., 'Main Bathroom', 'Commercial Kitchen'
  final double roomLength;
  final double roomWidth;
  final double ceilingHeight;
  final double floorArea;
  final double wallSurfaceArea;
  final List<PipeRouteTrace> routes;
  final List<BomItem> bomItems;
  final double laborHours;
  final double laborCost;
  final double materialCost;
  final double subtotal;
  final double markupPercent;
  final double gstAmount;
  final double totalQuoteCost;
  final List<String> complianceAlerts;

  const PlumbingQuote({
    required this.id,
    required this.roomType,
    required this.roomLength,
    required this.roomWidth,
    required this.ceilingHeight,
    required this.floorArea,
    required this.wallSurfaceArea,
    required this.routes,
    required this.bomItems,
    required this.laborHours,
    required this.laborCost,
    required this.materialCost,
    required this.subtotal,
    required this.markupPercent,
    required this.gstAmount,
    required this.totalQuoteCost,
    required this.complianceAlerts,
  });
}

/// Core spatial analysis engine executing geometry math and AS/NZS 3500.2 sizing limits.
class ArSpatialQuotingService {
  /// Singleton access interface.
  static final ArSpatialQuotingService _instance = ArSpatialQuotingService._internal();
  factory ArSpatialQuotingService() => _instance;
  ArSpatialQuotingService._internal();

  /// Calculates room layout parameters and generates an itemized, compliant quotation from captured anchors.
  PlumbingQuote generateSpatialQuote({
    required String roomType,
    required double length,
    required double width,
    required double height,
    required List<SpatialAnchor> fixtures,
    double laborRatePerHour = 110.0, // Brisbane standard plumber contractor rate
    double markupMultiplier = 1.25, // default 25% materials markup
  }) {
    final floorArea = length * width;
    final wallSurfaceArea = 2 * (length + width) * height;

    // Filter fixture anchors vs corners
    final fixtureAnchors = fixtures.where((f) => f.anchorType != 'corner').toList();
    final List<PipeRouteTrace> computedRoutes = [];
    final List<String> alerts = [];

    // Base sewer connection point (relative origin x=0, y=0, z=0)
    final sewerOutfall = SpatialAnchor(
      id: 'sewer_origin',
      name: 'Main Sewer Outfall Connection',
      x: 0.0,
      y: 0.0,
      z: -0.2, // placed 200mm below slab level
      anchorType: 'drain',
    );

    // Compute route lines from each active fixture back to main drain connection
    for (final fixture in fixtureAnchors) {
      double dn = 50;
      String citation = 'AS/NZS 3500.2 Clause 3.3';
      double minSlope = 2.0; // standard 1 in 50 gradient (2.0%) for smaller waste lines

      if (fixture.anchorType == 'wc') {
        dn = 100;
        citation = 'AS/NZS 3500.2 Clause 3.2.1';
        minSlope = 1.65; // standard 1 in 60 gradient (1.65%) for DN100 soil pipes
      } else if (fixture.anchorType == 'fwg') {
        dn = 80;
        minSlope = 1.65;
        citation = 'AS/NZS 3500.2 Table 3.2';
      }

      final horizDistance = fixture.horizontalDistanceTo(sewerOutfall);
      final totalLen = fixture.distanceTo(sewerOutfall);

      // Verify the vertical slope ratio (relative fall)
      final verticalDrop = fixture.z - sewerOutfall.z;
      final calculatedSlope = horizDistance > 0 ? (verticalDrop / horizDistance) * 100 : 0.0;
      final isSlopeCompliant = calculatedSlope >= minSlope;

      if (!isSlopeCompliant && horizDistance > 0) {
        alerts.add(
          'WARNING: ${fixture.name} drain gradient is ${calculatedSlope.toStringAsFixed(2)}%, which is below the statutory AS/NZS 3500.2 limit of $minSlope%. Please adjust your slab levels or drop coordinate!',
        );
      }

      // Calculate support bracket/clip count: AS/NZS 3500.2 Clause 9.2 (PVC pipes supported at max 1.2m intervals)
      // Horizontal PVC drainage lines must be clipped at max 1.2m. Vertical at max 1.8m.
      final isVertical = (fixture.z - sewerOutfall.z).abs() > horizDistance;
      final clipInterval = isVertical ? 1.8 : 1.2;
      final clipCount = (totalLen / clipInterval).ceil() + 1; // plus start anchor clip

      computedRoutes.add(
        PipeRouteTrace(
          id: 'route_${fixture.id}',
          label: '${fixture.name} to Sewer Outfall',
          pipeType: 'PVC Drainage',
          diameterDn: dn,
          totalLength: totalLen,
          slopePercent: calculatedSlope,
          requiredClips: clipCount,
          isGradientCompliant: isSlopeCompliant,
          standardCitation: citation,
        ),
      );

      // Calculate matching dual-run hot/cold water supply routing trace (Copper lines)
      if (fixture.anchorType != 'fwg') {
        final waterRouteLen = totalLen * 1.15; // include 15% allowance for vertical plumbing drops in walls
        // Water lines (copper) horizontal clipping: AS/NZS 3500.1 Clause 5.2 specifies max support spacings for DN15 copper: 1.5m
        final waterClips = (waterRouteLen / 1.5).ceil() + 1;

        computedRoutes.add(
          PipeRouteTrace(
            id: 'route_water_${fixture.id}',
            label: '${fixture.name} Hot & Cold Feed Lines',
            pipeType: 'Copper Water Runs (Dual)',
            diameterDn: 15,
            totalLength: waterRouteLen * 2, // both hot and cold runs
            slopePercent: 0.0, // water lines are pressurized, no gravity fall requirement
            requiredClips: waterClips * 2,
            isGradientCompliant: true,
            standardCitation: 'AS/NZS 3500.1 Clause 5.2',
          ),
        );
      }
    }

    // Build complete itemized Bill of Materials (BOM)
    final List<BomItem> bom = [];
    double totalMaterialCost = 0.0;

    // Aggregate physical materials required
    double totalPvc100Len = 0.0;
    double totalPvc50Len = 0.0;
    double totalCopper15Len = 0.0;
    int totalPvcClips = 0;
    int totalCopperClips = 0;
    int elbows100 = 0;
    int elbows50 = 0;
    int junctions = 0;

    for (final r in computedRoutes) {
      if (r.pipeType == 'PVC Drainage') {
        if (r.diameterDn == 100) {
          totalPvc100Len += r.totalLength;
          elbows100 += 2;
          junctions += 1;
        } else {
          totalPvc50Len += r.totalLength;
          elbows50 += 2;
        }
        totalPvcClips += r.requiredClips;
      } else {
        totalCopper15Len += r.totalLength;
        totalCopperClips += r.requiredClips;
      }
    }

    // PVC 100mm Sizing logic ($22 per meter)
    if (totalPvc100Len > 0) {
      final qty = totalPvc100Len.ceil();
      final unitCost = 22.0 * markupMultiplier;
      final total = qty * unitCost;
      bom.add(BomItem(name: 'DN100 PVC Drainage Pipe (Class 12)', category: 'Pipe', quantity: qty, unitPrice: unitCost, totalPrice: total));
      totalMaterialCost += total;
    }

    // PVC 50mm Sizing ($14 per meter)
    if (totalPvc50Len > 0) {
      final qty = totalPvc50Len.ceil();
      final unitCost = 14.0 * markupMultiplier;
      final total = qty * unitCost;
      bom.add(BomItem(name: 'DN50 PVC Drainage Pipe (Class 12)', category: 'Pipe', quantity: qty, unitPrice: unitCost, totalPrice: total));
      totalMaterialCost += total;
    }

    // Copper 15mm Sizing ($18 per meter)
    if (totalCopper15Len > 0) {
      final qty = totalCopper15Len.ceil();
      final unitCost = 18.0 * markupMultiplier;
      final total = qty * unitCost;
      bom.add(BomItem(name: 'DN15 Copper Water Tube (Pre-insulated)', category: 'Pipe', quantity: qty, unitPrice: unitCost, totalPrice: total));
      totalMaterialCost += total;
    }

    // Fittings and brackets
    if (elbows100 > 0) {
      final cost = 12.0 * markupMultiplier;
      bom.add(BomItem(name: 'DN100 PVC 90-Deg Elbow Fitting', category: 'Fitting', quantity: elbows100, unitPrice: cost, totalPrice: elbows100 * cost));
      totalMaterialCost += elbows100 * cost;
    }
    if (elbows50 > 0) {
      final cost = 6.0 * markupMultiplier;
      bom.add(BomItem(name: 'DN50 PVC 45/90-Deg Bend Fitting', category: 'Fitting', quantity: elbows50, unitPrice: cost, totalPrice: elbows50 * cost));
      totalMaterialCost += elbows50 * cost;
    }
    if (junctions > 0) {
      final cost = 28.0 * markupMultiplier;
      bom.add(BomItem(name: 'DN100 Junction / Combo Sewer Inlets', category: 'Fitting', quantity: junctions, unitPrice: cost, totalPrice: junctions * cost));
      totalMaterialCost += junctions * cost;
    }
    if (totalPvcClips > 0) {
      final cost = 4.5 * markupMultiplier;
      bom.add(BomItem(name: 'Heavy-Duty DN100/50 PVC Pipe Hanger Clips', category: 'Bracket', quantity: totalPvcClips, unitPrice: cost, totalPrice: totalPvcClips * cost));
      totalMaterialCost += totalPvcClips * cost;
    }
    if (totalCopperClips > 0) {
      final cost = 2.5 * markupMultiplier;
      bom.add(BomItem(name: 'Saddle Clips DN15 Copper w/ Insulator', category: 'Bracket', quantity: totalCopperClips, unitPrice: cost, totalPrice: totalCopperClips * cost));
      totalMaterialCost += totalCopperClips * cost;
    }

    // Mandatory consumables package ($45 basic set)
    final consumableCost = 45.0 * markupMultiplier;
    bom.add(BomItem(name: 'Premium Solvents, PVC Primers & Braze Packs', category: 'Consumable', quantity: 1, unitPrice: consumableCost, totalPrice: consumableCost));
    totalMaterialCost += consumableCost;

    // Labor calculation: allocate base hours per active plumbing fixture placement + setup time
    // Standard: 6 setup/travel hours, plus 4 labor hours per active drainage/fixture run
    final baseLaborHrs = 6.0 + (fixtureAnchors.length * 4.0);
    final totalLaborCost = baseLaborHrs * laborRatePerHour;

    // Quote summaries
    final sub = totalMaterialCost + totalLaborCost;
    final gst = sub * 0.10;
    final totalQuote = sub + gst;

    // Compliance alerts for local QLD water conservation and insulation standard rules
    if (fixtures.any((f) => f.anchorType == 'hws')) {
      alerts.add(
        'COMPLIANCE ALERT (AS/NZS 3500.4 Clause 5.9): Hot water supply line from storage system must be fully insulated (R-value minimum 0.3) for first 5 meters of piping to conserve thermal energy.',
      );
    }
    if (fixtures.isNotEmpty) {
      alerts.add(
        'REGULATORY STANDARD (PCA 2025 / QLD Plumbing Regulation): Floor waste gully (FWG) requires a minimum water seal depth of 75mm to prevent hazardous sewer gas backdraft into habitable bathroom spaces.',
      );
    }

    return PlumbingQuote(
      id: 'quote_${DateTime.now().millisecondsSinceEpoch}',
      roomType: roomType,
      roomLength: length,
      roomWidth: width,
      ceilingHeight: height,
      floorArea: floorArea,
      wallSurfaceArea: wallSurfaceArea,
      routes: computedRoutes,
      bomItems: bom,
      laborHours: baseLaborHrs,
      laborCost: totalLaborCost,
      materialCost: totalMaterialCost,
      subtotal: sub,
      markupPercent: (markupMultiplier - 1.0) * 100,
      gstAmount: gst,
      totalQuoteCost: totalQuote,
      complianceAlerts: alerts,
    );
  }
}
