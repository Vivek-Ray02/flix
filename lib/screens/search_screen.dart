import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flix/models/show_model.dart';
import 'package:flix/services/api_service.dart';
import 'package:flix/widgets/show_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  List<Show> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      try {
        final results = await _apiService.searchShows(query);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching shows')),
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          width: double.infinity,
          constraints:
              BoxConstraints(maxWidth: 800), // Add max width for search bar
          child: TextField(
            onChanged: _onSearchChanged,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search TV shows...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.grey),
            ),
            autofocus: true,
          ),
        ),
      ),
      body: Center(
        // Center the content
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 1200), // Add max width constraint
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'Start typing to search shows',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200
                            ? 5
                            : MediaQuery.of(context).size.width > 800
                                ? 4
                                : MediaQuery.of(context).size.width > 600
                                    ? 3
                                    : 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ShowCard(
                          show: _searchResults[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: _searchResults[index],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
