import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/app_sizes.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {});
    });
    Future.microtask(() {
      final provider = context.read<EventProvider>();

      provider.addListener(() {
        if (provider.error != null) {
          AppSnackBar.error(context, provider.error!);

          provider.clearError();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return AppScaffold(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,

            delegate: EventHeaderDelegate(event),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(getIcon(event.category), size: 18),
                      SizedBox(width: context.res.wxs),
                      Text(event.category),
                    ],
                  ),
                  SizedBox(height: context.res.hxs),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      SizedBox(width: context.res.wxs),
                      Expanded(child: Text(event.creatorName)),
                    ],
                  ),
                  SizedBox(height: context.res.hxs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      SizedBox(width: context.res.wxs),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: getAddressFromLatLng(
                            event.latitude,
                            event.longitude,
                          ),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading location...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.hitText,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (event.savedUsers.isNotEmpty)
                    SizedBox(height: context.res.hsm),
                  if (event.savedUsers.isNotEmpty)
                    _AttendeesRow(
                      attendees: event.savedUsers.entries.take(5).map((entry) {
                        return {
                          'initial': entry.value[0].toUpperCase(),
                          'color':
                              Colors.primaries[entry.key.hashCode %
                                  Colors.primaries.length],
                        };
                      }).toList(),
                      goingCount: event.savedUsers.length,
                      interestedCount: 0,
                    ),
                  SizedBox(height: context.res.hsm),
                  Text('About Event', style: AppTextStyles.titleLarge),
                  SizedBox(height: context.res.hsm),
                  Text(event.description, style: AppTextStyles.bodyLarge),

                  SizedBox(height: context.res.hsm),

                  // Container(
                  //   padding: const EdgeInsets.all(14),
                  //   decoration: BoxDecoration(
                  //     color: context.primary.withValues(alpha: .08),
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Column(
                  //     // crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _AttendeesRow(
                  //         attendees: event.savedUsers.entries.take(5).map((
                  //           entry,
                  //         ) {
                  //           return {
                  //             'initial': entry.value[0].toUpperCase(),
                  //             'color':
                  //                 Colors.primaries[entry.key.hashCode %
                  //                     Colors.primaries.length],
                  //           };
                  //         }).toList(),
                  //         goingCount: event.savedUsers.length,
                  //         interestedCount: 0,
                  //       ),
                  //       SizedBox(height: context.res.hxs),
                  //       Row(
                  //         children: [
                  //           const Icon(Icons.person_outline),
                  //           SizedBox(width: context.res.wxs),
                  //           Expanded(
                  //             child: Text("Created by ${event.creatorName}"),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: context.res.hsm),
                  ElevatedButton(
                    onPressed: _openGoogleMaps,
                    child: Text("View on Google Maps"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final double lat = widget.event.latitude;
    final double lng = widget.event.longitude;

    // Try native Google Maps app first
    final nativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) AppSnackBar.error(context, "Could not open Google Maps");
    }
  }
}

class EventHeaderDelegate extends SliverPersistentHeaderDelegate {
  final EventModel event;

  EventHeaderDelegate(this.event);

  @override
  double get minExtent => kToolbarHeight + 20;

  @override
  double get maxExtent => 320;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(
      0.0,
      1.0,
    );

    final screenWidth = MediaQuery.of(context).size.width;

    final topPadding = MediaQuery.of(context).padding.top;

    // Image Animation
    final imageWidth = 40 + ((screenWidth - 20) - 40) * progress;

    final imageHeight = 40 + (220 - 40) * progress;

    final imageLeft = 52 * (1 - progress);

    final imageTop = topPadding + 8 + (50 - 8) * progress;

    // Title Animation
    final titleLeft = 96 + (20 - 96) * progress;

    final titleTop =
        (topPadding + 18) +
        ((imageTop + imageHeight + 12) - (topPadding + 18)) * progress;

    return Container(
      color: Color.lerp(
        Theme.of(context).scaffoldBackgroundColor,
        Colors.transparent,
        progress,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // IMAGE
          Positioned(
            left: imageLeft,
            top: imageTop,
            child: Hero(
              tag: 'event_${event.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 + (12 * progress)),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // BACK BUTTON
          Positioned(
            left: 4,
            top: topPadding + 4,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          ),

          // TITLE
          Positioned(
            left: titleLeft,
            top: titleTop,
            child: SizedBox(
              width: screenWidth - 150,
              child: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: progress < .3
                    ? AppTextStyles.titleLarge
                    : AppTextStyles.headlineLarge,
              ),
            ),
          ),

          // SAVE BUTTON
          Positioned(
            right: 4,
            top: topPadding + 4,
            child: Consumer<EventProvider>(
              builder: (context, provider, _) {
                final isSaved = provider.isEventSaved(event.id);

                return IconButton(
                  onPressed: () async {
                    if (isSaved) {
                      await provider.unsaveEvent(event.id);
                    } else {
                      await provider.saveEvent(event.id);
                    }
                  },

                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),

                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,

                      key: ValueKey(isSaved),

                      color: isSaved
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant EventHeaderDelegate oldDelegate) {
    return true;
  }
}

// ── Attendees Row ─────────────────────────────────────────────────────────────
class _AttendeesRow extends StatelessWidget {
  final List<Map<String, dynamic>> attendees;
  final int goingCount;
  final int interestedCount;

  const _AttendeesRow({
    required this.attendees,
    required this.goingCount,
    required this.interestedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: attendees.length * 18.0 + 8,
          height: 28,
          child: Stack(
            children: List.generate(attendees.length, (i) {
              final att = attendees[i];
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: att['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.background,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      att['initial'] as String,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$goingCount Saved',
                style: const TextStyle(
                  fontSize: AppSizes.textXs,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // TextSpan(
              //   text: '  ·  $interestedCount interested',
              //   style: TextStyle(
              //     fontSize: AppSizes.textXs,
              //     color: Colors.white.withValues(alpha: 0.4),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
