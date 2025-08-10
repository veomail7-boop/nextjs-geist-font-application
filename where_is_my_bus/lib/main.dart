import 'package:flutter/material.dart';
import 'models/bus.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/favorites': (context) => FavoritesHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes that require arguments
        switch (settings.name) {
          case '/bus_details':
            final bus = settings.arguments as Bus;
            return MaterialPageRoute(
              builder: (context) => BusDetailsScreen(bus: bus),
            );
          case '/route_details':
            final bus = settings.arguments as Bus;
            return MaterialPageRoute(
              builder: (context) => RouteDetailsScreen(bus: bus),
            );
          case '/live_tracking':
            final bus = settings.arguments as Bus;
            return MaterialPageRoute(
              builder: (context) => LiveTrackingScreen(bus: bus),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => HomeScreen(),
            );
        }
      },
    );
  }
}
