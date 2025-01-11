import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flix/models/show_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';
  static const int pageSize = 20;

  Future<List<Show>> getShows({int page = 0}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows?page=$page'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Show.fromJson({'show': json})).toList();
      } else {
        throw Exception('Failed to load shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Show>> searchShows(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/search/shows?q=${Uri.encodeComponent(query)}'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Show.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during search: $e');
    }
  }

  Future<List<Show>> getShowsByGenre(String genre, {int page = 0}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows?page=$page'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => Show.fromJson({'show': json}))
            .where((show) => show.genres.contains(genre))
            .toList();
      } else {
        throw Exception(
            'Failed to load shows by genre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching shows by genre: $e');
    }
  }

  Future<List<Show>> getFilteredShows({
    List<String>? genres,
    double? minRating,
    String? status,
    int page = 0,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows?page=$page'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Show.fromJson({'show': json})).where((show) {
          bool matches = true;

          if (genres != null && genres.isNotEmpty) {
            matches =
                matches && show.genres.any((genre) => genres.contains(genre));
          }

          if (minRating != null && show.rating != null) {
            matches = matches && show.rating! >= minRating;
          }

          if (status != null) {
            matches = matches && show.status == status;
          }

          return matches;
        }).toList();
      } else {
        throw Exception(
            'Failed to load filtered shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while filtering shows: $e');
    }
  }

  Future<Map<String, dynamic>> getShowDetails(int showId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows/$showId'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load show details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching show details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getShowEpisodes(int showId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows/$showId/episodes'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load show episodes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching episodes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getShowCast(int showId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shows/$showId/cast'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load show cast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching cast: $e');
    }
  }
}
