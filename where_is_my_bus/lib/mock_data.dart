import 'models/bus.dart';
import 'models/stoppage.dart';

List<Bus> sampleBuses = [
  Bus(
    busNumber: "45A",
    busName: "Downtown Express",
    stoppages: [
      Stoppage(
        name: "Central Station",
        arrivalTime: DateTime.now().subtract(Duration(minutes: 5)),
        departureTime: DateTime.now().add(Duration(minutes: 2)),
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      Stoppage(
        name: "5th Avenue",
        arrivalTime: DateTime.now().add(Duration(minutes: 10)),
        departureTime: DateTime.now().add(Duration(minutes: 12)),
        latitude: 40.7614,
        longitude: -73.9776,
      ),
      Stoppage(
        name: "Times Square",
        arrivalTime: DateTime.now().add(Duration(minutes: 18)),
        departureTime: DateTime.now().add(Duration(minutes: 20)),
        latitude: 40.7580,
        longitude: -73.9855,
      ),
      Stoppage(
        name: "Brooklyn Bridge",
        arrivalTime: DateTime.now().add(Duration(minutes: 30)),
        departureTime: DateTime.now().add(Duration(minutes: 32)),
        latitude: 40.7061,
        longitude: -73.9969,
      ),
    ],
  ),
  Bus(
    busNumber: "12B",
    busName: "Uptown Local",
    stoppages: [
      Stoppage(
        name: "Grand Central",
        arrivalTime: DateTime.now().add(Duration(minutes: 3)),
        departureTime: DateTime.now().add(Duration(minutes: 5)),
        latitude: 40.7527,
        longitude: -73.9772,
      ),
      Stoppage(
        name: "Central Park",
        arrivalTime: DateTime.now().add(Duration(minutes: 15)),
        departureTime: DateTime.now().add(Duration(minutes: 17)),
        latitude: 40.7829,
        longitude: -73.9654,
      ),
      Stoppage(
        name: "Columbia University",
        arrivalTime: DateTime.now().add(Duration(minutes: 25)),
        departureTime: DateTime.now().add(Duration(minutes: 27)),
        latitude: 40.8075,
        longitude: -73.9626,
      ),
      Stoppage(
        name: "Harlem",
        arrivalTime: DateTime.now().add(Duration(minutes: 40)),
        departureTime: DateTime.now().add(Duration(minutes: 42)),
        latitude: 40.8176,
        longitude: -73.9482,
      ),
    ],
  ),
  Bus(
    busNumber: "78C",
    busName: "Crosstown Shuttle",
    stoppages: [
      Stoppage(
        name: "Penn Station",
        arrivalTime: DateTime.now().add(Duration(minutes: 8)),
        departureTime: DateTime.now().add(Duration(minutes: 10)),
        latitude: 40.7505,
        longitude: -73.9934,
      ),
      Stoppage(
        name: "Madison Square Garden",
        arrivalTime: DateTime.now().add(Duration(minutes: 12)),
        departureTime: DateTime.now().add(Duration(minutes: 14)),
        latitude: 40.7505,
        longitude: -73.9934,
      ),
      Stoppage(
        name: "Union Square",
        arrivalTime: DateTime.now().add(Duration(minutes: 22)),
        departureTime: DateTime.now().add(Duration(minutes: 24)),
        latitude: 40.7359,
        longitude: -73.9911,
      ),
      Stoppage(
        name: "East Village",
        arrivalTime: DateTime.now().add(Duration(minutes: 35)),
        departureTime: DateTime.now().add(Duration(minutes: 37)),
        latitude: 40.7264,
        longitude: -73.9818,
      ),
    ],
  ),
];

// Helper function to get all unique stoppage names for search
List<String> getAllStoppageNames() {
  Set<String> stoppageNames = {};
  for (Bus bus in sampleBuses) {
    for (Stoppage stoppage in bus.stoppages) {
      stoppageNames.add(stoppage.name);
    }
  }
  return stoppageNames.toList()..sort();
}

// Helper function to find buses between two stoppages
List<Bus> findBusesBetweenStoppages(String source, String destination) {
  List<Bus> matchingBuses = [];
  
  for (Bus bus in sampleBuses) {
    bool hasSource = false;
    bool hasDestination = false;
    int sourceIndex = -1;
    int destinationIndex = -1;
    
    for (int i = 0; i < bus.stoppages.length; i++) {
      if (bus.stoppages[i].name.toLowerCase().contains(source.toLowerCase())) {
        hasSource = true;
        sourceIndex = i;
      }
      if (bus.stoppages[i].name.toLowerCase().contains(destination.toLowerCase())) {
        hasDestination = true;
        destinationIndex = i;
      }
    }
    
    // Only add bus if it has both stoppages and source comes before destination
    if (hasSource && hasDestination && sourceIndex < destinationIndex) {
      matchingBuses.add(bus);
    }
  }
  
  return matchingBuses;
}
