class Stoppage {
  final String name;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final double? latitude;
  final double? longitude;

  Stoppage({
    required this.name,
    required this.arrivalTime,
    required this.departureTime,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    return 'Stoppage{name: $name, arrivalTime: $arrivalTime, departureTime: $departureTime}';
  }
}
