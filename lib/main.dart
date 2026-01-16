import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/export_screen.dart';

void main() {
  runApp(const CpapDataApp());
}

class CpapDataApp extends StatelessWidget {
  const CpapDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPAP Data Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
        '/export': (context) => const ExportScreen(),
      },
    );
  }
}
