import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:near_vibe/core/apikeys/api_key.dart';
import 'package:near_vibe/models/event_model.dart';

/// Fetches Ticketmaster concerts directly for the free Firebase setup.
/// This key is intentionally local/ignored, but is still extractable from a
/// released app; move this behind a server before a public production release.
class ExternalEventRepository {
  static const _cooldown = Duration(seconds: 60);
  static const _cacheLifetime = Duration(minutes: 30);
  DateTime? _lastRequestAt;
  DateTime? _cachedAt;
  String? _cacheKey;
  List<EventModel> _cachedEvents = const [];

  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
  }) async {
    if (TicketmasterConstants.apiKey.isEmpty) {
      debugPrint('[Ticketmaster] API key is empty in api_key.dart.');
      throw StateError('Add your Ticketmaster Consumer Key in api_key.dart.');
    }

    final now = DateTime.now();
    final key = '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_$radiusKm';
    final cacheIsFresh = _cacheKey == key &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheLifetime;
    if (cacheIsFresh) {
      debugPrint('[Ticketmaster] Using ${_cachedEvents.length} cached events.');
      return _cachedEvents;
    }
    if (_lastRequestAt != null && now.difference(_lastRequestAt!) < _cooldown) {
      debugPrint('[Ticketmaster] Refresh cooldown active; returning ${_cachedEvents.length} cached events.');
      return _cachedEvents;
    }

    _lastRequestAt = now;
    final uri = Uri.https('app.ticketmaster.com', '/discovery/v2/events.json', {
      'apikey': TicketmasterConstants.apiKey,
      'latlong': '$latitude,$longitude',
      // Ticketmaster rejects decimal-form radius values such as `20.0`.
      'radius': radiusKm.round().toString(),
      'unit': 'km',
      'classificationName': 'music',
      'size': '50',
      'sort': 'date,asc',
    });
    debugPrint('[Ticketmaster] Requesting events near $latitude,$longitude (radius: ${radiusKm}km).');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('[Ticketmaster] Request failed: HTTP ${response.statusCode}. ${response.body}');
      throw Exception('Ticketmaster request failed (${response.statusCode}).');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final embedded = Map<String, dynamic>.from(payload['_embedded'] ?? const {});
    final rawEvents = List<Map<String, dynamic>>.from(embedded['events'] ?? const []);
    _cachedEvents = rawEvents.map(_toEvent).toList();
    debugPrint('[Ticketmaster] Received ${_cachedEvents.length} events.');
    _cacheKey = key;
    _cachedAt = now;
    return _cachedEvents;
  }

  EventModel _toEvent(Map<String, dynamic> event) {
    final venues = (event['_embedded'] as Map?)?['venues'] as List? ?? const [];
    final venue = venues.isEmpty ? const <String, dynamic>{} : Map<String, dynamic>.from(venues.first as Map);
    final location = Map<String, dynamic>.from(venue['location'] ?? const {});
    final images = event['images'] as List? ?? const [];
    final image = images.isEmpty ? const <String, dynamic>{} : Map<String, dynamic>.from(images.first as Map);
    final dates = Map<String, dynamic>.from(event['dates'] ?? const {});
    final start = Map<String, dynamic>.from(dates['start'] ?? const {});
    final status = Map<String, dynamic>.from(dates['status'] ?? const {});
    final prices = event['priceRanges'] as List? ?? const [];
    final price = prices.isEmpty
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(prices.first as Map);
    final eventDate = start['dateTime'] ?? start['localDate'] ?? DateTime.now().toIso8601String();
    return EventModel(
      id: 'ticketmaster_${event['id']}',
      title: event['name']?.toString() ?? 'Untitled event',
      description: _eventDescription(event, venue),
      imageUrl: image['url']?.toString() ?? '',
      imageUrls: image['url'] == null ? const [] : [image['url'].toString()],
      category: 'Music',
      latitude: double.tryParse(location['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(location['longitude']?.toString() ?? '') ?? 0,
      geohash: '',
      eventDate: DateTime.tryParse(eventDate.toString()) ?? DateTime.now(),
      createdBy: 'ticketmaster',
      creatorName: 'Ticketmaster',
      savedUsers: const {},
      source: 'ticketmaster',
      externalUrl: event['url']?.toString() ?? '',
      venueName: venue['name']?.toString() ?? '',
      priceInfo: _formatPrice(price),
      ticketStatus: status['code']?.toString() ?? '',
    );
  }

  String _formatPrice(Map<String, dynamic> price) {
    final min = price['min'];
    final max = price['max'];
    final currency = price['currency']?.toString() ?? '';
    if (min == null && max == null) return '';
    if (min == max || max == null) return '$currency $min'.trim();
    return '$currency $min – $max'.trim();
  }

  String _eventDescription(
    Map<String, dynamic> event,
    Map<String, dynamic> venue,
  ) {
    // Ticketmaster does not guarantee a description on every listing.
    for (final value in [
      event['info'],
      event['description'],
      event['additionalInfo'],
      event['pleaseNote'],
    ]) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    final venueName = venue['name']?.toString().trim() ?? '';
    if (venueName.isNotEmpty) {
      return 'This event is hosted at $venueName. Open the official '
          'Ticketmaster listing for the latest event details and ticket information.';
    }
    return 'Ticketmaster has not provided a written description for this event. '
        'Open the official listing for the latest details and ticket information.';
  }
}
