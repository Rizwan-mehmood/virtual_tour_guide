import 'dart:convert';
import 'package:uuid/uuid.dart';

// User model for storing profile information and preferences
class User {
  final String id;
  String username;
  String email;
  String profileImage;
  List<String> favoriteExhibitIds;
  Map<String, dynamic> preferences;

  User({
    String? id,
    required this.username,
    required this.email,
    this.profileImage = '',
    List<String>? favoriteExhibitIds,
    Map<String, dynamic>? preferences,
  }) : this.id = id ?? Uuid().v4(),
       this.favoriteExhibitIds = favoriteExhibitIds ?? [],
       this.preferences = preferences ?? {};

  // Convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'favoriteExhibitIds': favoriteExhibitIds,
      'preferences': preferences,
    };
  }

  // Create User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
      favoriteExhibitIds: List<String>.from(json['favoriteExhibitIds']),
      preferences: json['preferences'],
    );
  }

  // Create a copy of User with optional updated fields
  User copyWith({
    String? username,
    String? email,
    String? profileImage,
    List<String>? favoriteExhibitIds,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      favoriteExhibitIds: favoriteExhibitIds ?? this.favoriteExhibitIds,
      preferences: preferences ?? this.preferences,
    );
  }
}

// Exhibit model for museum exhibits
class Exhibit {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String location;
  final String period;
  final List<String> artistNames;
  final List<Review> reviews;
  final double averageRating; // Calculated from reviews

  Exhibit({
    String? id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.period,
    List<String>? artistNames,
    List<Review>? reviews,
    double? averageRating,
  }) : this.id = id ?? Uuid().v4(),
       this.artistNames = artistNames ?? [],
       this.reviews = reviews ?? [],
       this.averageRating = averageRating ?? 0.0;

  // Calculate average rating
  double calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  // Convert Exhibit instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'location': location,
      'period': period,
      'artistNames': artistNames,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'averageRating': calculateAverageRating(),
    };
  }

  // Create Exhibit instance from JSON
  factory Exhibit.fromJson(Map<String, dynamic> json) {
    List<Review> reviewsList = [];
    if (json['reviews'] != null) {
      reviewsList = List<Review>.from(
        json['reviews'].map((reviewJson) => Review.fromJson(reviewJson)),
      );
    }

    return Exhibit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      location: json['location'],
      period: json['period'],
      artistNames: List<String>.from(json['artistNames']),
      reviews: reviewsList,
      averageRating: json['averageRating'],
    );
  }

  // Create a copy of Exhibit with updated reviews
  Exhibit addReview(Review review) {
    final updatedReviews = List<Review>.from(reviews)..add(review);
    return Exhibit(
      id: this.id,
      name: this.name,
      description: this.description,
      imageUrl: this.imageUrl,
      category: this.category,
      location: this.location,
      period: this.period,
      artistNames: this.artistNames,
      reviews: updatedReviews,
      averageRating: null, // Will be calculated
    );
  }
}

// Review model for exhibit reviews
class Review {
  final String id;
  final String userId;
  final String username;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    String? id,
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : this.id = id ?? Uuid().v4(),
       this.createdAt = createdAt ?? DateTime.now();

  // Convert Review instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Review instance from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Tour model for scheduling museum tours
class Tour {
  final String id;
  final String userId;
  String title;
  DateTime startTime;
  DateTime endTime;
  List<String> exhibitIds;
  String status; // 'scheduled', 'completed', 'cancelled'
  String? notes;

  Tour({
    String? id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    List<String>? exhibitIds,
    this.status = 'scheduled',
    this.notes,
  }) : this.id = id ?? Uuid().v4(),
       this.exhibitIds = exhibitIds ?? [];

  // Convert Tour instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exhibitIds': exhibitIds,
      'status': status,
      'notes': notes,
    };
  }

  // Create Tour instance from JSON
  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      exhibitIds: List<String>.from(json['exhibitIds']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  // Create a copy of Tour with optional updated fields
  Tour copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? exhibitIds,
    String? status,
    String? notes,
  }) {
    return Tour(
      id: this.id,
      userId: this.userId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exhibitIds: exhibitIds ?? this.exhibitIds,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Cancel the tour
  Tour cancel() {
    return copyWith(status: 'cancelled');
  }

  // Add an exhibit to the tour
  Tour addExhibit(String exhibitId) {
    if (exhibitIds.contains(exhibitId)) return this;
    final updatedExhibitIds = List<String>.from(exhibitIds)..add(exhibitId);
    return copyWith(exhibitIds: updatedExhibitIds);
  }

  // Remove an exhibit from the tour
  Tour removeExhibit(String exhibitId) {
    if (!exhibitIds.contains(exhibitId)) return this;
    final updatedExhibitIds = List<String>.from(exhibitIds)..remove(exhibitId);
    return copyWith(exhibitIds: updatedExhibitIds);
  }
}
