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
    required String userName,
    required EventModel event,
  }) async {
    try {
      final batch = firestore.batch();

      // saved_events collection
      final savedRef = firestore.collection('saved_events').doc('${userId}_${event.id}');

      batch.set(savedRef, {
        'userId': userId,
        'eventId': event.id,
        'savedAt': FieldValue.serverTimestamp(),
        if (event.source != 'user') 'eventData': event.toJson(),
      });

      // update event document
      if (event.source == 'user') {
        final eventRef = firestore.collection('events').doc(event.id);
        batch.update(eventRef, {'savedUsers.$userId': userName});
      }

      await batch.commit();
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    }
  }
  //=== REMOVE FROM SAVED EVENT ====

  Future<void> removeSavedEvent({
    required String userId,
    required EventModel event,
  }) async {
    try {
      final batch = firestore.batch();

      final snapshot = await firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: event.id)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (event.source == 'user') {
        final eventRef = firestore.collection('events').doc(event.id);
        batch.update(eventRef, {'savedUsers.$userId': FieldValue.delete()});
      }

      await batch.commit();
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
              .where((e) => e.data()['eventData'] == null)
              .map((e) => e['eventId'] as String)
              .toList();

          final externalEvents = savedSnapshot.docs
              .where((e) => e.data()['eventData'] != null)
              .map((e) => EventModel.fromJson(
                    Map<String, dynamic>.from(e.data()['eventData'] as Map),
                  ))
              .toList();

          if (eventIds.isEmpty) return externalEvents;

          final eventSnapshot = await firestore
              .collection('events')
              .where(FieldPath.documentId, whereIn: eventIds)
              .get();

          return [
            ...eventSnapshot.docs
              .map((e) => EventModel.fromDocument(e))
              .toList(),
            ...externalEvents,
          ];
        });
  }
}
