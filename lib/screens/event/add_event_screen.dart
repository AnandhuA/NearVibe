import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/dummy_data.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/app_snackbar.dart';
import 'package:near_vibe/widgets/category_widget.dart';
import 'package:near_vibe/widgets/date_time_picker_widget.dart';
import 'package:near_vibe/widgets/location_bottom_sheet_widget.dart';
import 'package:near_vibe/widgets/location_picker_widget.dart';
import 'package:near_vibe/screens/event/picklocation_from_map_screen.dart';
import 'package:provider/provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  String? selectedLocation;
  String selectedCategory = "Music";
  File? selectedImage;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  LatLng? selectedLatLng;
  DateTime? selectedDate;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: context.res.hsm,
        children: [
          Text("Create Event", style: AppTextStyles.headlineLarge),
          // SizedBox(height: context.res.hsm),
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: double.infinity,
              height: context.res.h(0.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.primary.withValues(alpha: 0.1),
                image: selectedImage != null
                    ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: selectedImage == null
                  ? Center(
                      child: Text(
                        "Add Event Photo",
                        style: AppTextStyles.labelLarge,
                      ),
                    )
                  : null,
            ),
          ),
          Text("Event Title", style: AppTextStyles.titleMedium),
          TextField(
            decoration: InputDecoration(hintText: "Event"),
            controller: titleController,
          ),
          Text("Event Description", style: AppTextStyles.titleMedium),
          TextField(
            decoration: InputDecoration(hintText: "Add Description"),
            controller: descriptionController,
          ),
          Text("Category", style: AppTextStyles.titleMedium),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dummyCategoriesList.map((category) {
              final bool isSelected = category["title"] == selectedCategory;

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
          DateTimePickerWidget(
            onDateTimeSelected: (dateTime) {
              setState(() {
                selectedDate = dateTime;
              });
            },
          ),

          LocationPickerWidget(
            selectedLocation: selectedLocation,

            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                backgroundColor: context.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),

                builder: (_) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: LocationBottomSheet(
                        onLocationSelected: (location) {
                          setState(() {
                            selectedLocation = location;
                          });
                        },
                        onPickFromMap: () async {
                          final LatLng? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PickLocationFromMapScreen(),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              selectedLatLng = result;
                              selectedLocation =
                                  "${result.latitude}, ${result.longitude}";
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          Consumer<EventProvider>(
            builder: (context, provider, _) {
              return ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => eventOnTap(provider: provider),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Add Event"),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> eventOnTap({required EventProvider provider}) async {
    try {
      if (titleController.text.trim().isEmpty) {
        AppSnackBar.warning(context, "Please enter event title");
        return;
      }

      if (descriptionController.text.trim().isEmpty) {
        AppSnackBar.warning(context, "Please enter description");
        return;
      }

      if (selectedImage == null) {
        AppSnackBar.warning(context, "Please select event image");
        return;
      }

      if (selectedLatLng == null) {
        AppSnackBar.warning(context, "Please select location");
        return;
      }

      final event = EventModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),

        imageUrl: '',

        category: selectedCategory,

        latitude: selectedLatLng!.latitude,
        longitude: selectedLatLng!.longitude,

        geohash: '',

        eventDate: selectedDate ?? DateTime.now(),

        createdBy: FirebaseAuth.instance.currentUser!.uid,

        creatorName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
      );

      await provider.createEvent(event: event, imageFile: selectedImage!);

      if (!mounted) return;

      AppSnackBar.success(context, "Event Created Successfully");

      // Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.error(context, e.toString());
    }
  }
}
