import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final String category;
  final double latitude;
  final double longitude;
  final String geohash;
  final DateTime eventDate;
  final String createdBy;
  final String creatorName;
  final Map<String, String> savedUsers;
  final String source;
  final String externalUrl;
  final String venueName;
  final String priceInfo;
  final String ticketStatus;

  const EventModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.eventDate,
    required this.createdBy,
    required this.creatorName,
    required this.savedUsers,
    this.source = 'user',
    this.externalUrl = '',
    this.venueName = '',
    this.priceInfo = '',
    this.ticketStatus = '',
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
      imageUrls: List<String>.from(
        data['imageUrls'] ?? [data['imageUrl'] ?? ''],
      ).where((url) => url.isNotEmpty).toList(),
      category: data['category'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      geohash: data['geohash'] ?? '',
      eventDate:
          (data['eventDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      creatorName: data['creatorName'] ?? '',
     savedUsers: Map<String, String>.from(
  data['savedUsers'] ?? {},
),
      source: data['source'] ?? 'user',
      externalUrl: data['externalUrl'] ?? '',
      venueName: data['venueName'] ?? '',
      priceInfo: data['priceInfo'] ?? '',
      ticketStatus: data['ticketStatus'] ?? '',
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
      imageUrls: List<String>.from(
        json['imageUrls'] ?? [json['imageUrl'] ?? ''],
      ).where((url) => url.isNotEmpty).toList(),
      category: json['category'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      geohash: json['geohash'] ?? '',
      eventDate: DateTime.tryParse(json['eventDate']?.toString() ?? '') ?? DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      creatorName: json['creatorName'] ?? '',
      savedUsers: Map<String, String>.from(json['savedUsers'] ?? {}),
      source: json['source'] ?? 'user',
      externalUrl: json['externalUrl'] ?? '',
      venueName: json['venueName'] ?? '',
      priceInfo: json['priceInfo'] ?? '',
      ticketStatus: json['ticketStatus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls.isEmpty ? [imageUrl] : imageUrls,
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
      'savedUsers': savedUsers,
      'source': source,
      'externalUrl': externalUrl,
      'venueName': venueName,
      'priceInfo': priceInfo,
      'ticketStatus': ticketStatus,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls.isEmpty ? [imageUrl] : imageUrls,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'eventDate': eventDate.toIso8601String(),
      'createdBy': createdBy,
      'creatorName': creatorName,
      'savedUsers': savedUsers,
      'source': source,
      'externalUrl': externalUrl,
      'venueName': venueName,
      'priceInfo': priceInfo,
      'ticketStatus': ticketStatus,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    String? category,
    double? latitude,
    double? longitude,
    String? geohash,
    DateTime? eventDate,
    String? createdBy,
    String? creatorName,
    Map<String,String>? savedUsers,
    String? source,
    String? externalUrl,
    String? venueName,
    String? priceInfo,
    String? ticketStatus,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      eventDate: eventDate ?? this.eventDate,
      createdBy: createdBy ?? this.createdBy,
      creatorName:
          creatorName ?? this.creatorName,
          savedUsers: savedUsers??this.savedUsers,
      source: source ?? this.source,
      externalUrl: externalUrl ?? this.externalUrl,
      venueName: venueName ?? this.venueName,
      priceInfo: priceInfo ?? this.priceInfo,
      ticketStatus: ticketStatus ?? this.ticketStatus,
    );
  }
}
