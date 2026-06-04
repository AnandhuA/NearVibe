import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLocation;

  bool isLoading = false;
    String? errorMessage;

  final Location _location = Location();

  // Future<void> getCurrentLocation() async {
  //   isLoading = true;
  //   notifyListeners();

  //   // ================= CHECK SERVICE =================

  //   bool serviceEnabled =
  //       await Geolocator.isLocationServiceEnabled();

  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();

  //     isLoading = false;
  //     notifyListeners();

  //     return;
  //   }



Future<void> getCurrentLocation() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // ================= CHECK SERVICE =================

    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      // ← This triggers the NATIVE Android popup (not settings screen)
      serviceEnabled = await _location.requestService();

      if (!serviceEnabled) {
        errorMessage = 'Location service is disabled.';
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    // ================= CHECK PERMISSION =================

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();

      return;
    }

    // ================= GET LOCATION =================

    Position position =
        await Geolocator.getCurrentPosition();

    currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    isLoading = false;

    notifyListeners();
  }
}