import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/dummy_data.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/core/utils/validators.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:near_vibe/screens/event/picklocation_from_map_screen.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/app_snackbar.dart';
import 'package:near_vibe/widgets/category_widget.dart';
import 'package:near_vibe/widgets/date_time_picker_widget.dart';
import 'package:provider/provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  static const int maxImages = 5;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = "Music";
  final List<File> selectedImages = [];
  String? selectedLocation;
  LatLng? selectedLatLng;
  DateTime? selectedDate;
  Key datePickerKey = UniqueKey();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    final remainingSlots = maxImages - selectedImages.length;
    final files = images
        .take(remainingSlots)
        .map((image) => File(image.path))
        .toList();

    setState(() {
      selectedImages.addAll(files);
    });

    if (images.length > remainingSlots && mounted) {
      AppSnackBar.warning(context, "You can add up to $maxImages images");
    }
  }

  Future<void> useCurrentLocation() async {
    final provider = context.read<MapProvider>();
    await provider.getCurrentLocation();

    if (!mounted) return;

    final location = provider.currentLocation;
    if (location == null) {
      AppSnackBar.warning(
        context,
        "Enable location permission to use current location",
      );
      return;
    }

    final address = await getAddressFromLatLng(
      location.latitude,
      location.longitude,
    );

    if (!mounted) return;
    setState(() {
      selectedLatLng = location;
      selectedLocation = address;
    });
  }

  Future<void> pickFromMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationFromMapScreen()),
    );

    if (result == null || !mounted) return;

    final address = await getAddressFromLatLng(
      result.latitude,
      result.longitude,
    );

    if (!mounted) return;
    setState(() {
      selectedLatLng = result;
      selectedLocation = address;
    });
  }

  Future<void> searchLocation() async {
    final result = await showModalBottomSheet<_PickedLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _LocationSearchSheet(),
    );

    if (result == null || !mounted) return;

    setState(() {
      selectedLatLng = result.latLng;
      selectedLocation = result.name;
    });
  }

  Future<void> addFromGoogleMapLink() async {
    final result = await showDialog<_PickedLocation>(
      context: context,
      builder: (_) => const _GoogleMapLinkDialog(),
    );

    if (result == null || !mounted) return;

    setState(() {
      selectedLatLng = result.latLng;
      selectedLocation = result.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Create Event", style: AppTextStyles.headlineLarge),
            SizedBox(height: context.res.hxs),
            Text(
              "Add the essentials first. Photos, time and location make your event easier to discover.",
              style: AppTextStyles.bodyMedium.copyWith(color: context.hitText),
            ),
            SizedBox(height: context.res.hmd),

            _SectionCard(
              title: "Photos",
              subtitle: "Add up to $maxImages images",
              child: _ImagePickerSection(
                images: selectedImages,
                maxImages: maxImages,
                onAddImages: pickImages,
                onRemove: (index) {
                  setState(() {
                    selectedImages.removeAt(index);
                  });
                },
              ),
            ),

            SizedBox(height: context.res.hsm),
            _SectionCard(
              title: "Event details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    validator: AppValidator.isRequired,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Event title",
                      hintText: "Weekend concert, tech meetup...",
                    ),
                  ),
                  SizedBox(height: context.res.hsm),
                  TextFormField(
                    controller: descriptionController,
                    validator: AppValidator.isRequired,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Tell people what to expect",
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.res.hsm),
            _SectionCard(
              title: "Category",
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: dummyCategoriesList.map((category) {
                  final isSelected = category["title"] == selectedCategory;

                  return CategoryWidget(
                    title: category["title"],
                    icon: category["icon"],
                    bgColor: context.primary.withValues(alpha: 0.09),
                    isSelected: isSelected,
                    ontap: () {
                      setState(() {
                        selectedCategory = category["title"];
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: context.res.hsm),
            _SectionCard(
              title: "Date & time",
              child: DateTimePickerWidget(
                key: datePickerKey,
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    selectedDate = dateTime;
                  });
                },
              ),
            ),

            SizedBox(height: context.res.hsm),
            _SectionCard(
              title: "Location",
              subtitle: selectedLocation ?? "Choose how users will find it",
              child: Column(
                children: [
                  _LocationActionTile(
                    icon: Icons.link_rounded,
                    title: "Paste Google Maps link",
                    subtitle: "Use a link that contains coordinates",
                    onTap: addFromGoogleMapLink,
                  ),
                  SizedBox(height: context.res.hxs),
                  _LocationActionTile(
                    icon: Icons.search_rounded,
                    title: "Search location",
                    subtitle: "Search by venue or place name",
                    onTap: searchLocation,
                  ),
                  SizedBox(height: context.res.hxs),
                  _LocationActionTile(
                    icon: Icons.my_location_rounded,
                    title: "Use current location",
                    subtitle: "Quickly use where you are now",
                    onTap: useCurrentLocation,
                  ),
                  SizedBox(height: context.res.hxs),
                  _LocationActionTile(
                    icon: Icons.map_rounded,
                    title: "Pick from map",
                    subtitle: "Drop a pin manually",
                    onTap: pickFromMap,
                  ),
                  if (selectedLatLng != null) ...[
                    SizedBox(height: context.res.hsm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: context.success),
                          SizedBox(width: context.res.wxs),
                          Expanded(
                            child: Text(
                              selectedLocation ?? "Location selected",
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: context.res.hmd),
            Consumer<EventProvider>(
              builder: (context, provider, _) {
                return ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => eventOnTap(provider: provider),
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    provider.isLoading ? "Creating..." : "Create Event",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> eventOnTap({required EventProvider provider}) async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty) {
      AppSnackBar.warning(context, "Please add at least one event image");
      return;
    }

    if (selectedDate == null) {
      AppSnackBar.warning(context, "Please select event date and time");
      return;
    }

    if (selectedLatLng == null) {
      AppSnackBar.warning(context, "Please select location");
      return;
    }

    try {
      await provider.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        latitude: selectedLatLng!.latitude,
        longitude: selectedLatLng!.longitude,
        eventDate: selectedDate!,
        imageFiles: selectedImages,
      );

      if (!mounted) return;

      AppSnackBar.success(context, "Event created successfully");
      clearForm();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString());
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();

    setState(() {
      selectedImages.clear();
      selectedLatLng = null;
      selectedLocation = null;
      selectedDate = null;
      datePickerKey = UniqueKey();
      selectedCategory = "Music";
    });
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: context.hitText),
            ),
          ],
          SizedBox(height: context.res.hsm),
          child,
        ],
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final List<File> images;
  final int maxImages;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemove;

  const _ImagePickerSection({
    required this.images,
    required this.maxImages,
    required this.onAddImages,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length < maxImages ? images.length + 1 : images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final showAddButton = index == images.length && images.length < maxImages;

          if (showAddButton) {
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onAddImages,
              child: Container(
                width: 118,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, color: context.primary),
                    const SizedBox(height: 8),
                    Text(
                      "Add photos",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  images[index],
                  width: 118,
                  height: 118,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onRemove(index),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocationActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.primary),
            ),
            SizedBox(width: context.res.wsm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: context.hitText),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.primary),
          ],
        ),
      ),
    );
  }
}

class _PickedLocation {
  final String name;
  final LatLng latLng;

  const _PickedLocation({required this.name, required this.latLng});
}

class _LocationSearchSheet extends StatefulWidget {
  const _LocationSearchSheet();

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Search location", style: AppTextStyles.titleLarge),
          SizedBox(height: context.res.hsm),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: "Search venue or place",
            ),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 350), () {
                if (!mounted || controller.text != value) return;
                context.read<MapProvider>().searchLocation(value);
              });
            },
          ),
          if (provider.isSearching)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (provider.searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: context.res.h(0.35)),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: provider.searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = provider.searchResults[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.place_outlined, color: context.primary),
                    title: Text(
                      result['name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.read<MapProvider>().clearSearch();
                      Navigator.pop(
                        context,
                        _PickedLocation(
                          name: result['name'] as String,
                          latLng: LatLng(
                            result['lat'] as double,
                            result['lon'] as double,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _GoogleMapLinkDialog extends StatefulWidget {
  const _GoogleMapLinkDialog();

  @override
  State<_GoogleMapLinkDialog> createState() => _GoogleMapLinkDialogState();
}

class _GoogleMapLinkDialogState extends State<_GoogleMapLinkDialog> {
  final controller = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Google Maps link", style: AppTextStyles.titleLarge),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Paste a Google Maps link with coordinates",
          errorText: errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _apply,
          child: const Text("Use link"),
        ),
      ],
    );
  }

  Future<void> _apply() async {
    final input = controller.text.trim();
    var latLng = _parseGoogleMapsLatLng(input);
    latLng ??= await _parseExpandedGoogleMapsLink(input);

    if (latLng == null) {
      setState(() {
        errorText = "Could not find coordinates in this link";
      });
      return;
    }

    final address = await getAddressFromLatLng(latLng.latitude, latLng.longitude);
    if (!mounted) return;

    Navigator.pop(
      context,
      _PickedLocation(name: address, latLng: latLng),
    );
  }

  LatLng? _parseGoogleMapsLatLng(String value) {
    final patterns = [
      RegExp(r'@(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
      RegExp(r'[?&]query=(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
      RegExp(r'[?&]q=(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
      RegExp(r'(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(value);
      if (match == null) continue;

      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);

      if (lat == null || lng == null) continue;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;

      return LatLng(lat, lng);
    }

    return null;
  }

  Future<LatLng?> _parseExpandedGoogleMapsLink(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return null;

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 6));
      final resolvedUrl = response.request?.url.toString();

      if (resolvedUrl == null || resolvedUrl == value) return null;

      return _parseGoogleMapsLatLng(resolvedUrl);
    } catch (_) {
      return null;
    }
  }
}
