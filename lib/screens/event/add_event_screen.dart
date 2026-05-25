import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/dummy_data.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';
import 'package:near_vibe/core/widgets/category_widget.dart';
import 'package:near_vibe/core/widgets/date_time_picker_widget.dart';
import 'package:near_vibe/core/widgets/location_bottom_sheet_widget.dart';
import 'package:near_vibe/core/widgets/location_picker_widget.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  String? selectedLocation;
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
          Container(
            width: double.infinity,
            height: context.res.h(0.2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text("Add Event Photo", style: AppTextStyles.labelLarge),
            ),
          ),
          Text("Event Title", style: AppTextStyles.titleMedium),
          TextField(decoration: InputDecoration(hintText: "Event")),
          Text("Category", style: AppTextStyles.titleMedium),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dummyCategoriesList.map((category) {
              final bool isSelected = category["title"] == "Music";

              return CategoryWidget(
                title: category["title"],
                icon: category["icon"],
                bgColor: context.primary.withValues(alpha: 0.09),
                isSelected: isSelected,
              );
            }).toList(),
          ),
          DateTimePickerWidget(),

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
                      ),
                    ),
                  );
                },
              );
            },
          ),

          ElevatedButton(onPressed: () {}, child: Text("Add Event")),
        ],
      ),
    );
  }
}
