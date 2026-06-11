import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class HelperFuntions {
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }
}

Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  try {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      return "${place.locality}, ${place.subAdministrativeArea}";
    }

    return "Unknown Location";
  } catch (e) {
    return "Unknown Location";
  }
}

String formatEventDate(DateTime eventDate) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);

  final tomorrow = today.add(const Duration(days: 1));

  final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

  final time = DateFormat('h:mm a').format(eventDate);

  if (eventDay == today) {
    return 'Today • $time';
  }

  if (eventDay == tomorrow) {
    return 'Tomorrow • $time';
  }

  return '${DateFormat('dd MMM yyyy').format(eventDate)} • $time';
}

String formatEventDateWithoutYear(DateTime eventDate) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);

  final tomorrow = today.add(const Duration(days: 1));

  final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

  final time = DateFormat('h:mm a').format(eventDate);

  if (eventDay == today) {
    return 'Today • $time';
  }

  if (eventDay == tomorrow) {
    return 'Tomorrow • $time';
  }

  return '${DateFormat('dd MMM').format(eventDate)} • $time';
}

IconData getIcon(String category) {
  switch (category.toLowerCase()) {
    case 'music':
      return Icons.music_note;

    case 'gaming':
      return Icons.sports_esports;

    case 'tech':
      return Icons.computer;

    case 'food':
      return Icons.restaurant;

    case 'sports':
      return Icons.sports_soccer;

    case 'business':
      return Icons.business_center;

    case 'education':
      return Icons.school;

    case 'movie':
      return Icons.movie;

    case 'travel':
      return Icons.flight;

    case 'art':
      return Icons.palette;

    default:
      return Icons.category;
  }
}
