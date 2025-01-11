import 'package:flutter/material.dart';
import 'package:flix/models/show_model.dart';

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final show = ModalRoute.of(context)!.settings.arguments as Show;
    final Size screenSize = MediaQuery.of(context).size;
    final double imageHeight = screenSize.width > 600
        ? 500
        : 300; // Adjust image height based on screen width

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageHeight,
            pinned: true,
            backgroundColor: Colors.black.withOpacity(0.7),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: Hero(
                  tag: 'show_image_${show.id}',
                  child: show.imageUrl != null
                      ? Image.network(
                          show.imageUrl!,
                          fit: BoxFit.contain, // Changed from cover to contain
                          alignment: Alignment.topCenter, // Align image to top
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.image_not_supported),
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              // Center the content
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 800), // Limit content width
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        show.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width > 600
                              ? 32
                              : 24, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (show.rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '${show.rating?.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width > 600 ? 20 : 16,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: show.genres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width > 600 ? 16 : 14,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width > 600 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _stripHtmlTags(show.summary),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenSize.width > 600 ? 18 : 16,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32), // Add some bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
