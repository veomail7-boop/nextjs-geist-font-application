import 'stoppage.dart';

class Bus {
  final String busNumber;
  final String busName;
  final List<Stoppage> stoppages;

  Bus({
    required this.busNumber,
    required this.busName,
    required this.stoppages,
  });

  @override
  String toString() {
    return 'Bus{busNumber: $busNumber, busName: $busName, stoppages: ${stoppages.length} stops}';
  }
}
