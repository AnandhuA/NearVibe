import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= MAP =================
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(9.9312, 76.2673),
              initialZoom: 13,
            ),

            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nearvibe.app',
              ),

              MarkerLayer(
                markers: [
                  buildMarker(
                    point: LatLng(9.935, 76.26),
                    color: const Color(0xFF8B5CF6),
                  ),

                  buildMarker(
                    point: LatLng(9.928, 76.275),
                    color: const Color(0xFF22C55E),
                  ),

                  buildMarker(
                    point: LatLng(9.94, 76.28),
                    color: const Color(0xFFE91E63),
                  ),

                  buildMarker(
                    point: LatLng(9.932, 76.268),
                    color: const Color(0xFFF59E0B),
                    active: true,
                  ),
                ],
              ),
            ],
          ),

          // ================= LOCATION =================
          Positioned(
            top: 60,
            left: 20,
            right: 20,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

              decoration: BoxDecoration(
                color: const Color(0xFF1C1C28),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                "Kochi, Kerala",
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ================= BOTTOM PANEL =================
          Align(
            alignment: Alignment.bottomCenter,

            child: Container(
              height: 270,

              padding: const EdgeInsets.all(24),

              decoration: const BoxDecoration(
                color: Color(0xFF0F0F14),

                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,

                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "12 Events Near You",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 120,

                    child: ListView(
                      scrollDirection: Axis.horizontal,

                      children: [
                        eventCard(
                          color: const Color(0xFF8B5CF6),
                          category: "Music",
                          title: "Indie Night Live",
                          distance: "0.5km • 9 PM",
                        ),

                        const SizedBox(width: 14),

                        eventCard(
                          color: const Color(0xFF22C55E),
                          category: "Tech",
                          title: "Founder Meetup",
                          distance: "1.1km • 7 PM",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EVENT CARD =================

  Widget eventCard({
    required Color color,
    required String category,
    required String title,
    required String distance,
  }) {
    return Container(
      width: 180,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),

              const SizedBox(width: 8),

              Text(
                category,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(distance, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // ================= CUSTOM MARKER =================

  Marker buildMarker({
    required LatLng point,
    required Color color,
    bool active = false,
  }) {
    return Marker(
      point: point,

      width: 50,
      height: 50,

      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.8,

            child: Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (active)
            const CircleAvatar(radius: 5, backgroundColor: Colors.white),
        ],
      ),
    );
  }
}
