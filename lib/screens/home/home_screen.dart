import 'dart:developer';
import 'dart:math' as math;

import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/dummy_data.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/models/user_model.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:near_vibe/providers/user_provider.dart';
import 'package:near_vibe/screens/event/event_details_screen.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/card_widget.dart';
import 'package:near_vibe/widgets/category_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  String? selectedDistance;
  bool _isInitialNearbyLoad = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(_loadEvents);
  }

  Future<void> _loadEvents() async {
    try {
      final mapProvider = context.read<MapProvider>();
      await mapProvider.getCurrentLocation();
      if (!mounted) return;
      final events = context.read<EventProvider>();
      await events.fetchEvents();
      final location = mapProvider.currentLocation;
      log("current location $location");
      if (location != null) {
        log("calling");
        await events.fetchNearbyExternalEvents(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }
    } finally {
      if (mounted) setState(() => _isInitialNearbyLoad = false);
    }
  }

  List<EventModel> filterEventsByCategoryAndDistance(
    List<EventModel> events,
    String? category,
    String? distance,
  ) {
    List<EventModel> filteredEvents = events;

    if (category == null || category == "All") {
      filteredEvents = events;
    } else {
      filteredEvents = events
          .where((event) => event.category == category)
          .toList();
    }

    // if (distance != null) {
    //   final distanceInMeters =
    //       double.tryParse(distance.replaceAll('km', '')) * 1000;
    //   if (distanceInMeters > 0) {
    //     filteredEvents = filteredEvents.where((event) {
    //       final distanceToEvent = calculateDistance(
    //         mapProvider.currentLocation!.latitude,
    //         mapProvider.currentLocation!.longitude,
    //         event.latitude,
    //         event.longitude,
    //       );
    //       return distanceToEvent <= distanceInMeters;
    //     }).toList();
    //   }
    // }

    return filteredEvents;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371; // Radius of the earth in km
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return R * c; // Distance in km
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<UserProvider, UserModel?>((p) => p.user);
    final events = context.select<EventProvider, List<EventModel>>(
      (p) => p.events,
    );

    final isLoading =
        _isInitialNearbyLoad || context.select<EventProvider, bool>((p) => p.isLoading);
    return AppScaffold(
      scrollable: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HelperFuntions.getGreeting(),
              style: AppTextStyles.titleMedium,
            ),
            Text(
              user != null
                  ? "Hey, ${user.name.split(' ').first}!"
                  : "What's Nearby",
              style: AppTextStyles.titleLarge,
            ),
          ],
        ),
        actions: [
          ClipOval(
            child: user != null
                ? (user.avatarUrl.isNotEmpty
                      ? Image.network(
                          user.avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : AvatarPlus(
                          user.name.toLowerCase(),
                          width: 40,
                          height: 40,
                        ))
                : CircleAvatar(
                    radius: 19,
                    backgroundColor: context.primary,
                    child: Text("?", style: AppTextStyles.bodyLarge),
                  ),
          ),
          SizedBox(width: context.res.wsm),
        ],
      ),
      child: Column(
        children: [
          Consumer<MapProvider>(
            builder: (context, mapProvider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: context.res.h(0.06),
                width: context.res.width,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    Icon(Icons.location_on, color: context.primary),

                    SizedBox(width: context.res.wsm),

                    Expanded(
                      child: mapProvider.currentLocation == null
                          ? Text(
                              "Getting location...",
                              style: AppTextStyles.bodyMedium,
                            )
                          : FutureBuilder<String>(
                              future: getAddressFromLatLng(
                                mapProvider.currentLocation!.latitude,
                                mapProvider.currentLocation!.longitude,
                              ),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? "Loading...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium,
                                );
                              },
                            ),
                    ),

                    // Distance Filter
                    DropdownButton<String>(
                      value: selectedDistance,
                      items: [
                        DropdownMenuItem(value: "1km", child: Text("1km")),
                        DropdownMenuItem(value: "5km", child: Text("5km")),
                        DropdownMenuItem(value: "10km", child: Text("10km")),
                        DropdownMenuItem(value: "20km", child: Text("20km")),
                        DropdownMenuItem(value: "All", child: Text("All")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDistance = value;
                        });
                      },
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 2,
                      style: TextStyle(color: Colors.black),
                      underline: Container(height: 0),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            height: context.res.h(0.08),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dummyCategoriesList.length,
              itemBuilder: (context, index) {
                final isAll = index == 0;

                final category = isAll
                    ? {"title": "All"}
                    : dummyCategoriesList[index - 1];
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedCategory = category["title"];
                  }),
                  child: CategoryWidget(
                    icon: category["icon"],
                    title: category["title"],
                    bgColor: context.primary.withValues(alpha: 0.09),
                    isSelected: category["title"] == selectedCategory,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: context.res.hxs),
          if (isLoading)
            Center(child: threeBounceLoading(context))
          else if (events.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.res.hlg),
              child: Text("No Events Found", style: AppTextStyles.bodyLarge),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filterEventsByCategoryAndDistance(
                events,
                selectedCategory,
                selectedDistance,
              ).length,
              separatorBuilder: (_, _) => SizedBox(height: context.res.hsm),
              itemBuilder: (context, index) {
                final event = filterEventsByCategoryAndDistance(
                  events,
                  selectedCategory,
                  selectedDistance,
                )[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: event),
                    ),
                  ),
                  child: CardWidget(event: event),
                );
              },
            ),
        ],
      ),
    );
  }
}
