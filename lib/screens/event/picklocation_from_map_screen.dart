import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:provider/provider.dart';

class PickLocationFromMapScreen extends StatefulWidget {
  const PickLocationFromMapScreen({super.key});

  @override
  State<PickLocationFromMapScreen> createState() =>
      _PickLocationFromMapScreenState();
}

class _PickLocationFromMapScreenState extends State<PickLocationFromMapScreen> {
  final MapController mapController = MapController();

  LatLng? selectedLocation;
  

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
          ? Center(child: threeBounceLoading(context))
          : provider.currentLocation == null
          ? const Center(child: Text("Location not found"))
          : Stack(
        children: [
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
                    initialCenter:
                        provider.currentLocation ?? LatLng(8.5241, 76.9366),
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
                userAgentPackageName: 'com.nearvibe.app',
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
                  top: provider.isLocationOff
                      ? 100
                      : 60, // ← shift down if banner visible
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      TextField(
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
                            context.read<MapProvider>().searchLocation(
                              value,
                              // limit: "10",
                            );
                          });
                        },
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
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
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

                // After the search bar Positioned, before the Confirm button Positioned
                Positioned(
                  // top: provider.isLocationOff ? 160 : 120,
                  right: 20,
                  bottom: 150,
                  child: FloatingActionButton(
                    heroTag: 'current_location',
                    backgroundColor: context.background,
                    onPressed: () {
                      if (provider.currentLocation != null) {
                        setState(() {
                          selectedLocation = provider.currentLocation;
                        });
                        mapController.move(provider.currentLocation!, 15);
                      }
                    },
                    child: Icon(
                      Icons.my_location_rounded,
                      color: context.primary,
                    ),
                  ),
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
