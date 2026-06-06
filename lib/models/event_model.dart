import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
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

  EventModel({
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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdBy': createdBy,
      'creatorName': creatorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  EventModel copyWith({
  String? imageUrl,
}) {
  return EventModel(
    title: title,
    description: description,
    imageUrl: imageUrl ?? this.imageUrl,
    category: category,
    latitude: latitude,
    longitude: longitude,
    geohash: geohash,
    eventDate: eventDate,
    createdBy: createdBy,
    creatorName: creatorName,
  );
}
}