class Show {
  final int id;
  final String name;
  final String summary;
  final String? imageUrl;
  final List<String> genres;
  final double? rating;
  final String status; // Added status field

  Show({
    required this.id,
    required this.name,
    required this.summary,
    this.imageUrl,
    required this.genres,
    this.rating,
    required this.status, // Added to constructor
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    final show = json['show'];
    return Show(
      id: show['id'],
      name: show['name'],
      summary: show['summary'] ?? '',
      imageUrl: show['image']?['original'],
      genres: List<String>.from(show['genres']),
      rating: show['rating']?['average']?.toDouble(),
      status: show['status'] ?? 'Unknown', // Parse status from JSON
    );
  }
}
