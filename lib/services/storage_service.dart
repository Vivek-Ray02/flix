import 'dart:convert';
import 'package:flix/models/show_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';

  Future<void> toggleFavorite(Show show) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (favorites.any((s) => s.id == show.id)) {
      favorites.removeWhere((s) => s.id == show.id);
    } else {
      favorites.add(show);
    }

    await prefs.setString(
        _favoritesKey,
        json.encode(
          favorites
              .map((s) => {
                    'id': s.id,
                    'name': s.name,
                    'summary': s.summary,
                    'imageUrl': s.imageUrl,
                    'genres': s.genres,
                    'rating': s.rating,
                    'status': s.status, // Added status
                  })
              .toList(),
        ));
  }

  Future<List<Show>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null) return [];

    final List<dynamic> decoded = json.decode(favoritesJson);
    return decoded
        .map((item) => Show(
              id: item['id'],
              name: item['name'],
              summary: item['summary'],
              imageUrl: item['imageUrl'],
              genres: List<String>.from(item['genres']),
              rating: item['rating']?.toDouble(),
              status: item['status'], // Added status
            ))
        .toList();
  }

  Future<bool> isFavorite(int showId) async {
    final favorites = await getFavorites();
    return favorites.any((show) => show.id == showId);
  }
}
