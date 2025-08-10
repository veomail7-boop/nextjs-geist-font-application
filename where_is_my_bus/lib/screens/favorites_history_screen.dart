import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/bus.dart';
import '../widgets/bus_card.dart';
import 'bus_details_screen.dart';

class FavoritesHistoryScreen extends StatefulWidget {
  @override
  _FavoritesHistoryScreenState createState() => _FavoritesHistoryScreenState();
}

class _FavoritesHistoryScreenState extends State<FavoritesHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for favorites and history
  List<Bus> _favoriteBuses = [];
  List<SearchHistory> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock favorite buses
    _favoriteBuses = [
      sampleBuses[0], // Downtown Express
      sampleBuses[1], // Uptown Local
    ];

    // Mock search history
    _searchHistory = [
      SearchHistory(
        source: 'Central Station',
        destination: 'Times Square',
        searchTime: DateTime.now().subtract(Duration(hours: 2)),
        resultCount: 2,
      ),
      SearchHistory(
        source: 'Grand Central',
        destination: 'Central Park',
        searchTime: DateTime.now().subtract(Duration(days: 1)),
        resultCount: 1,
      ),
      SearchHistory(
        source: 'Penn Station',
        destination: 'Union Square',
        searchTime: DateTime.now().subtract(Duration(days: 2)),
        resultCount: 3,
      ),
      SearchHistory(
        source: '5th Avenue',
        destination: 'Brooklyn Bridge',
        searchTime: DateTime.now().subtract(Duration(days: 3)),
        resultCount: 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Favorites & History'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Favorites',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              _showClearDialog(context);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                '${_favoriteBuses.length} Favorite Routes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Favorites List
        Expanded(
          child: _favoriteBuses.isEmpty
              ? _buildEmptyState(
                  'No Favorite Routes',
                  'Add buses to favorites for quick access',
                  Icons.favorite_border,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _favoriteBuses.length,
                  itemBuilder: (context, index) {
                    final bus = _favoriteBuses[index];
                    return Dismissible(
                      key: Key('favorite_${bus.busNumber}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _favoriteBuses.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${bus.busName} removed from favorites'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  _favoriteBuses.insert(index, bus);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: BusCard(
                        bus: bus,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusDetailsScreen(bus: bus),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // History List
        Expanded(
          child: _searchHistory.isEmpty
              ? _buildEmptyState(
                  'No Search History',
                  'Your recent searches will appear here',
                  Icons.history,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final history = _searchHistory[index];
                    return Dismissible(
                      key: Key('history_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 20),
                            SizedBox(height: 2),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _searchHistory.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Search history deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  _searchHistory.insert(index, history);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildHistoryItem(context, history),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, SearchHistory history) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate back to home screen with pre-filled search
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Search repeated: ${history.source} → ${history.destination}'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.route,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  history.source,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  history.destination,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.outline,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatSearchTime(history.searchTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.directions_bus,
                                size: 14,
                                color: theme.colorScheme.outline,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${history.resultCount} buses found',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.replay,
                      color: theme.colorScheme.outline,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: theme.colorScheme.outline,
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All'),
          content: Text('Are you sure you want to clear all favorites and history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _favoriteBuses.clear();
                  _searchHistory.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  String _formatSearchTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class SearchHistory {
  final String source;
  final String destination;
  final DateTime searchTime;
  final int resultCount;

  SearchHistory({
    required this.source,
    required this.destination,
    required this.searchTime,
    required this.resultCount,
  });
}
