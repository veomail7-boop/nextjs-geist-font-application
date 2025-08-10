import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/stoppage.dart';
import 'route_details_screen.dart';
import 'live_tracking_screen.dart';

class BusDetailsScreen extends StatelessWidget {
  final Bus bus;

  const BusDetailsScreen({Key? key, required this.bus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    // Find current and next stoppage
    Stoppage? currentStoppage;
    Stoppage? nextStoppage;
    
    for (int i = 0; i < bus.stoppages.length; i++) {
      final stoppage = bus.stoppages[i];
      if (now.isAfter(stoppage.arrivalTime) && now.isBefore(stoppage.departureTime)) {
        currentStoppage = stoppage;
        if (i + 1 < bus.stoppages.length) {
          nextStoppage = bus.stoppages[i + 1];
        }
        break;
      } else if (stoppage.arrivalTime.isAfter(now)) {
        nextStoppage = stoppage;
        break;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Bus Details'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to favorites'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          bus.busNumber,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    bus.busName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${bus.stoppages.length} stops on this route',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Current Status Section
            if (currentStoppage != null || nextStoppage != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Current Status',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (currentStoppage != null) ...[
                      _buildStatusItem(
                        context,
                        'Currently at',
                        currentStoppage.name,
                        'Departs at ${_formatTime(currentStoppage.departureTime)}',
                        Icons.radio_button_checked,
                        theme.colorScheme.primary,
                      ),
                      SizedBox(height: 12),
                    ],
                    if (nextStoppage != null)
                      _buildStatusItem(
                        context,
                        'Next stop',
                        nextStoppage.name,
                        'Arrives at ${_formatTime(nextStoppage.arrivalTime)}',
                        Icons.radio_button_unchecked,
                        theme.colorScheme.outline,
                      ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildActionButton(
                    context,
                    'View Full Route',
                    'See all stops and timetable',
                    Icons.route,
                    theme.colorScheme.secondary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteDetailsScreen(bus: bus),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    'Live Tracking',
                    'Track bus location in real-time',
                    Icons.gps_fixed,
                    theme.colorScheme.tertiary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveTrackingScreen(bus: bus),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Quick Route Preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Preview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < bus.stoppages.length && i < 5; i++)
                          _buildRoutePreviewItem(
                            context,
                            bus.stoppages[i],
                            i == 0,
                            i == bus.stoppages.length - 1 || i == 4,
                            currentStoppage == bus.stoppages[i],
                          ),
                        if (bus.stoppages.length > 5)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '... and ${bus.stoppages.length - 5} more stops',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String location,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                location,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePreviewItem(
    BuildContext context,
    Stoppage stoppage,
    bool isFirst,
    bool isLast,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: isCurrent 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 12,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stoppage.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_formatTime(stoppage.arrivalTime)} - ${_formatTime(stoppage.departureTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
