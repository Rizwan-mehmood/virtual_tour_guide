import 'package:cloud_firestore/cloud_firestore.dart';

class Tour {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime tourDate;
  final DateTime createdAt;
  final List<TourExhibit> exhibits;
  final bool isCancelled;
  final int durationMinutes;

  Tour({
    this.id = '',
    required this.userId,
    required this.title,
    required this.description,
    required this.tourDate,
    required this.exhibits,
    required this.createdAt,
    this.isCancelled = false,
    this.durationMinutes = 60,
  });

  // Factory constructor to create a Tour from a Map
  factory Tour.fromMap(Map<String, dynamic> map, String documentId) {
    return Tour(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tourDate: (map['tourDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      exhibits: List<TourExhibit>.from(
        (map['exhibits'] as List<dynamic>? ?? []).map(
          (x) => TourExhibit.fromMap(x as Map<String, dynamic>),
        ),
      ),
      isCancelled: map['isCancelled'] ?? false,
      durationMinutes: map['durationMinutes'] ?? 60,
    );
  }

  // Convert a Tour to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'tourDate': Timestamp.fromDate(tourDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'exhibits': exhibits.map((x) => x.toMap()).toList(),
      'isCancelled': isCancelled,
      'durationMinutes': durationMinutes,
    };
  }

  // Create a copy of the Tour with specified fields updated
  Tour copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? tourDate,
    DateTime? createdAt,
    List<TourExhibit>? exhibits,
    bool? isCancelled,
    int? durationMinutes,
  }) {
    return Tour(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      tourDate: tourDate ?? this.tourDate,
      createdAt: createdAt ?? this.createdAt,
      exhibits: exhibits ?? this.exhibits,
      isCancelled: isCancelled ?? this.isCancelled,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

class TourExhibit {
  final String exhibitId;
  final String name;
  final String imageUrl;
  final int orderIndex;
  final int visitDurationMinutes;

  TourExhibit({
    required this.exhibitId,
    required this.name,
    required this.imageUrl,
    required this.orderIndex,
    this.visitDurationMinutes = 15,
  });

  // Factory constructor to create a TourExhibit from a Map
  factory TourExhibit.fromMap(Map<String, dynamic> map) {
    return TourExhibit(
      exhibitId: map['exhibitId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
      visitDurationMinutes: map['visitDurationMinutes'] ?? 15,
    );
  }

  // Convert a TourExhibit to a Map
  Map<String, dynamic> toMap() {
    return {
      'exhibitId': exhibitId,
      'name': name,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
      'visitDurationMinutes': visitDurationMinutes,
    };
  }

  // Create a copy of the TourExhibit with specified fields updated
  TourExhibit copyWith({
    String? exhibitId,
    String? name,
    String? imageUrl,
    int? orderIndex,
    int? visitDurationMinutes,
  }) {
    return TourExhibit(
      exhibitId: exhibitId ?? this.exhibitId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      orderIndex: orderIndex ?? this.orderIndex,
      visitDurationMinutes: visitDurationMinutes ?? this.visitDurationMinutes,
    );
  }
}
