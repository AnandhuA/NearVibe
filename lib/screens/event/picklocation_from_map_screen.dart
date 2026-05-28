import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PickLocationFromMapScreen extends StatefulWidget {
  const PickLocationFromMapScreen({super.key});

  @override
  State<PickLocationFromMapScreen> createState() =>
      _PickLocationFromMapScreenState();
}

class _PickLocationFromMapScreenState extends State<PickLocationFromMapScreen> {
  final MapController mapController = MapController();

  LatLng? selectedLocation;
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
    });

    mapController.move(selectedLocation!, 15);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter: selectedLocation ?? LatLng(8.5241, 76.9366),
              initialZoom: 14,

              onTap: (_, latLng) {
                setState(() {
                  selectedLocation = latLng;
                });
              },
            ),

            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.app",
              ),

              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 50,
                      height: 50,

                      child: const Icon(
                        Icons.location_pin,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ElevatedButton(
              onPressed: selectedLocation == null
                  ? null
                  : () {
                      Navigator.pop(context, selectedLocation);
                    },

              child: const Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
