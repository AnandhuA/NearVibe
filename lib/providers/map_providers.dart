import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
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


  // ================= CLEAR ERROR =================

void clearError() {
  errorMessage = null;
  notifyListeners();
}
 
}