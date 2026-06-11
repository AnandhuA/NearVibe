import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/screens/event/event_details_screen.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().fetchSavedEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = context.select<EventProvider, List<EventModel>>(
      (p) => p.savedEvents,
    );
    return AppScaffold(
      appBar: AppBar(
        title: Text("Saved", style: AppTextStyles.headlineLarge),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      child: events.isEmpty
          ? Center(
              child: Text("No Saved Events", style: AppTextStyles.titleMedium),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                  child: _savedCard(context: context, event: event),
                );
              },
            ),
    );
  }

  Widget _savedCard({
    required BuildContext context,
    required EventModel event,
  }) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.primary.withValues(alpha: 0.09),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),

            child: Hero(
              tag: 'event_${event.id}',
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: context.res.wsm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                Text(
                  event.title,

                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                ),
                SizedBox(height: context.res.hxs),
                Text(
                  formatEventDateWithoutYear(event.eventDate),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: context.res.wsm),
          Text(event.category),
        ],
      ),
    );
  }
}
