import 'package:flutter/material.dart';
import 'package:hcms_sep/Domain/Report.dart';
import 'package:hcms_sep/Provider/ReportController.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPreview extends StatefulWidget {
  final Report report;

  const ReportPreview({super.key, required this.report});

  @override
  _ReportPreviewState createState() => _ReportPreviewState();
}

class _ReportPreviewState extends State<ReportPreview> {
  final ReportController _reportController = ReportController();
  bool isLoading = true;
  Map<String, dynamic> homestayDetails = {};
  Map<String, dynamic> bookingDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchHomestayDetails();
  }

  // Fetch homestay and booking details
  Future<void> _fetchHomestayDetails() async {
    // Use widget.report.homestayId to fetch details from the controller
    Map<String, dynamic> homestay = await _reportController.getHomestay(widget.report.homestayID);
    Map<String, dynamic> booking = await _reportController.getBooking(widget.report.bookingId);

    setState(() {
      homestayDetails = homestay;
      bookingDetails = booking;
      isLoading = false;
    });
  }

  // Generate PDF for printing
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Access the homestay name and other details
            pw.Text('Homestay: ${homestayDetails['House Name'] ?? 'Unknown'}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${widget.report.sessionDate ?? 'Unknown'}',
                style: pw.TextStyle(fontSize: 16)),
            pw.Text('Status: ${bookingDetails['bookingStatus'] ?? 'Unknown'}',
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('House Description:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Number of rooms: ${homestayDetails['Rooms']?.length ?? 0}',
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Text('Room Details and Activities:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Loop through the rooms and activities from the homestay details
            ...(homestayDetails['Rooms']?.map((room) {
              return pw.Column(
                children: [
                  pw.Text('Room Type: ${room['roomType'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14)),
                  // pw.SizedBox(height: 4),
                  // pw.Text('Activities: ${room['activities']?.join(', ') ?? 'No activities'}',
                  //     style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 10),
                ],
              );
            }).toList() ?? []),
          ],
        );
      },
    ));

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preview Report'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
      );
    }

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
