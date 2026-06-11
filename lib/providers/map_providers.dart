import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLocation;

  bool isLoading = false;
  String? errorMessage;

  final Location _location = Location();
  SharedPreferences? _prefs;
  static const String _latKey = 'cached_lat';
  static const String _lngKey = 'cached_lng';
  bool isLocationOff = false;
  EventModel? _selectedEvent;
  EventModel? get selectedEvent => _selectedEvent;

  LatLng? get selectedEventLocation => _selectedEvent == null
      ? null
      : LatLng(_selectedEvent!.latitude, _selectedEvent!.longitude);


  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  // ================= INIT PREFS ONCE =================

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ================= LOAD CACHED LOCATION =================
  Future<void> loadCachedLocation() async {
    await _initPrefs();
    final lat = _prefs!.getDouble(_latKey);
    final lng = _prefs!.getDouble(_lngKey);

    if (lat != null && lng != null) {
      currentLocation = LatLng(lat, lng);
      notifyListeners(); // ← show cached location instantly
    }
  }

  Future<void> _cacheLocation(LatLng location) async {
    await _initPrefs();
    await _prefs!.setDouble(_latKey, location.latitude);
    await _prefs!.setDouble(_lngKey, location.longitude);
  }

  Future<void> getCurrentLocation() async {
    isLocationOff = false;
    errorMessage = null;

    // ← Load cache first before showing loader
    await loadCachedLocation();

    if (currentLocation == null) {
      isLoading = true;
      notifyListeners();
    }

    // ================= CHECK SERVICE =================

    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      // ← This triggers the NATIVE Android popup (not settings screen)
      serviceEnabled = await _location.requestService();

      if (!serviceEnabled) {
        isLocationOff = true;
        errorMessage = 'Location service is disabled.';
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    // ================= CHECK PERMISSION =================

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      isLocationOff = true;
      isLoading = false;
      errorMessage = 'permission_denied_forever'; // ← special key
      notifyListeners();
      return;
    }

    if (permission == LocationPermission.denied) {
      isLocationOff = true;
      isLoading = false;
      errorMessage = 'permission_denied';
      notifyListeners();
      return;
    }
    // ================= GET LOCATION =================

    Position position = await Geolocator.getCurrentPosition();

    currentLocation = LatLng(position.latitude, position.longitude);
    await _cacheLocation(currentLocation!);
    isLoading = false;
    isLocationOff = false;
    notifyListeners();
  }

  //=====
  void selectEvent(EventModel event) {
    _selectedEvent = event;
    notifyListeners();
  }

  //============
  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }


//=====LOCATION SEARCH =====
  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'NearVibe/1.0 (com.example.near_vibe)'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        searchResults = data
            .map<Map<String, dynamic>>(
              (e) => {
                'name': e['display_name'] as String,
                'lat': double.parse(e['lat'] as String),
                'lon': double.parse(e['lon'] as String),
              },
            )
            .toList();
      }
    } catch (_) {
      searchResults = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  //====CLEAR SEACH =====
  void clearSearch() {
    searchResults = [];
    notifyListeners();
  }

  // ================= CLEAR ERROR =================

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
