import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final double latitude;
  final double longitude;
  final String geohash;
  final DateTime eventDate;
  final String createdBy;
  final String creatorName;

  const EventModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.eventDate,
    required this.createdBy,
    required this.creatorName,
  });

  factory EventModel.fromDocument(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      geohash: data['geohash'] ?? '',
      eventDate:
          (data['eventDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      creatorName: data['creatorName'] ?? '',
    );
  }

  factory EventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      geohash: json['geohash'] ?? '',
      eventDate: DateTime.parse(
        json['eventDate'],
      ),
      createdBy: json['createdBy'] ?? '',
      creatorName: json['creatorName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'eventDate': Timestamp.fromDate(
        eventDate,
      ),
      'createdBy': createdBy,
      'creatorName': creatorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'eventDate': eventDate.toIso8601String(),
      'createdBy': createdBy,
      'creatorName': creatorName,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    double? latitude,
    double? longitude,
    String? geohash,
    DateTime? eventDate,
    String? createdBy,
    String? creatorName,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      eventDate: eventDate ?? this.eventDate,
      createdBy: createdBy ?? this.createdBy,
      creatorName:
          creatorName ?? this.creatorName,
    );
  }
}