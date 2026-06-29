import 'dart:developer';
import 'dart:math' as math;

import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
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
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/app_shimmer.dart';
import 'package:near_vibe/widgets/card_widget.dart';
import 'package:near_vibe/widgets/category_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> distanceOptions = [
    "50km",
    "100km",
    "150km",
    "200km",
    "Custom",
  ];

  String? selectedCategory = "All";
  String? selectedDistance = "100km";
  String selectedDateFilter = "Upcoming";
  DateTime? customFilterDate;
  double? customDistanceKm;
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
      await events.cleanupPastEvents();
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

  List<EventModel> filterEvents(
    List<EventModel> events,
    String? category,
    String? distance,
    String dateFilter,
    DateTime? customDate,
    LatLng? currentLocation,
  ) {
    List<EventModel> filteredEvents = events;

    if (category == null || category == "All") {
      filteredEvents = events;
    } else {
      filteredEvents = events
          .where((event) => event.category == category)
          .toList();
    }

    if (distance != null && currentLocation != null) {
      final distanceInKm = distance == "Custom"
          ? customDistanceKm
          : double.tryParse(distance.replaceAll('km', ''));

      if (distanceInKm != null) {
        filteredEvents = filteredEvents.where((event) {
          final distanceToEvent = calculateDistance(
            currentLocation.latitude,
            currentLocation.longitude,
            event.latitude,
            event.longitude,
          );

          return distanceToEvent <= distanceInKm;
        }).toList();
      }
    }

    filteredEvents = filteredEvents.where((event) {
      return _matchesDateFilter(event.eventDate, dateFilter, customDate);
    }).toList();

    return filteredEvents;
  }

  bool _matchesDateFilter(
    DateTime eventDate,
    String dateFilter,
    DateTime? customDate,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    return switch (dateFilter) {
      "Upcoming" => eventDate.isAfter(now),
      "Today" => eventDay == today,
      "Tomorrow" => eventDay == today.add(const Duration(days: 1)),
      "This week" =>
        !eventDay.isBefore(today) &&
            eventDay.isBefore(today.add(const Duration(days: 7))),
      "Custom" =>
        customDate != null &&
            eventDay ==
                DateTime(customDate.year, customDate.month, customDate.day),
      _ => true,
    };
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
    final currentLocation = context.select<MapProvider, LatLng?>(
      (p) => p.currentLocation,
    );
    final filteredEvents = filterEvents(
      events,
      selectedCategory,
      selectedDistance,
      selectedDateFilter,
      customFilterDate,
      currentLocation,
    );

    final isLoading =
        _isInitialNearbyLoad ||
        context.select<EventProvider, bool>((p) => p.isLoading);
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
              final locationWidth = math.min(context.res.w(0.40), 158.0);

              return Row(
                children: [
                  SizedBox(
                    width: locationWidth,
                    child: _HomeFilterChipShell(
                      icon: Icons.location_on_rounded,
                      label: mapProvider.currentLocation == null
                          ? "Location"
                          : null,
                      child: mapProvider.currentLocation == null
                          ? null
                          : FutureBuilder<String>(
                              future: getAddressFromLatLng(
                                mapProvider.currentLocation!.latitude,
                                mapProvider.currentLocation!.longitude,
                              ),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? "Location",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  SizedBox(width: context.res.wsm),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: _DateFilterButton(
                            compact: true,
                            value: selectedDateFilter,
                            customDate: customFilterDate,
                            onSelected: (value, customDate) {
                              setState(() {
                                selectedDateFilter = value;
                                if (customDate != null) {
                                  customFilterDate = customDate;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          flex: 3,
                          child: _DistanceFilterButton(
                            compact: true,
                            value: selectedDistance ?? "100km",
                            customDistanceKm: customDistanceKm,
                            options: distanceOptions,
                            onSelected: (value, customValue) {
                              setState(() {
                                selectedDistance = value;
                                if (customValue != null) {
                                  customDistanceKm = customValue;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            height: context.res.h(0.06),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: dummyCategoriesList.length + 1,
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
            const HomeEventShimmer()
          else if (events.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.res.hlg),
              child: Text("No Events Found", style: AppTextStyles.bodyLarge),
            )
          else if (filteredEvents.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.res.hlg),
              child: Text(
                "No matching events",
                style: AppTextStyles.bodyLarge.copyWith(color: context.hitText),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              separatorBuilder: (_, _) => SizedBox(height: context.res.hsm),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
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

class _HomeFilterChipShell extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Widget? child;

  const _HomeFilterChipShell({required this.icon, this.label, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.primary),
          const SizedBox(width: 4),
          Expanded(
            child:
                child ??
                Text(
                  label ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _DistanceFilterButton extends StatelessWidget {
  final String value;
  final double? customDistanceKm;
  final List<String> options;
  final void Function(String value, double? customDistanceKm) onSelected;
  final bool compact;

  const _DistanceFilterButton({
    required this.value,
    required this.customDistanceKm,
    required this.options,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: "Distance",
      color: context.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      offset: const Offset(0, 44),
      onSelected: (option) async {
        if (option == "Custom") {
          final customValue = await _showCustomDistanceDialog(context);
          if (!context.mounted || customValue == null) return;
          onSelected(option, customValue);
          return;
        }

        onSelected(option, null);
      },
      itemBuilder: (context) {
        return options.map((option) {
          final isSelected = option == value;

          return PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isSelected ? null : context.hitText,
                ),
                const SizedBox(width: 10),
                Text(
                  option == "Custom" && customDistanceKm != null
                      ? "Custom (${_formatDistance(customDistanceKm!)}km)"
                      : option,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? null : context.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: compact ? 74 : 0,
          maxWidth: compact ? 96 : double.infinity,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: compact ? 13 : 18,
              color: context.primary,
            ),
            SizedBox(width: compact ? 4 : 6),
            Expanded(
              child: Text(
                _label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? AppTextStyles.bodySmall
                            : AppTextStyles.bodyMedium)
                        .copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w700,
                        ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: context.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _label {
    if (value == "Custom" && customDistanceKm != null) {
      return "${_formatDistance(customDistanceKm!)}km";
    }

    return value;
  }

  String _formatDistance(double distance) {
    return distance % 1 == 0
        ? distance.toStringAsFixed(0)
        : distance.toStringAsFixed(1);
  }

  Future<double?> _showCustomDistanceDialog(BuildContext context) async {
    return showDialog<double>(
      context: context,
      builder: (_) => _CustomDistanceDialog(
        initialDistance: customDistanceKm,
        formatDistance: _formatDistance,
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  static const List<String> options = [
    "Upcoming",
    "Today",
    "Tomorrow",
    "This week",
    "Custom",
  ];

  final String value;
  final DateTime? customDate;
  final void Function(String value, DateTime? customDate) onSelected;
  final bool compact;

  const _DateFilterButton({
    required this.value,
    required this.customDate,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: "Date",
      color: context.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      offset: const Offset(0, 44),
      onSelected: (option) async {
        if (option == "Custom") {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: customDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );

          if (!context.mounted || pickedDate == null) return;
          onSelected(option, pickedDate);
          return;
        }

        onSelected(option, null);
      },
      itemBuilder: (context) {
        return options.map((option) {
          final isSelected = option == value;

          return PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isSelected ? context.primary : context.hitText,
                ),
                const SizedBox(width: 10),
                Text(
                  option == "Custom" && customDate != null
                      ? DateFormat('dd MMM yyyy').format(customDate!)
                      : option,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? context.primary : context.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: compact ? 88 : 0,
          maxWidth: compact ? 118 : double.infinity,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: compact ? 13 : 18,
              color: context.primary,
            ),
            SizedBox(width: compact ? 4 : 6),
            Expanded(
              child: Text(
                _label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? AppTextStyles.bodySmall
                            : AppTextStyles.bodyMedium)
                        .copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w700,
                        ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: context.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _label {
    if (value == "Custom" && customDate != null) {
      return DateFormat('dd MMM').format(customDate!);
    }

    return value;
  }
}

class _CustomDistanceDialog extends StatefulWidget {
  final double? initialDistance;
  final String Function(double distance) formatDistance;

  const _CustomDistanceDialog({
    required this.initialDistance,
    required this.formatDistance,
  });

  @override
  State<_CustomDistanceDialog> createState() => _CustomDistanceDialogState();
}

class _CustomDistanceDialogState extends State<_CustomDistanceDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialDistance == null
          ? ""
          : widget.formatDistance(widget.initialDistance!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Custom distance", style: AppTextStyles.titleLarge),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: context.text),
        decoration: InputDecoration(
          hintText: "Enter distance in km",
          suffixText: "km",
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _apply, child: const Text("Apply")),
      ],
    );
  }

  void _apply() {
    final value = double.tryParse(_controller.text.trim());

    if (value == null || value <= 0) {
      setState(() {
        _errorText = "Enter valid km";
      });
      return;
    }

    Navigator.pop(context, value);
  }
}
