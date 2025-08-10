import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/stoppage.dart';

class RouteDetailsScreen extends StatelessWidget {
  final Bus bus;

  const RouteDetailsScreen({Key? key, required this.bus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Route Timetable'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Timetable refreshed'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
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
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bus.busNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bus.busName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Updated: ${_formatTime(now)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${bus.stoppages.length} stops',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Legend
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildLegendItem(
                  context,
                  'Current Stop',
                  theme.colorScheme.primary,
                  Icons.radio_button_checked,
                ),
                SizedBox(width: 20),
                _buildLegendItem(
                  context,
                  'Upcoming',
                  theme.colorScheme.outline,
                  Icons.radio_button_unchecked,
                ),
                SizedBox(width: 20),
                _buildLegendItem(
                  context,
                  'Completed',
                  theme.colorScheme.outline.withOpacity(0.5),
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Route Timeline
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: bus.stoppages.length,
              itemBuilder: (context, index) {
                final stoppage = bus.stoppages[index];
                final isFirst = index == 0;
                final isLast = index == bus.stoppages.length - 1;
                
                // Determine status
                StoppageStatus status = _getStoppageStatus(stoppage, now);
                
                return _buildStoppageItem(
                  context,
                  stoppage,
                  status,
                  isFirst,
                  isLast,
                  index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStoppageItem(
    BuildContext context,
    Stoppage stoppage,
    StoppageStatus status,
    bool isFirst,
    bool isLast,
    int stopNumber,
  ) {
    final theme = Theme.of(context);
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case StoppageStatus.completed:
        statusColor = theme.colorScheme.outline.withOpacity(0.5);
        statusIcon = Icons.check_circle;
        break;
      case StoppageStatus.current:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.radio_button_checked;
        break;
      case StoppageStatus.upcoming:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: status == StoppageStatus.completed 
                      ? statusColor 
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 20,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
            ],
          ),
          
          SizedBox(width: 16),
          
          // Stoppage details
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status == StoppageStatus.current
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: status == StoppageStatus.current
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stop $stopNumber',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (status == StoppageStatus.current)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    stoppage.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: status == StoppageStatus.current
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Arrives: ${_formatTime(stoppage.arrivalTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.departure_board,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Departs: ${_formatTime(stoppage.departureTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (status == StoppageStatus.current) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bus is currently at this stop',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (status == StoppageStatus.upcoming) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ETA: ${_getTimeUntilArrival(stoppage.arrivalTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  StoppageStatus _getStoppageStatus(Stoppage stoppage, DateTime now) {
    if (now.isBefore(stoppage.arrivalTime)) {
      return StoppageStatus.upcoming;
    } else if (now.isAfter(stoppage.arrivalTime) && now.isBefore(stoppage.departureTime)) {
      return StoppageStatus.current;
    } else {
      return StoppageStatus.completed;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeUntilArrival(DateTime arrivalTime) {
    final now = DateTime.now();
    final difference = arrivalTime.difference(now);
    
    if (difference.inMinutes < 1) {
      return 'Less than 1 min';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }
}

enum StoppageStatus {
  completed,
  current,
  upcoming,
}
