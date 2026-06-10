import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_vibe/core/exceptions/firebase_exception_mapper.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  EventRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : firestore = firestore ?? FirebaseFirestore.instance,
      storage = storage ?? FirebaseStorage.instance;

  //====ADD EVENT =======
  Future<void> addEvent(EventModel event) async {
    try {
      await firestore.collection('events').add(event.toMap());
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    }
  }

  //=====GET ALL EVENTS====
  Stream<List<EventModel>> getEvents() {
    return firestore
        .collection('events')
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList(),
        );
  }

  //== UPLOAD IMAGE ======
  Future<String> uploadEventImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = storage.ref().child('events').child('$fileName.jpg');

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }

  //===ADD SAVEDEVENT ======
  Future<void> saveEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await firestore.collection('saved_events').add({
        'userId': userId,
        'eventId': eventId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    }
  }

  //=== REMOVE FROM SAVED EVENT ====

  Future<void> removeSavedEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      final snapshot = await firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    }
  }

  //== LIST ALL SAVED EVENTS ========
  Stream<List<EventModel>> getSavedEvents(String userId) {
    return firestore
        .collection('saved_events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((savedSnapshot) async {
          final eventIds = savedSnapshot.docs
              .map((e) => e['eventId'] as String)
              .toList();

          if (eventIds.isEmpty) return [];

          final eventSnapshot = await firestore
              .collection('events')
              .where(FieldPath.documentId, whereIn: eventIds)
              .get();

          return eventSnapshot.docs
              .map((e) => EventModel.fromDocument(e))
              .toList();
        });
  }
}
