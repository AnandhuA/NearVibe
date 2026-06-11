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

  List<EventModel> _savedEvents = [];
  final Set<String> _savedEventIds = {};

  List<EventModel> get savedEvents => _savedEvents;

  StreamSubscription? _savedEventSubscription;

  bool isEventSaved(String eventId) {
    return _savedEventIds.contains(eventId);
  }

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
        savedUsers: {},
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

  //===== ADD SAVED EVENT =====
  Future<void> saveEvent(String eventId) async {
    try {
      final user = await localStorageRepository.getUser();
      log("$user");
      if (user == null) return;

      await repository.saveEvent(
        userId: user.id,
        eventId: eventId,
        userName: user.name,
      );
      _savedEventIds.add(eventId);
    } catch (e) {
      _error = e.toString();

      notifyListeners();
    }
  }

  //==== REMOVE SAVED EVENT ====
  Future<void> unsaveEvent(String eventId) async {
    log("unsave work ");
    try {
      final user = await localStorageRepository.getUser();

      if (user == null) return;

      await repository.removeSavedEvent(userId: user.id, eventId: eventId);
      _savedEventIds.remove(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  //=== FETCH ALL SAVED EVENTS =====
  Future<void> fetchSavedEvents() async {
    try {
      final user = await localStorageRepository.getUser();

      if (user == null) return;

      _savedEventSubscription?.cancel();

      _savedEventSubscription = repository.getSavedEvents(user.id).listen((
        events,
      ) {
        _savedEvents = events;
        _savedEventIds.clear();

        _savedEventIds.addAll(events.map((e) => e.id));

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  //===CLEAR ERROR ===
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _savedEventSubscription?.cancel();
    super.dispose();
  }
}
