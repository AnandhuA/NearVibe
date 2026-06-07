import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/repositories/event_repository.dart';
import 'package:near_vibe/repositories/local_storage_repository.dart';
import 'package:near_vibe/repositories/upload_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository repository;
  final UploadRepository uploadRepository;
  final LocalStorageRepository localStorageRepository;

  EventProvider(
    this.repository,
    this.uploadRepository,
    this.localStorageRepository,
  );

  List<EventModel> _events = [];

  List<EventModel> get events => _events;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription? _eventSubscription;

  //=== CREATE EVENT ==========
  Future<void> createEvent({
    // required EventModel event,
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required DateTime eventDate,
    required File imageFile,
    // required File imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      //fetch user data
      final user = await localStorageRepository.getUser();
      // Upload image
      final imageUrl = await uploadRepository.uploadImage(imageFile);
      // add location hash
      final geoPoint = GeoFirePoint(GeoPoint(latitude, longitude));

      final event = EventModel(
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: category,

        latitude: latitude,
        longitude: longitude,
        geohash: geoPoint.geohash,

        eventDate: eventDate,

        createdBy: user?.id ?? "id null",
        creatorName: user?.name ?? "User",
      );

      // Save event
      await repository.addEvent(event);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //=====GET ALL EVENTS ============

  Future<void> fetchEvents() async {
    log("work");
    _isLoading = true;
    notifyListeners();

    try {
      _eventSubscription?.cancel();

      _eventSubscription = repository.getEvents().listen((events) {
        _events = events;

        _isLoading = false;

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();

      _isLoading = false;

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
