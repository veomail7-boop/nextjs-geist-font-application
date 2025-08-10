# Detailed Implementation Plan for WhereIsMyBus Flutter App

This plan outlines the complete steps and dependent files for building a cross-platform Flutter app called **WhereIsMyBus**. The app will help users search for real-time bus schedules, view route timetables, and track bus positions. It will feature a premium, modern UI with Material 3 theming (dark/light mode), smooth transitions, and fault-tolerant error handling.

---

## 1. Project Setup

- **Action:** Create a new Flutter project.
- **Command:**  
  ```
  flutter create where_is_my_bus
  ```
- **Outcome:** A new project directory with default Android, iOS, web folders and a basic `lib` folder.

- **Modifications to `pubspec.yaml`:**  
  - Ensure Flutter SDK and required dependencies (if using additional packages like provider, etc.) are listed.
  - Example snippet:
    ```yaml
    environment:
      sdk: ">=2.18.0 <3.0.0"

    dependencies:
      flutter:
        sdk: flutter
      cupertino_icons: ^1.0.2
      # Optionally add provider or any state management package

    dev_dependencies:
      flutter_test:
        sdk: flutter
    ```

---

## 2. Directory Structure

Set up the following structure under the `lib` folder:

```
lib/

├── main.dart
├── models/
│   ├── bus.dart
│   └── stoppage.dart
├── mock_data.dart
├── screens/
│   ├── home_screen.dart
│   ├── route_details_screen.dart
│   ├── live_tracking_screen.dart
│   ├── bus_details_screen.dart
│   └── favorites_history_screen.dart
└── widgets/
    ├── bus_card.dart
    └── timetable_item.dart
```

---

## 3. File-by-File Changes

### 3.1. `lib/main.dart`
- **Purpose:** App entry point; defines the `MaterialApp`, routes, and theme (light/dark).
- **Changes:**
  - Initialize theme data using Material3.
  - Define named routes for each screen.
  - Example snippet:
    ```dart
    import 'package:flutter/material.dart';
    import 'screens/home_screen.dart';
    import 'screens/route_details_screen.dart';
    import 'screens/live_tracking_screen.dart';
    import 'screens/bus_details_screen.dart';
    import 'screens/favorites_history_screen.dart';

    void main() {
      runApp(WhereIsMyBusApp());
    }

    class WhereIsMyBusApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'WhereIsMyBus',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/route_details': (context) => RouteDetailsScreen(),
            '/live_tracking': (context) => LiveTrackingScreen(),
            '/bus_details': (context) => BusDetailsScreen(),
            '/favorites': (context) => FavoritesHistoryScreen(),
          },
        );
      }
    }
    ```

### 3.2. `lib/models/bus.dart`
- **Purpose:** Define the Bus model with properties.
- **Changes:**
  - Create a `Bus` class with attributes like `busNumber`, `busName`, and a list of stoppages.
  - Example:
    ```dart
    import 'stoppage.dart';

    class Bus {
      final String busNumber;
      final String busName;
      final List<Stoppage> stoppages;

      Bus({required this.busNumber, required this.busName, required this.stoppages});
    }
    ```

### 3.3. `lib/models/stoppage.dart`
- **Purpose:** Define the Stoppage model.
- **Changes:**
  - Create a `Stoppage` class with properties such as `name`, `arrivalTime`, `departureTime`, and optional coordinates.
  - Example:
    ```dart
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
    }
    ```

### 3.4. `lib/mock_data.dart`
- **Purpose:** Provide sample bus routes and timetable data.
- **Changes:**
  - Create sample instances of `Bus` and `Stoppage` with realistic data (e.g. routes for New York or a sample city).
  - Example:
    ```dart
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
            departureTime: DateTime.now().add(Duration(minutes: 0)),
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          Stoppage(
            name: "5th Avenue",
            arrivalTime: DateTime.now().add(Duration(minutes: 10)),
            departureTime: DateTime.now().add(Duration(minutes: 12)),
          ),
          // Add more stoppages as needed
        ],
      ),
      // More bus instances…
    ];
    ```

### 3.5. `lib/screens/home_screen.dart`
- **Purpose:** Initial screen for bus search.
- **Changes:**
  - Create a form with two dropdowns or text fields to select "source" and "destination" stoppages.
  - Include a search button that validates non-empty selections.
  - Display a list of buses (using `BusCard` from widgets) matching the selected route.
  - Example UI elements:
    ```dart
    import 'package:flutter/material.dart';
    import '../mock_data.dart';
    import '../widgets/bus_card.dart';

    class HomeScreen extends StatefulWidget {
      @override
      _HomeScreenState createState() => _HomeScreenState();
    }

    class _HomeScreenState extends State<HomeScreen> {
      String? source;
      String? destination;

      final _formKey = GlobalKey<FormState>();

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text("WhereIsMyBus")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Source"),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                          onSaved: (value) => source = value,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Destination"),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                          onSaved: (value) => destination = value,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // For simplicity, show all sample buses.
                      Navigator.pushNamed(context, '/bus_details');
                    }
                  },
                  child: Text("Search Buses"),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: sampleBuses.length,
                    itemBuilder: (context, index) {
                      return BusCard(bus: sampleBuses[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    ```

### 3.6. `lib/widgets/bus_card.dart`
- **Purpose:** Render each bus item in the search results.
- **Changes:**
  - Create a card with modern, premium layout that shows bus number and name.
  - Provide an InkWell tap handler to navigate to Bus Details.
  - Example:
    ```dart
    import 'package:flutter/material.dart';
    import '../models/bus.dart';

    class BusCard extends StatelessWidget {
      final Bus bus;
      const BusCard({Key? key, required this.bus}) : super(key: key);

      @override
      Widget build(BuildContext context) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/bus_details', arguments: bus);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus.busNumber, style: Theme.of(context).textTheme.headline6),
                  SizedBox(height: 4),
                  Text(bus.busName, style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
            ),
          ),
        );
      }
    }
    ```

### 3.7. `lib/screens/route_details_screen.dart`
- **Purpose:** Display the timetable (stoppages, arrival/departure times) of a selected route.
- **Changes:**
  - Use a ListView to list each stoppage.
  - Highlight the current stoppage based on system time.
  - Use a custom widget (e.g., timetable_item) for each stoppage if needed.
  - Example:
    ```dart
    import 'package:flutter/material.dart';
    import '../models/bus.dart';

    class RouteDetailsScreen extends StatelessWidget {
      final Bus bus;
      const RouteDetailsScreen({Key? key, required this.bus}) : super(key: key);

      @override
      Widget build(BuildContext context) {
        final currentTime = DateTime.now();
        return Scaffold(
          appBar: AppBar(title: Text("Route Details")),
          body: ListView.builder(
            itemCount: bus.stoppages.length,
            itemBuilder: (context, index) {
              final stoppage = bus.stoppages[index];
              final isCurrent = currentTime.isAfter(stoppage.arrivalTime) &&
                  currentTime.isBefore(stoppage.departureTime);
              return ListTile(
                title: Text(stoppage.name,
                    style: isCurrent ? TextStyle(fontWeight: FontWeight.bold) : null),
                subtitle: Text(
                    "Arrives: ${stoppage.arrivalTime.hour}:${stoppage.arrivalTime.minute}  Departs: ${stoppage.departureTime.hour}:${stoppage.departureTime.minute}"),
                tileColor: isCurrent ? Colors.amber.withOpacity(0.3) : null,
              );
            },
          ),
        );
      }
    }
    ```

### 3.8. `lib/screens/live_tracking_screen.dart`
- **Purpose:** Provide a live bus tracking view.
- **Changes:**
  - Layout a mock map view using a Container with a placeholder background color.
  - Overlay a “bus marker” (as a styled Container with text) at a simulated position.
  - Include a list view below the map with time-matched bus positions.
  - Example:
    ```dart
    import 'package:flutter/material.dart';

    class LiveTrackingScreen extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        // Simulation: calculate bus position based on current time.
        return Scaffold(
          appBar: AppBar(title: Text("Live Bus Tracking")),
          body: Column(
            children: [
              Container(
                height: 300,
                color: Colors.grey.shade300,
                child: Stack(
                  children: [
                    Center(child: Text("Mock Map View", style: TextStyle(fontSize: 18))),
                    Positioned(
                      top: 120,
                      left: 150,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("Bus Position", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text("Time Matched Bus Positions (mock data)"),
                    // Populate list items with simulated tracking info.
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
    ```

### 3.9. `lib/screens/bus_details_screen.dart`
- **Purpose:** Show detailed bus information including route and timings.
- **Changes:**
  - Accept the selected Bus as an argument (via Navigator).
  - Display comprehensive route details.
  - Include a button to navigate to Live Tracking.
  - Example:
    ```dart
    import 'package:flutter/material.dart';
    import '../models/bus.dart';

    class BusDetailsScreen extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        final Bus bus = ModalRoute.of(context)!.settings.arguments as Bus;
        return Scaffold(
          appBar: AppBar(title: Text("Bus Details")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bus ${bus.busNumber} - ${bus.busName}", style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/route_details', arguments: bus);
                  },
                  child: Text("View Route Timetable"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/live_tracking');
                  },
                  child: Text("Live Tracking"),
                ),
              ],
            ),
          ),
        );
      }
    }
    ```

### 3.10. `lib/screens/favorites_history_screen.dart`
- **Purpose:** Display a list of favorite routes and recent searches.
- **Changes:**
  - Layout a ListView showing favorite bus routes.
  - Provide options to remove an item from favorites.
  - Example:
    ```dart
    import 'package:flutter/material.dart';

    class FavoritesHistoryScreen extends StatelessWidget {
      // For demo purposes use a static list of favorites.
      final List<String> favorites = ["45A - Downtown Express", "12B - Uptown Local"];

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text("Favorites & History")),
          body: ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(favorites[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Implement removal logic
                  },
                ),
              );
            },
          ),
        );
      }
    }
    ```

---

## 4. Additional Features & Best Practices

- **Error Handling:**  
  - Validate user input in forms (non-empty validations).
  - Use try/catch blocks for any asynchronous data fetching (if moved from mock to real API).
  - Display friendly error messages using SnackBar or AlertDialog.
  
- **UI/UX Considerations:**  
  - Consistent margins, paddings, and typography across screens.
  - Use Material 3 components to ensure premium and modern appearance.
  - Smooth transitions between screens using `Navigator.push` with built-in animations.
  
- **Data Integration:**  
  - Currently using `mock_data.dart` for bus and stoppage info.
  - In real scenario, integrate a REST API service with proper error and timeout handling.
  
- **State Management:**  
  - Use simple `setState` for local state.
  - For complex state, consider Provider or another state management solution.
  
- **Testing & Documentation:**  
  - Create widget tests for each screen.
  - Update the README.md with project overview, installation and run instructions.

---

## Summary

- A new Flutter project "WhereIsMyBus" will be created from scratch with a modular directory structure.  
- Key screens include Home, Route Details, Live Tracking, Bus Details, and Favorites/History with modern Material 3 UI.  
- Models for Bus and Stoppage, along with mock data, are defined and used across screens.  
- The project emphasizes error handling, proper state management, and responsive design for Android, iOS, and web.  
- Navigation and theming are configured in the main entry point with light/dark mode support.  
- Best practices include input validations, clear UI separation, and thorough documentation in README.md.

