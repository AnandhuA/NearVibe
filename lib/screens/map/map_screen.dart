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
import 'package:near_vibe/widgets/app_shimmer.dart';
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
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                              color: Colors.black.withValues(alpha: .12),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search location",
                            // border: InputBorder.none,
                            // enabledBorder: OutlineInputBorder(
                            //   borderSide: BorderSide(color: Colors.transparent),
                            // ),
                            // focusedBorder: OutlineInputBorder(
                            //   borderSide: BorderSide(color: Colors.transparent),
                            // ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: context.primary,
                            ),
                            suffixIcon: provider.searchResults.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded),
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
                          ),
                          onChanged: (value) {
                            Future.delayed(
                              const Duration(milliseconds: 400),
                              () {
                                context.read<MapProvider>().searchLocation(
                                  value,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (provider.searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: BoxConstraints(
                            maxHeight: context.res.h(0.32),
                          ),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                                color: Colors.black.withValues(alpha: .12),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: provider.searchResults.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: context.primary.withValues(alpha: .08),
                            ),
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
                    ],
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

                Positioned(
                  right: 16,
                  top: provider.isLocationOff ? 164 : 126,
                  child: Column(
                    children: [
                      _mapControlButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          final camera = mapController.camera;
                          mapController.move(camera.center, camera.zoom + 1);
                        },
                      ),
                      const SizedBox(height: 8),
                      _mapControlButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          final camera = mapController.camera;
                          mapController.move(camera.center, camera.zoom - 1);
                        },
                      ),
                      const SizedBox(height: 8),
                      _mapControlButton(
                        icon: Icons.my_location_rounded,
                        onTap: () {
                          final location = provider.currentLocation;
                          if (location != null) {
                            mapController.move(location, 15);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                if (selectedEvent != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).size.height * 0.24 + 16,
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: context.primary.withValues(alpha: .12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                                color: Colors.black.withValues(alpha: .18),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: selectedEvent.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
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
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          getIcon(selectedEvent.category),
                                          size: 14,
                                          color: context.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            selectedEvent.category,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: context.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatEventDateWithoutYear(
                                        selectedEvent.eventDate,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: context.hitText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // ================= BOTTOM SHEET =================
                DraggableScrollableSheet(
                  initialChildSize: 0.24,
                  minChildSize: 0.16,
                  maxChildSize: 0.72,

                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .16),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: context.hitText.withValues(alpha: .35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Events Nearby",
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primary.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${events.length}",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Expanded(
                            child: events.isEmpty
                                ? Center(
                                    child: Text(
                                      "No events found near this area",
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: context.hitText,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    itemCount: events.length,
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: 12);
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.primary.withValues(alpha: .10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
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
                  height: 78,
                  width: 78,
                  fit: BoxFit.cover,

                  placeholder: (context, url) => ShimmerBox(
                    height: 78,
                    width: 78,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  errorWidget: (context, url, error) => Container(
                    height: 78,
                    width: 78,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient(context.primary),
                    ),
                    child: const Icon(Icons.broken_image_rounded, size: 50),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ================= DETAILS =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        getIcon(event.category),
                        color: context.hitText,
                        size: 18,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
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

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: context.hitText,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          formatEventDate(event.eventDate),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.hitText,
                          ),
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
            if (active) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .18),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ] else ...[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.location_on_rounded, color: color, size: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.primary.withValues(alpha: .12)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 8),
                color: Colors.black.withValues(alpha: .12),
              ),
            ],
          ),
          child: Icon(icon, color: context.primary),
        ),
      ),
    );
  }
}
