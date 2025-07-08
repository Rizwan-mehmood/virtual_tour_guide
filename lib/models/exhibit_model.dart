class Exhibit {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String type;
  final String location;
  final String artist;
  final String period;
  final String origin;
  final bool isIconic;
  final List<String> tags;
  final double averageRating;
  final int ratingCount;

  Exhibit({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.location,
    required this.artist,
    required this.period,
    required this.origin,
    this.isIconic = false,
    this.tags = const [],
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  // Factory constructor to create an Exhibit from a Map
  factory Exhibit.fromMap(Map<String, dynamic> map, String documentId) {
    return Exhibit(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      artist: map['artist'] ?? '',
      period: map['period'] ?? '',
      origin: map['origin'] ?? '',
      isIconic: map['isIconic'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  // Convert an Exhibit to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'location': location,
      'artist': artist,
      'period': period,
      'origin': origin,
      'isIconic': isIconic,
      'tags': tags,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  // Create a copy of the Exhibit with specified fields updated
  Exhibit copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? type,
    String? location,
    String? artist,
    String? period,
    String? origin,
    bool? isIconic,
    List<String>? tags,
    double? averageRating,
    int? ratingCount,
  }) {
    return Exhibit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      location: location ?? this.location,
      artist: artist ?? this.artist,
      period: period ?? this.period,
      origin: origin ?? this.origin,
      isIconic: isIconic ?? this.isIconic,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
