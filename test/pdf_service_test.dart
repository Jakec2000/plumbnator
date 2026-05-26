import 'package:flutter_test/flutter_test.dart';
import 'package:plumbnator/services/pdf_service.dart';
import 'package:plumbnator/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PdfService pdfService;

  setUp(() {
    pdfService = PdfService();
  });

  group('PdfService Tests - Document Generation', () {
    test('generateSwmsPdf returns a valid byte array', () async {
      final mockSwms = SwmsProfile(
        id: '123',
        taskName: 'Pipe Repair',
        hazards: ['Falling', 'Chemicals'],
        controlMeasures: ['Harness', 'Gloves'],
        signedBy: 'John Plumber',
        signedAt: DateTime(2026, 1, 1),
      );

      final pdfBytes = await pdfService.generateSwmsPdf(mockSwms);
      
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Check for standard PDF header signature %PDF-
      expect(pdfBytes[0], equals(0x25)); // %
      expect(pdfBytes[1], equals(0x50)); // P
      expect(pdfBytes[2], equals(0x44)); // D
      expect(pdfBytes[3], equals(0x46)); // F
    });

    test('generateForm4Pdf returns a valid byte array', () async {
      final mockJob = PlumbingJob(
        id: 'job-123',
        title: 'Bathroom Renovation',
        clientName: 'Jane Doe',
        address: '123 Fake St, Brisbane',
        dateCompleted: DateTime(2026, 2, 2),
        status: 'LODGED',
        complianceScore: 0.95,
        issues: ['Missing lagging on cold pipe'],
        form4Submitted: true,
      );

      final pdfBytes = await pdfService.generateForm4Pdf(mockJob);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(pdfBytes[0], equals(0x25)); // %PDF-
    });

    test('generateForm9Pdf returns a valid byte array', () async {
      final mockDevice = BackflowDevice(
        id: 'bf-1',
        deviceType: 'RPZD',
        brand: 'Watts',
        modelName: '009',
        serialNumber: 'SN99999',
        sizeDn: 50,
        location: 'Plant Room',
        testDate: DateTime(2026, 3, 3),
        upstreamPressureKpa: 500.0,
        firstCheckValueKpa: 40.0,
        reliefValveOpeningKpa: 15.0,
        secondCheckValueKpa: 10.0,
        testerName: 'Bob Tester',
        testerLicence: 'QBCC123456',
      );

      final pdfBytes = await pdfService.generateForm9Pdf(mockDevice);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(pdfBytes[0], equals(0x25)); // %PDF-
    });

    test('generateDrainageDiagramPdf handles base64 image and generates PDF', () async {
      // 1x1 transparent png in base64
      const dummyBase64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
      
      final mockJob = PlumbingJob(
        id: 'job-124',
        title: 'New Drainage',
        clientName: 'John Smith',
        address: '456 Real Ave',
        dateCompleted: DateTime.now(),
        status: 'DRAFT',
        complianceScore: 1.0,
        issues: [],
        form4Submitted: false,
        drainageSketchBase64: 'data:image/png;base64,$dummyBase64Image',
      );

      final pdfBytes = await pdfService.generateDrainageDiagramPdf(mockJob);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(pdfBytes[0], equals(0x25)); // %PDF-
    });

    test('generateDrainageDiagramPdf handles missing base64 sketch gracefully', () async {
      final mockJob = PlumbingJob(
        id: 'job-125',
        title: 'No Sketch Job',
        clientName: 'No Sketch Client',
        address: 'Nowhere',
        dateCompleted: DateTime.now(),
        status: 'DRAFT',
        complianceScore: 0.8,
        issues: [],
        form4Submitted: false,
        drainageSketchBase64: null, // missing sketch
      );

      final pdfBytes = await pdfService.generateDrainageDiagramPdf(mockJob);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(pdfBytes[0], equals(0x25)); // %PDF-
    });
  });
}
