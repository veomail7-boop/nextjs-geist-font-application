import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/stoppage.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Bus bus;

  const LiveTrackingScreen({Key? key, required this.bus}) : super(key: key);

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Stoppage? _currentStoppage;
  Stoppage? _nextStoppage;
  double _busProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _calculateBusPosition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _calculateBusPosition() {
    final now = DateTime.now();
    
    for (int i = 0; i < widget.bus.stoppages.length; i++) {
      final stoppage = widget.bus.stoppages[i];
      
      if (now.isAfter(stoppage.arrivalTime) && now.isBefore(stoppage.departureTime)) {
        _currentStoppage = stoppage;
        if (i + 1 < widget.bus.stoppages.length) {
          _nextStoppage = widget.bus.stoppages[i + 1];
        }
        _busProgress = i / (widget.bus.stoppages.length - 1);
        break;
      } else if (stoppage.arrivalTime.isAfter(now)) {
        _nextStoppage = stoppage;
        if (i > 0) {
          _currentStoppage = widget.bus.stoppages[i - 1];
          // Calculate progress between current and next stop
          final prevStoppage = widget.bus.stoppages[i - 1];
          final totalTime = stoppage.arrivalTime.difference(prevStoppage.departureTime).inMinutes;
          final elapsedTime = now.difference(prevStoppage.departureTime).inMinutes;
          final progressBetweenStops = (elapsedTime / totalTime).clamp(0.0, 1.0);
          _busProgress = ((i - 1) + progressBetweenStops) / (widget.bus.stoppages.length - 1);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Live Tracking'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _calculateBusPosition();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location updated'),
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
                        widget.bus.busNumber,
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
                        widget.bus.busName,
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
                    Icon(Icons.gps_fixed, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Live tracking active',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ONLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Mock Map View
          Container(
            height: 300,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Mock map background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.green.shade50,
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: MapPainter(),
                    ),
                  ),
                  
                  // Route line
                  CustomPaint(
                    size: Size.infinite,
                    painter: RoutePainter(
                      stoppages: widget.bus.stoppages,
                      progress: _busProgress,
                      theme: theme,
                    ),
                  ),
                  
                  // Bus marker
                  Positioned(
                    left: 50 + (_busProgress * 200),
                    top: 100 + (_busProgress * 100),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  widget.bus.busNumber,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Map controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildMapControl(Icons.zoom_in, () {}),
                        SizedBox(height: 8),
                        _buildMapControl(Icons.zoom_out, () {}),
                        SizedBox(height: 8),
                        _buildMapControl(Icons.my_location, () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Current Status
          if (_currentStoppage != null || _nextStoppage != null)
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
                        'Current Position',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_currentStoppage != null) ...[
                    _buildLocationInfo(
                      context,
                      'Last seen at',
                      _currentStoppage!.name,
                      'Departed at ${_formatTime(_currentStoppage!.departureTime)}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    if (_nextStoppage != null) ...[
                      SizedBox(height: 16),
                      _buildLocationInfo(
                        context,
                        'Heading to',
                        _nextStoppage!.name,
                        'ETA: ${_formatTime(_nextStoppage!.arrivalTime)}',
                        Icons.navigation,
                        theme.colorScheme.primary,
                      ),
                    ],
                  ] else if (_nextStoppage != null) ...[
                    _buildLocationInfo(
                      context,
                      'Next stop',
                      _nextStoppage!.name,
                      'Arrives at ${_formatTime(_nextStoppage!.arrivalTime)}',
                      Icons.navigation,
                      theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),

          SizedBox(height: 20),

          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Set Alert',
                    Icons.notifications,
                    theme.colorScheme.secondary,
                    () {
                      _showAlertDialog(context);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Share Location',
                    Icons.share,
                    theme.colorScheme.tertiary,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bus location shared'),
                          backgroundColor: theme.colorScheme.tertiary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(
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

  Widget _buildQuickAction(
    BuildContext context,
    String title,
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
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Arrival Alert'),
          content: Text('Get notified when the bus is approaching your stop.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alert set successfully'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              child: Text('Set Alert'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(i * size.width / 10, 0),
        Offset(i * size.width / 10, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * size.height / 10),
        Offset(size.width, i * size.height / 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  final List<Stoppage> stoppages;
  final double progress;
  final ThemeData theme;

  RoutePainter({
    required this.stoppages,
    required this.progress,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final completedRoutePaint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw route line
    final path = Path();
    path.moveTo(50, 100);
    path.lineTo(250, 200);

    canvas.drawPath(path, routePaint);

    // Draw completed portion
    final completedPath = Path();
    completedPath.moveTo(50, 100);
    completedPath.lineTo(50 + (progress * 200), 100 + (progress * 100));

    canvas.drawPath(completedPath, completedRoutePaint);

    // Draw stop markers
    final stopPaint = Paint()
      ..color = theme.colorScheme.outline
      ..style = PaintingStyle.fill;

    for (int i = 0; i < stoppages.length && i < 4; i++) {
      final x = 50.0 + (i * 200 / 3);
      final y = 100.0 + (i * 100 / 3);
      
      canvas.drawCircle(Offset(x, y), 6, stopPaint);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
