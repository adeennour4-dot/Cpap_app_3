
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For picking files[citation:5]
import '../models/cpap_session.dart';
import '../services/cpap_parser.dart';
import './detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CpapSession> _sessions = [];
  bool _isLoading = false;

  // Function to pick and parse files from SD card/device storage
  Future<void> _pickAndParseFiles() async {
    setState(() => _isLoading = true);
    try {
      // Open file picker[citation:5]
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // Target common CPAP file extensions[citation:1]
        allowedExtensions: ['edf', 'dat', 'csv', 'xml'],
      );
      if (result == null) return; // User cancelled

      List<File> files = result.paths.map((path) => File(path!)).toList();
      List<CpapSession> loadedSessions = [];
      CpapParser parser = CpapParser();

      for (File file in files) {
        try {
          CpapSession session = await parser.parseFile(file);
          loadedSessions.add(session);
        } catch (e) {
          print('Failed to parse ${file.path}: $e');
        }
      }
      setState(() => _sessions = loadedSessions);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your CPAP Sessions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(
                  child: Text('No sessions found. Tap + to import.'))
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (ctx, index) {
                    CpapSession session = _sessions[index];
                    return ListTile(
                      title: Text('Night of ${session.date.toString()}'),
                      subtitle: Text('AHI: ${session.ahi} | Usage: ${session.usageHours}h'),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: session,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndParseFiles,
        child: const Icon(Icons.add),
      ),
    );
  }
}
