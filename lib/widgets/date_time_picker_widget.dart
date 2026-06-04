import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class DateTimePickerWidget extends StatefulWidget {
  const DateTimePickerWidget({super.key});

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await pickDate(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.primary.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: context.primary),

                  SizedBox(width: context.res.wsm),

                  Text(
                    selectedDate == null
                        ? "May 24"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: context.res.wsm),

        Expanded(
          child: GestureDetector(
            onTap: () async {
              await pickTime(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.primary.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: context.primary,
                  ),

                  SizedBox(width: context.res.wsm),

                  Text(
                    selectedTime == null
                        ? "8:00 PM"
                        : selectedTime!.format(context),
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
