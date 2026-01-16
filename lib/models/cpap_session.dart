class CpapSession {
  final String id;
  final DateTime date;
  final double ahi; // Apnea-Hypopnea Index
  final double usageHours;
  final double leakRate;
  final double pressureAverage;
  final List<double> pressureData; // For detailed graphs (e.g., per-minute)

  CpapSession({
    required this.id,
    required this.date,
    required this.ahi,
    required this.usageHours,
    required this.leakRate,
    required this.pressureAverage,
    required this.pressureData,
  });
}
