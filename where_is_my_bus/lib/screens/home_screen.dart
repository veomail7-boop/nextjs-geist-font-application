import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/bus.dart';
import '../widgets/bus_card.dart';
import 'bus_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _sourceFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();
  
  List<Bus> _searchResults = [];
  List<String> _allStoppages = [];
  List<String> _sourceSuggestions = [];
  List<String> _destinationSuggestions = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _showSourceSuggestions = false;
  bool _showDestinationSuggestions = false;

  @override
  void initState() {
    super.initState();
    _allStoppages = getAllStoppageNames();
    _searchResults = sampleBuses; // Show all buses initially
    
    // Add listeners for text changes
    _sourceController.addListener(_onSourceTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);
    
    // Add focus listeners
    _sourceFocusNode.addListener(() {
      setState(() {
        _showSourceSuggestions = _sourceFocusNode.hasFocus && _sourceSuggestions.isNotEmpty;
      });
    });
    
    _destinationFocusNode.addListener(() {
      setState(() {
        _showDestinationSuggestions = _destinationFocusNode.hasFocus && _destinationSuggestions.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onSourceTextChanged() {
    final query = _sourceController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _sourceSuggestions = [];
        _showSourceSuggestions = false;
      });
      return;
    }
    
    setState(() {
      _sourceSuggestions = _allStoppages
          .where((stoppage) => stoppage.toLowerCase().contains(query))
          .take(5)
          .toList();
      _showSourceSuggestions = _sourceFocusNode.hasFocus && _sourceSuggestions.isNotEmpty;
    });
  }

  void _onDestinationTextChanged() {
    final query = _destinationController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _destinationSuggestions = [];
        _showDestinationSuggestions = false;
      });
      return;
    }
    
    setState(() {
      _destinationSuggestions = _allStoppages
          .where((stoppage) => stoppage.toLowerCase().contains(query))
          .take(5)
          .toList();
      _showDestinationSuggestions = _destinationFocusNode.hasFocus && _destinationSuggestions.isNotEmpty;
    });
  }

  void _selectSourceSuggestion(String suggestion) {
    _sourceController.text = suggestion;
    setState(() {
      _showSourceSuggestions = false;
    });
    _sourceFocusNode.unfocus();
  }

  void _selectDestinationSuggestion(String suggestion) {
    _destinationController.text = suggestion;
    setState(() {
      _showDestinationSuggestions = false;
    });
    _destinationFocusNode.unfocus();
  }

  void _swapSourceDestination() {
    final temp = _sourceController.text;
    _sourceController.text = _destinationController.text;
    _destinationController.text = temp;
    
    // Hide suggestions after swap
    setState(() {
      _showSourceSuggestions = false;
      _showDestinationSuggestions = false;
    });
  }

  void _searchBuses() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSearching = true;
      });

      // Simulate search delay
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _searchResults = findBusesBetweenStoppages(
            _sourceController.text,
            _destinationController.text,
          );
          _isSearching = false;
          _hasSearched = true;
        });
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _sourceController.clear();
      _destinationController.clear();
      _searchResults = sampleBuses;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'WhereIsMyBus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
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
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Source Input
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _sourceController,
                          focusNode: _sourceFocusNode,
                          decoration: InputDecoration(
                            labelText: 'From (Source)',
                            prefixIcon: Icon(Icons.my_location, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter source location';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Source Suggestions
                      if (_showSourceSuggestions)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _sourceSuggestions.map((suggestion) {
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.location_on, size: 16, color: theme.colorScheme.outline),
                                title: Text(
                                  suggestion,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                onTap: () => _selectSourceSuggestion(suggestion),
                              );
                            }).toList(),
                          ),
                        ),
                      // Swap Button
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: GestureDetector(
                            onTap: _swapSourceDestination,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.swap_vert,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Destination Input
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _destinationController,
                          focusNode: _destinationFocusNode,
                          decoration: InputDecoration(
                            labelText: 'To (Destination)',
                            prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter destination location';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Destination Suggestions
                      if (_showDestinationSuggestions)
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _destinationSuggestions.map((suggestion) {
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.location_on, size: 16, color: theme.colorScheme.outline),
                                title: Text(
                                  suggestion,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                onTap: () => _selectDestinationSuggestion(suggestion),
                              );
                            }).toList(),
                          ),
                        ),
                      // Search Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : _searchBuses,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: _isSearching
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onSecondary,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Search Buses',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (_hasSearched) ...[
                            SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _clearSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                                padding: EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: Icon(Icons.clear),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _hasSearched 
                              ? 'Search Results (${_searchResults.length})'
                              : 'Available Buses (${_searchResults.length})',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_searchResults.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              // Show all buses on map (future feature)
                            },
                            icon: Icon(Icons.map, size: 18),
                            label: Text('Map View'),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Bus List
                  Expanded(
                    child: _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_bus_outlined,
                                  size: 80,
                                  color: theme.colorScheme.outline,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No buses found',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try searching with different locations',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 20),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final bus = _searchResults[index];
                              return BusCard(
                                bus: bus,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusDetailsScreen(bus: bus),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
