import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitComment {
  final String id;
  final String exhibitId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final List<String> images;

  ExhibitComment({
    this.id = '',
    required this.exhibitId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl = '',
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.images = const [],
  });

  // Factory constructor to create an ExhibitComment from a Map
  factory ExhibitComment.fromMap(Map<String, dynamic> map, String documentId) {
    return ExhibitComment(
      id: documentId,
      exhibitId: map['exhibitId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatarUrl: map['userAvatarUrl'] ?? '',
      comment: map['comment'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      images: List<String>.from(map['images'] ?? []),
    );
  }

  // Convert an ExhibitComment to a Map
  Map<String, dynamic> toMap() {
    return {
      'exhibitId': exhibitId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'images': images,
    };
  }

  // Create a copy of the ExhibitComment with specified fields updated
  ExhibitComment copyWith({
    String? id,
    String? exhibitId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? comment,
    double? rating,
    DateTime? createdAt,
    List<String>? images,
  }) {
    return ExhibitComment(
      id: id ?? this.id,
      exhibitId: exhibitId ?? this.exhibitId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }
}
