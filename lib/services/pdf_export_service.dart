import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'ar_spatial_quoting_service.dart';

class PdfExportService {
  static final _currencyFormat = NumberFormat.currency(locale: 'en_AU', symbol: '\$');

  static Future<void> generateAndShareQuote(PlumbingQuote quote) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(quote),
            pw.SizedBox(height: 20),
            _buildJobScope(quote),
            pw.SizedBox(height: 20),
            _buildComplianceAudit(quote),
            pw.SizedBox(height: 20),
            _buildBomTable(quote),
            pw.SizedBox(height: 20),
            _buildPricingSummary(quote),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Quote_${quote.id}.pdf');
  }

  static pw.Widget _buildHeader(PlumbingQuote quote) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('AQUAFORGE DIGITAL CERTIFICATION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.SizedBox(height: 4),
        pw.Text('Certified Plumber Quote', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Quote ID: ${quote.id}'),
            pw.Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildJobScope(PlumbingQuote quote) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Job Scope & Floor Plan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Room Type: ${quote.roomType}'),
                pw.Text('Dimensions: ${quote.roomLength.toStringAsFixed(2)}m x ${quote.roomWidth.toStringAsFixed(2)}m'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Floor Area: ${quote.floorArea.toStringAsFixed(2)} sqm'),
                pw.Text('Water/Sewer Lines: ${quote.routes.length} Active Traces'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildComplianceAudit(PlumbingQuote quote) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('AS/NZS 3500 Compliance Audit', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...quote.complianceAlerts.map((alert) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: alert.contains('WARNING:') ? PdfColors.red : PdfColors.amber)),
                  pw.Expanded(child: pw.Text(alert, style: const pw.TextStyle(fontSize: 10))),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _buildBomTable(PlumbingQuote quote) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Itemized Takeoff BOM', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignment: pw.Alignment.centerLeft,
          headers: ['Description', 'Qty', 'Unit Price', 'Subtotal'],
          data: quote.bomItems.map((item) => [
                item.name,
                item.quantity.toString(),
                _currencyFormat.format(item.unitPrice),
                _currencyFormat.format(item.totalPrice),
              ]).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildPricingSummary(PlumbingQuote quote) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Pricing Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _buildPriceRow('Material Component Costs:', _currencyFormat.format(quote.materialCost)),
          _buildPriceRow('Plumber Labor (${quote.laborHours.toStringAsFixed(1)} hrs):', _currencyFormat.format(quote.laborCost)),
          pw.Divider(color: PdfColors.grey300),
          _buildPriceRow('Subtotal:', _currencyFormat.format(quote.subtotal)),
          _buildPriceRow('GST (10%):', _currencyFormat.format(quote.gstAmount)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL ESTIMATE:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(_currencyFormat.format(quote.totalQuoteCost), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPriceRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text(
          'All generated quotes dynamically respect Australian standard plumbing specifications, verifying critical pipeline slopes and support guidelines automatically.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
