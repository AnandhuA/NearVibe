import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:near_vibe/screens/event/event_details_screen.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/widgets/app_snackbar.dart';
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

      context.read<MapProvider>().addListener(_onProviderChange);
    });
  }

  void _onProviderChange() {
    if (!mounted) return;
    final provider = context.read<MapProvider>();

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      AppSnackBar.warning(context, provider.errorMessage ?? "Error");

      provider.clearError();
    }
  }

  @override
  void dispose() {
    try {
      context.read<MapProvider>().removeListener(_onProviderChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapProvider>();
    final events = context.watch<EventProvider>().events;
    // final selectedEvent = context.watch<MapProvider>().selectedEvent;
    final selectedEvent = provider.selectedEvent;

    Offset? markerOffset;

    if (selectedEvent != null) {
      markerOffset = mapController.camera.latLngToScreenOffset(
        LatLng(selectedEvent.latitude, selectedEvent.longitude),
      );
    }
    return Scaffold(
      body: provider.isLoading
          ? Center(child: threeBounceLoading(context))
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
                    onTap: (_, _) {
                      context.read<MapProvider>().clearSelectedEvent();
                    },
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
                        // User location
                        buildMarker(
                          point: provider.currentLocation!,
                          color: context.primary,
                          active: true,
                        ),

                        // Event markers
                        ...events.asMap().entries.map((entry) {
                          final index = entry.key;
                          final event = entry.value;

                          return buildMarker(
                            point: LatLng(event.latitude, event.longitude),
                            color:
                                AppColors.markerColors[index %
                                    AppColors.markerColors.length],
                            onTap: () {
                              context.read<MapProvider>().selectEvent(event);
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // ================= SEARCH BAR =================
                Positioned(
                  top: provider.isLocationOff
                      ? 100
                      : 60, // ← shift down if banner visible
                  left: 20,
                  right: 20,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_pin,
                        color: context.primary,
                      ),
                      suffixIcon: provider.searchResults.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                context.read<MapProvider>().clearSearch();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : provider.isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
        
                      hintText: "Search",
                      
                    ),
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        context.read<MapProvider>().searchLocation(value);
                      });
                    },
                  ),
                ),

                if (provider.searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: .12),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.searchResults.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final result = provider.searchResults[i];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.place_outlined,
                            color: context.primary,
                          ),
                          title: Text(
                            result['name'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                          onTap: () {
                            final target = LatLng(
                              result['lat'] as double,
                              result['lon'] as double,
                            );
                            mapController.move(target, 15);
                            context.read<MapProvider>().clearSearch();
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),



                if (provider.isLocationOff)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Showing last known location. Turn on location for live updates.",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // ← Tap to retry
                            GestureDetector(
                              onTap: () => context
                                  .read<MapProvider>()
                                  .getCurrentLocation(),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                //==============event detail =========
                if (selectedEvent != null && markerOffset != null)
                  Positioned(
                    left: markerOffset.dx - 120,
                    top: markerOffset.dy - 120,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailsScreen(event: selectedEvent),
                          ),
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: context.res.w(0.6),
                          height: context.res.h(0.1),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.background,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withValues(alpha: .15),
                              ),
                            ],
                          ),

                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Hero(
                                  tag: 'event_${selectedEvent.id}',
                                  child: CachedNetworkImage(
                                    imageUrl: selectedEvent.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(width: context.res.wsm),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      selectedEvent.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Text(
                                      selectedEvent.category,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Text(
                                      formatEventDateWithoutYear(
                                        selectedEvent.eventDate,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            "${events.length} Events Nearby",
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,

                              itemCount: events.length,

                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 16);
                              },

                              itemBuilder: (context, index) {
                                final EventModel event = events[index];
                                return eventCard(context, event);
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

  Widget eventCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: 'event_${event.id}',
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  height: 90,

                  width: 90,
                  fit: BoxFit.cover,

                  placeholder: (context, url) => Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const CircularProgressIndicator(),
                  ),

                  errorWidget: (context, url, error) => Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(Icons.broken_image_rounded, size: 50),
                  ),
                ),
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
                          event.category,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Icon(getIcon(event.category), color: context.hitText),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    event.title,
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

                      FutureBuilder<String>(
                        future: getAddressFromLatLng(
                          event.latitude,
                          event.longitude,
                        ),
                        builder: (context, snapshot) {
                          return Expanded(
                            child: Text(
                              snapshot.data ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.hitText,
                              ),
                            ),
                          );
                        },
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
                        formatEventDate(event.eventDate),
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
      ),
    );
  }

  // ================= CUSTOM MARKER =================

  Marker buildMarker({
    required LatLng point,
    required Color color,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!active)
              Icon(
                Icons.location_on_rounded,
                color: color,
                size: active ? 52 : 44,
              ),

            if (active) Icon(Icons.my_location, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  //======ON TAP ON MARKER ====
  void showEventDetails(EventModel event) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: AppTextStyles.headlineSmall),

              const SizedBox(height: 10),

              Text(event.description),

              const SizedBox(height: 10),

              Text("Category: ${event.category}"),

              Text("Created By: ${event.creatorName}"),

              Text(event.eventDate.toString()),
            ],
          ),
        );
      },
    );
  }
}
