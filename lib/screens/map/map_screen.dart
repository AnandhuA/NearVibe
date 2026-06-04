import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<MapProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapProvider>();

    return Scaffold(
      body: provider.isLoading
          ? Center(child: threeBounceLoading(context)
            )
          : provider.currentLocation == null
          ? const Center(child: Text("Location not found"))
          : Stack(
              children: [
                // ================= MAP =================
                FlutterMap(
                  mapController: mapController,

                  options: MapOptions(
                    initialCenter: provider.currentLocation!,
                    initialZoom: 15,
                  ),

                  children: [
                    // ================= TILE LAYER =================
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName: 'com.example.near_vibe',
                    ),

                    // ================= MARKERS =================
                    MarkerLayer(
                      markers: [
                        buildMarker(
                          point: provider.currentLocation!,
                          color: context.primary,
                          active: true,
                        ),
                      ],
                    ),
                  ],
                ),

                // ================= SEARCH BAR =================
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_pin,
                        color: context.primary,
                      ),
                      hintText: "Search",
                    ),
                  ),
                ),

                // ================= BOTTOM SHEET =================
                DraggableScrollableSheet(
                  initialChildSize: 0.30,
                  minChildSize: 0.20,
                  maxChildSize: 0.80,

                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: context.background,

                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,

                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "12 Events Nearby",
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,

                              itemCount: 10,

                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 16);
                              },

                              itemBuilder: (context, index) {
                                return eventCard(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  // ================= EVENT CARD =================

  Widget eventCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1C1C28) : Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),

      child: Row(
        children: [
          // ================= IMAGE =================
          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          const SizedBox(width: 16),

          // ================= DETAILS =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.12),

                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Text(
                        "Music",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Icon(Icons.bookmark_border_rounded, color: context.hitText),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  "Indie Night Festival",
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: context.hitText,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Kakkanad • 0.5 km",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.hitText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: context.hitText,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Today • 7:30 PM",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.hitText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CUSTOM MARKER =================

  Marker buildMarker({
    required dynamic point,
    required Color color,
    bool active = false,
  }) {
    return Marker(
      point: point,

      width: 60,
      height: 60,

      child: Icon(
        Icons.location_on_rounded,
        color: color,
        size: active ? 50 : 42,
      ),
    );
  }
}
