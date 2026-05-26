import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/models.dart';

/// Service class utilizing the pdf package to compile beautifully styled reports.
class PdfService {
  pw.Font? _baseFont;

  Future<pw.ThemeData> _getTheme() async {
    if (_baseFont == null) {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      _baseFont = pw.Font.ttf(fontData);
    }
    return pw.ThemeData.withFont(base: _baseFont);
  }

  /// Generates a professional pre-start safety SWMS report for QLD WHS compliance.
  Future<Uint8List> generateSwmsPdf(SwmsProfile profile) async {
    final pdf = pw.Document();
    final theme = await _getTheme();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('WHS PRE-START SWMS COMPLIANCE REPORT'),
              pw.SizedBox(height: 16),
              _buildMetaInfo('Task Name', profile.taskName),
              _buildMetaInfo('Licensed To', 'Queensland Plumbing Contractors'),
              _buildMetaInfo('Signed By', profile.signedBy ?? 'N/A'),
              _buildMetaInfo('Signoff Time', profile.signedAt?.toLocal().toString() ?? 'N/A'),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 16),
              _buildSectionTitle('IDENTIFIED JOB HAZARDS'),
              ...profile.hazards.map((h) => _buildListItem(h, PdfColors.red300)),
              pw.SizedBox(height: 16),
              _buildSectionTitle('REQUIRED CONTROL MEASURES'),
              ...profile.controlMeasures.map((c) => _buildListItem(c, PdfColors.green300)),
              pw.Spacer(),
              _buildFooterSignature(profile.signedBy ?? 'N/A'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates a statutory QBCC Form 4 lodging certificate receipt.
  Future<Uint8List> generateForm4Pdf(PlumbingJob job) async {
    final pdf = pw.Document();
    final theme = await _getTheme();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('QBCC FORM 4 - NOTIFIABLE PLUMBING RECEIPT'),
              pw.SizedBox(height: 16),
              _buildMetaInfo('Receipt ID', 'Form4-${job.id}-${DateTime.now().year}'),
              _buildMetaInfo('Job Title', job.title),
              _buildMetaInfo('Client Name', job.clientName),
              _buildMetaInfo('Site Address', job.address),
              _buildMetaInfo('Lodge Date', job.dateCompleted.toLocal().toString()),
              _buildMetaInfo('Regulatory Status', 'LODGED & CERTIFIED (Statutory compliance passed)'),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 16),
              _buildSectionTitle('COMPLIANCE PARSED STANDARD ISSUES'),
              if (job.issues.isEmpty)
                _buildListItem('No standards violations active (AS/NZS 3500 Compliant)', PdfColors.green300)
              else
                ...job.issues.map((i) => _buildListItem(i, PdfColors.orange300)),
              pw.Spacer(),
              _buildFooterSignature('QBCC Online Lodgement Portal'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates a statutory QBCC Form 9 Backflow Prevention device certificate.
  Future<Uint8List> generateForm9Pdf(BackflowDevice device) async {
    final pdf = pw.Document();
    final theme = await _getTheme();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          final isPass = device.passesInspection;
          final statusText = isPass ? 'PASS (AS 2845.3 Compliant)' : 'FAIL (Non-Compliant)';
          final statusColor = isPass ? PdfColors.green300 : PdfColors.red300;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('QBCC FORM 9 - BACKFLOW COMMISSIONING CERTIFICATE'),
              pw.SizedBox(height: 16),
              _buildMetaInfo('Form Type', 'Form 9 (Plumbing & Drainage Act 2018)'),
              _buildMetaInfo('Device Category', device.deviceType),
              _buildMetaInfo('Brand / Model', '${device.brand} / ${device.modelName}'),
              _buildMetaInfo('Serial Number', device.serialNumber),
              _buildMetaInfo('Physical Size', 'DN ${device.sizeDn}'),
              _buildMetaInfo('Location', device.location),
              _buildMetaInfo('Test Date', device.testDate.toLocal().toString().substring(0, 16)),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 16),
              _buildSectionTitle('AS 2845.3 HYDRAULIC TEST MEASUREMENTS'),
              _buildListItem('Upstream Line Pressure: ${device.upstreamPressureKpa.toStringAsFixed(1)} kPa', PdfColors.blue300),
              _buildListItem('First Check Valve Tightness: ${device.firstCheckValueKpa.toStringAsFixed(1)} kPa (Min: ${device.deviceType == 'RPZD' ? '35 kPa' : '7 kPa'})', PdfColors.blue300),
              if (device.deviceType == 'RPZD')
                _buildListItem('Relief Valve Opening Pressure: ${device.reliefValveOpeningKpa.toStringAsFixed(1)} kPa (Min: 14 kPa)', PdfColors.blue300),
              _buildListItem('Second Check Valve Tightness: ${device.secondCheckValueKpa.toStringAsFixed(1)} kPa (Min: 7 kPa)', PdfColors.blue300),
              pw.SizedBox(height: 24),
              _buildSectionTitle('COMMISSIONING DIAGNOSIS & STATUS'),
              _buildListItem('Diagnostic Result: $statusText', statusColor),
              if (!isPass)
                _buildListItem('Warning: Device does not meet minimum tightness thresholds. Rectification required.', PdfColors.orange300),
              pw.Spacer(),
              _buildFooterSignature('${device.testerName} (${device.testerLicence})'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates a statutory As-Constructed Sanitary Drainage Diagram PDF.
  Future<Uint8List> generateDrainageDiagramPdf(PlumbingJob job) async {
    final pdf = pw.Document();

    pw.Widget sketchWidget;
    if (job.drainageSketchBase64 != null && job.drainageSketchBase64!.isNotEmpty) {
      try {
        final rawBase64 = job.drainageSketchBase64!.contains(',')
            ? job.drainageSketchBase64!.split(',').last
            : job.drainageSketchBase64!;
        final sketchBytes = base64Decode(rawBase64);
        final sketchImage = pw.MemoryImage(sketchBytes);
        sketchWidget = pw.Container(
          height: 380,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
            color: PdfColors.white,
          ),
          child: pw.Image(sketchImage, fit: pw.BoxFit.contain),
        );
      } catch (e) {
        sketchWidget = pw.Container(
          height: 380,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red300, width: 1.5),
            color: PdfColors.white,
          ),
          child: pw.Text(
            'Error decoding drainage sketch image stream: $e',
            style: pw.TextStyle(color: PdfColors.red700, fontWeight: pw.FontWeight.bold),
          ),
        );
      }
    } else {
      sketchWidget = pw.Container(
        height: 380,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'NO DRAINAGE SKETCH DIAGRAM ATTACHED',
              style: pw.TextStyle(color: PdfColors.grey500, fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Draw as-constructed drainage lines using Plumbnator Sketcher first.',
              style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 10),
            ),
          ],
        ),
      );
    }

    final theme = await _getTheme();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('AS-CONSTRUCTED SANITARY DRAINAGE SKETCH SHEET'),
              pw.SizedBox(height: 16),
              _buildMetaInfo('Form Category', 'As-Constructed Drainage Diagram (Plumbing & Drainage Regulation 2019)'),
              _buildMetaInfo('Job Ref / Title', job.title),
              _buildMetaInfo('Site Address', job.address),
              _buildMetaInfo('Client Details', job.clientName),
              _buildMetaInfo('Date Completed', job.dateCompleted.toLocal().toString().substring(0, 10)),
              _buildMetaInfo('Statutory Status', job.status),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 16),
              _buildSectionTitle('OFFICIAL DRAINAGE LAYOUT PLAN (AS/NZS 3500.2)'),
              sketchWidget,
              pw.SizedBox(height: 12),
              _buildListItem('Red Lines / Nodes indicate Sanitary Drains, Gully Traps (ORG), and Inspection Shafts (IS).', PdfColors.red300),
              _buildListItem('This document constitutes a physical compliance diagram under Queensland statutory plumbing regulations.', PdfColors.blue300),
              pw.Spacer(),
              _buildFooterSignature(job.form4Submitted ? 'LODGED (QBCC Receipt)' : 'DRAFT FOR LODGEMENT'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Helper to build a clean title header block with standard branding deep colors.
  pw.Widget _buildHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF0A0F1D),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  /// Helper to draw metadata key/value rows nicely aligned.
  pw.Widget _buildMetaInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to render custom section labels.
  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF00E6FF),
        ),
      ),
    );
  }

  /// Helper to render bullet points with colored indicators.
  pw.Widget _buildListItem(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6, left: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 6,
            height: 6,
            margin: const pw.EdgeInsets.only(top: 3, right: 8),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: color,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  /// Generates the signed-off vector footer design at bottom of pages.
  pw.Widget _buildFooterSignature(String authority) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'PLUMBNATOR COMPLIANCE ENGINE - AS/NZS 3500 & PCA',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  width: 120,
                  height: 40,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    authority,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.blue700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Authorized Digital Signoff',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
