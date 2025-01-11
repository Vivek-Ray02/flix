import 'package:flutter/material.dart';
import 'package:flix/models/show_model.dart';
import 'package:flix/services/storage_service.dart';
import 'package:flix/widgets/show_card.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Favorites'),
      ),
      body: FutureBuilder<List<Show>>(
        future: _storageService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ShowCard(
                show: snapshot.data![index],
                onTap: () => Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: snapshot.data![index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}