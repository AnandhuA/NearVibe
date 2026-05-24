import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLocation;

  bool isLoading = false;

  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    // ================= CHECK SERVICE =================

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      isLoading = false;
      notifyListeners();

      return;
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