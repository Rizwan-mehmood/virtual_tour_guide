import 'package:cloud_firestore/cloud_firestore.dart';

class CrowdData {
  final String id;
  final DateTime timestamp;
  final int totalVisitors;
  final Map<String, int> visitorsBySection;
  final Map<String, List<CrowdTimeData>> crowdForecast;

  CrowdData({
    this.id = '',
    required this.timestamp,
    required this.totalVisitors,
    required this.visitorsBySection,
    required this.crowdForecast,
  });

  // Factory constructor to create a CrowdData from a Map
  factory CrowdData.fromMap(Map<String, dynamic> map, String documentId) {
    return CrowdData(
      id: documentId,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      totalVisitors: map['totalVisitors'] ?? 0,
      visitorsBySection: Map<String, int>.from(map['visitorsBySection'] ?? {}),
      crowdForecast: _parseCrowdForecast(map['crowdForecast'] ?? {}),
    );
  }

  static Map<String, List<CrowdTimeData>> _parseCrowdForecast(
    Map<String, dynamic> forecastMap,
  ) {
    Map<String, List<CrowdTimeData>> result = {};

    forecastMap.forEach((key, value) {
      if (value is List) {
        result[key] =
            value
                .map(
                  (item) => CrowdTimeData.fromMap(item as Map<String, dynamic>),
                )
                .toList();
      } else {
        result[key] = [];
      }
    });

    return result;
  }

  // Convert a CrowdData to a Map
  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'totalVisitors': totalVisitors,
      'visitorsBySection': visitorsBySection,
      'crowdForecast': _crowdForecastToMap(),
    };
  }

  Map<String, dynamic> _crowdForecastToMap() {
    Map<String, dynamic> result = {};

    crowdForecast.forEach((key, value) {
      result[key] = value.map((item) => item.toMap()).toList();
    });

    return result;
  }

  // Create a copy of the CrowdData with specified fields updated
  CrowdData copyWith({
    String? id,
    DateTime? timestamp,
    int? totalVisitors,
    Map<String, int>? visitorsBySection,
    Map<String, List<CrowdTimeData>>? crowdForecast,
  }) {
    return CrowdData(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      totalVisitors: totalVisitors ?? this.totalVisitors,
      visitorsBySection: visitorsBySection ?? this.visitorsBySection,
      crowdForecast: crowdForecast ?? this.crowdForecast,
    );
  }
}

class CrowdTimeData {
  final String timeSlot; // e.g., "09:00-10:00"
  final int expectedVisitors;
  final String crowdLevel; // "Low", "Medium", "High"

  CrowdTimeData({
    required this.timeSlot,
    required this.expectedVisitors,
    required this.crowdLevel,
  });

  // Factory constructor to create a CrowdTimeData from a Map
  factory CrowdTimeData.fromMap(Map<String, dynamic> map) {
    return CrowdTimeData(
      timeSlot: map['timeSlot'] ?? '',
      expectedVisitors: map['expectedVisitors'] ?? 0,
      crowdLevel: map['crowdLevel'] ?? 'Low',
    );
  }

  // Convert a CrowdTimeData to a Map
  Map<String, dynamic> toMap() {
    return {
      'timeSlot': timeSlot,
      'expectedVisitors': expectedVisitors,
      'crowdLevel': crowdLevel,
    };
  }
}
