import 'package:flutter/material.dart';
import 'package:flix/models/show_model.dart';
import 'package:flix/services/api_service.dart';
import 'package:flix/widgets/show_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final List<Show> _shows = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _currentPage = 0;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreShows();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreShows();
    }
  }

  Future<void> _loadMoreShows() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newShows = await _apiService.getShows(page: _currentPage);

      setState(() {
        _shows.addAll(newShows);
        _currentPage++;
        _hasMoreData = newShows.length == ApiService.pageSize;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading shows. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadMoreShows,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshShows() async {
    setState(() {
      _shows.clear();
      _currentPage = 0;
      _hasMoreData = true;
      _hasError = false;
    });
    await _loadMoreShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        title: Text(
          'TV Shows',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 28,
            ),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshShows,
        color: Colors.red,
        child: _shows.isEmpty && !_isLoading
            ? Center(
                child: _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load shows',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: _loadMoreShows,
                            child: Text('Retry'),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
              )
            : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(8),
                    sliver: SliverGrid(
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ShowCard(
                            show: _shows[index],
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/details',
                              arguments: _shows[index],
                            ),
                          );
                        },
                        childCount: _shows.length,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                    ),
                  if (!_hasMoreData && _shows.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No more shows to load',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
