import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/repositories/event_repository.dart';
import 'package:near_vibe/repositories/external_event_repository.dart';
import 'package:near_vibe/repositories/local_storage_repository.dart';
import 'package:near_vibe/repositories/upload_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository repository;
  final UploadRepository uploadRepository;
  final LocalStorageRepository localStorageRepository;
  final ExternalEventRepository externalEventRepository;

  EventProvider(
    this.repository,
    this.uploadRepository,
    this.localStorageRepository,
    ExternalEventRepository? externalEventRepository,
  ) : externalEventRepository =
          externalEventRepository ?? ExternalEventRepository();

  List<EventModel> _userEvents = [];
  List<EventModel> _externalEvents = [];

  List<EventModel> get events =>
      [..._userEvents, ..._externalEvents]
        ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  bool _isLoading = false;
  String? _error;
  bool _didCleanupPastEvents = false;

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
    required List<File> imageFiles,
    // required File imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      //fetch user data
      final user = await localStorageRepository.getUser();
      // Upload images
      final imageUrls = await uploadRepository.uploadImages(imageFiles);
      // add location hash
      final geoPoint = GeoFirePoint(GeoPoint(latitude, longitude));

      final event = EventModel(
        title: title,
        description: description,
        imageUrl: imageUrls.first,
        imageUrls: imageUrls,
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

  Future<void> cleanupPastEvents() async {
    if (_didCleanupPastEvents) return;

    try {
      _didCleanupPastEvents = true;
      final deletedCount = await repository.deletePastEvents();
      if (deletedCount > 0) {
        log('[Events] Deleted $deletedCount past events.');
      }
    } catch (e) {
      _error = e.toString();
      log('[Events] Past-event cleanup error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _eventSubscription?.cancel();

      _eventSubscription = repository.getEvents().listen((events) {
        _userEvents = events;

        _isLoading = false;

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();

      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> fetchNearbyExternalEvents({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
  }) async {
    try {
      _externalEvents = await externalEventRepository.getNearbyEvents(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      log("$_externalEvents");
    } catch (e) {
      // Community events remain available if the provider is temporarily down.
      _error = e.toString();
      log('[Ticketmaster] Nearby-event fetch error: $e');
    } finally {
      notifyListeners();
    }
  }

  //===== ADD SAVED EVENT =====
  Future<void> saveEvent(EventModel event) async {
    try {
      final user = await localStorageRepository.getUser();
      log("$user");
      if (user == null) return;

      await repository.saveEvent(
        userId: user.id,
        userName: user.name,
        event: event,
      );
      _savedEventIds.add(event.id);
    } catch (e) {
      _error = e.toString();

      notifyListeners();
    }
  }

  //==== REMOVE SAVED EVENT ====
  Future<void> unsaveEvent(EventModel event) async {
    log("unsave work ");
    try {
      final user = await localStorageRepository.getUser();

      if (user == null) return;

      await repository.removeSavedEvent(userId: user.id, event: event);
      _savedEventIds.remove(event.id);
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
