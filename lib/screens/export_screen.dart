import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; // For PDF preview & sharing
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/cpap_session.dart';
import '../services/pdf_exporter.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  List<CpapSession> _selectedSessions = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Get the list of sessions to export (could be one or many)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<CpapSession>) {
      _selectedSessions = args;
    }
  }

  Future<void> _exportAllToPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdfExporter = PdfExporter();
      // This creates a single PDF with all selected sessions
      final pdfFile = await pdfExporter.exportSessionsToPdf(_selectedSessions);
      // Preview and share the generated PDF
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes());
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF Reports')),
      body: _isExporting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedSessions.length,
                    itemBuilder: (ctx, index) {
                      final session = _selectedSessions[index];
                      return CheckboxListTile(
                        title: Text('${session.date} - AHI: ${session.ahi}'),
                        value: true, // All pre-selected
                        onChanged: null, // Selection handled by parent screen
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportAllToPdf,
                          icon: const Icon(Icons.download),
                          label: const Text('Export All as Single PDF'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
