import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/services/ar_spatial_quoting_service.dart';

void main() {
  group('ArSpatialQuotingService Geometry & Distance Tests', () {
    test('SpatialAnchor calculates 3D Euclidean distance correctly', () {
      const p1 = SpatialAnchor(id: 'a', name: 'Start', x: 0.0, y: 0.0, z: 0.0, anchorType: 'corner');
      const p2 = SpatialAnchor(id: 'b', name: 'End', x: 3.0, y: 4.0, z: 0.0, anchorType: 'corner');

      expect(p1.distanceTo(p2), closeTo(5.0, 0.0001));
      expect(p1.horizontalDistanceTo(p2), closeTo(5.0, 0.0001));
    });

    test('SpatialAnchor handles height differentials in Euclidean calculations', () {
      const p1 = SpatialAnchor(id: 'a', name: 'Base', x: 0.0, y: 0.0, z: 1.0, anchorType: 'corner');
      const p2 = SpatialAnchor(id: 'b', name: 'Top', x: 0.0, y: 0.0, z: 4.0, anchorType: 'corner');

      expect(p1.distanceTo(p2), closeTo(3.0, 0.0001));
      expect(p1.horizontalDistanceTo(p2), closeTo(0.0, 0.0001));
    });
  });

  group('AR Spatial Sizer and Cost Takeoff Calculations', () {
    final service = ArSpatialQuotingService();

    test('generateSpatialQuote calculates correct area and volume dimensions', () {
      final quote = service.generateSpatialQuote(
        roomType: 'Ensuite Bathroom',
        length: 4.0,
        width: 3.0,
        height: 2.7,
        fixtures: [],
      );

      expect(quote.floorArea, equals(12.0));
      expect(quote.wallSurfaceArea, closeTo(37.8, 0.0001));
      expect(quote.routes, isEmpty);
      expect(quote.bomItems, isNotEmpty); // Consumables package is always added
      expect(quote.laborHours, equals(6.0)); // Base setup hours
      expect(quote.subtotal, greaterThan(0));
    });

    test('PVC bracket clipping rules spacing calculation asserts correct intervals', () {
      // 1.2m intervals horizontal PVC: A 3.6m run + 0.2m drop yields total 3D length of ~3.61m.
      // So clips = ceil(3.61 / 1.2) + 1 = 4 + 1 = 5 clips.
      final fixtures = [
        const SpatialAnchor(
          id: 'wc_fixture',
          name: 'WC Pedestal Pan',
          x: 3.6,
          y: 0.0,
          z: 0.0,
          anchorType: 'wc',
        ),
      ];

      final quote = service.generateSpatialQuote(
        roomType: 'Bathroom',
        length: 4.0,
        width: 3.0,
        height: 2.7,
        fixtures: fixtures,
      );

      final pvcRoute = quote.routes.firstWhere((r) => r.pipeType == 'PVC Drainage');
      expect(pvcRoute.requiredClips, equals(5)); // ceil(3.605 / 1.2) + 1 = 5 clips
      expect(pvcRoute.diameterDn, equals(100));
    });

    test('AS/NZS 3500.2 minimum gradient verification alerts on shallow grade', () {
      // A horizontal run of 10m with only a 0.05m drop yields 0.5% grade, falling below 1.65% DN100 limit
      final fixtures = [
        const SpatialAnchor(
          id: 'wc_low_grade',
          name: 'Sewer Line Toilet Outfall',
          x: 10.0,
          y: 0.0,
          z: -0.15, // Outfall is z=-0.2, drop is 0.05m
          anchorType: 'wc',
        ),
      ];

      final quote = service.generateSpatialQuote(
        roomType: 'Bathroom',
        length: 12.0,
        width: 6.0,
        height: 2.7,
        fixtures: fixtures,
      );

      final pvcRoute = quote.routes.firstWhere((r) => r.pipeType == 'PVC Drainage');
      expect(pvcRoute.isGradientCompliant, isFalse);
      expect(quote.complianceAlerts.any((a) => a.contains('gradient is')), isTrue);
    });

    test('AS/NZS 3500.2 minimum gradient passes on steep safe fall grade', () {
      // A run of 3.0m with a 0.3m drop yields 10% grade, passing the 1.65% minimum requirement
      final fixtures = [
        const SpatialAnchor(
          id: 'wc_compliant_grade',
          name: 'Steep Sewer line Outfall',
          x: 3.0,
          y: 0.0,
          z: 0.1, // Outfall is z=-0.2, drop is 0.3m
          anchorType: 'wc',
        ),
      ];

      final quote = service.generateSpatialQuote(
        roomType: 'Bathroom',
        length: 5.0,
        width: 4.0,
        height: 2.7,
        fixtures: fixtures,
      );

      final pvcRoute = quote.routes.firstWhere((r) => r.pipeType == 'PVC Drainage');
      expect(pvcRoute.isGradientCompliant, isTrue);
    });
  });
}
