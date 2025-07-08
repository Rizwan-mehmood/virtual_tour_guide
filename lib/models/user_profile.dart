class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String avatarUrl;
  final List<String> favoriteExhibitTypes;
  final List<String> favoriteExhibits;
  final List<CompletedTour> completedTours;
  final Map<String, dynamic> preferences;
  final int commentCount;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.favoriteExhibitTypes = const [],
    this.favoriteExhibits = const [],
    this.completedTours = const [],
    this.preferences = const {},
    this.commentCount = 0,
  });

  // Factory constructor to create a UserProfile from a Map
  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    // Handle both List<Map> and List<String> for completedTours
    final raw = map['completedTours'];
    List<CompletedTour> tours = [];
    if (raw is List) {
      for (var item in raw) {
        if (item is Map<String, dynamic>) {
          tours.add(CompletedTour.fromMap(item));
        } else if (item is String) {
          // Only an ID stored: create a minimal CompletedTour
          tours.add(
            CompletedTour(
              tourId: item,
              tourName: '',
              completedDate: DateTime.now(),
            ),
          );
        }
      }
    }

    return UserProfile(
      userId: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      favoriteExhibitTypes: List<String>.from(
        map['favoriteExhibitTypes'] ?? [],
      ),
      favoriteExhibits: List<String>.from(map['favoriteExhibits'] ?? []),
      completedTours: tours,
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      commentCount: map['commentCount'] ?? 0,
    );
  }

  // Convert a UserProfile to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'favoriteExhibitTypes': favoriteExhibitTypes,
      'favoriteExhibits': favoriteExhibits,
      'completedTours': completedTours.map((x) => x.toMap()).toList(),
      'preferences': preferences,
    };
  }

  // Create a copy of the UserProfile with specified fields updated
  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? favoriteExhibitTypes,
    List<String>? favoriteExhibits,
    List<CompletedTour>? completedTours,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteExhibitTypes: favoriteExhibitTypes ?? this.favoriteExhibitTypes,
      favoriteExhibits: favoriteExhibits ?? this.favoriteExhibits,
      completedTours: completedTours ?? this.completedTours,
      preferences: preferences ?? this.preferences,
    );
  }
}

class CompletedTour {
  final String tourId;
  final String tourName;
  final DateTime completedDate;
  final double rating;
  final String feedback;

  CompletedTour({
    required this.tourId,
    required this.tourName,
    required this.completedDate,
    this.rating = 0,
    this.feedback = '',
  });

  // Factory constructor to create a CompletedTour from a Map
  factory CompletedTour.fromMap(Map<String, dynamic> map) {
    return CompletedTour(
      tourId: map['tourId'] ?? '',
      tourName: map['tourName'] ?? '',
      completedDate: DateTime.parse(
        map['completedDate'] ?? DateTime.now().toIso8601String(),
      ),
      rating: map['rating']?.toDouble() ?? 0.0,
      feedback: map['feedback'] ?? '',
    );
  }

  // Convert a CompletedTour to a Map
  Map<String, dynamic> toMap() {
    return {
      'tourId': tourId,
      'tourName': tourName,
      'completedDate': completedDate.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
    };
  }
}
