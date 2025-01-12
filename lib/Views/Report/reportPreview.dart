import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPreview extends StatelessWidget {
  final Map<String, String> report;

  const ReportPreview({super.key, required this.report});

  // Generate PDF for printing
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Homestay: ${report['houseName']}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${report['sessionDate']}', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Status: ${report['status']}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('House Description:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Number of rooms: 3', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Text('Room Details and Activities:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Room Type: Deluxe, Activities: Swimming, Hiking', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
          ],
        );
      },
    ));

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pdf = await _generatePdf();
            await Printing.layoutPdf(onLayout: (_) => pdf.save());
          },
          child: const Text('Print Report'),
        ),
      ),
    );
  }
}
