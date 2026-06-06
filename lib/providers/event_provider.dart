import 'dart:io';

import 'package:flutter/material.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/repositories/event_repository.dart';
import 'package:near_vibe/repositories/upload_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository repository;
  final UploadRepository uploadRepository;

  EventProvider(this.repository, this.uploadRepository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createEvent({
    required EventModel event,
    required File imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload image
      // final imageUrl = await repository.uploadEventImage(
      //   imageFile,
      // );
      final imageUrl = await uploadRepository.uploadImage(imageFile);

      // Create updated event
      final updatedEvent = event.copyWith(imageUrl: imageUrl);

      // Save event
      await repository.addEvent(updatedEvent);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
