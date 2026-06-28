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
  late final PageController _imagePageController;
  int _selectedImageIndex = 0;

  List<String> get _imageUrls {
    final urls = widget.event.imageUrls.isNotEmpty
        ? widget.event.imageUrls
        : [widget.event.imageUrl];

    return urls.where((url) => url.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return AppScaffold(
      scrollable: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(event.title, style: AppTextStyles.headlineMedium),
        actions: [
          Consumer<EventProvider>(
            builder: (context, provider, _) {
              final isSaved = provider.isEventSaved(event.id);

              return IconButton(
                onPressed: () async {
                  if (isSaved) {
                    await provider.unsaveEvent(event);
                  } else {
                    await provider.saveEvent(event);
                  }
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    key: ValueKey(isSaved),
                    color: isSaved ? context.primary : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImageGallery(
            heroTag: 'event_${event.id}',
            imageUrls: _imageUrls,
            pageController: _imagePageController,
            selectedIndex: _selectedImageIndex,
            onPageChanged: (index) {
              setState(() => _selectedImageIndex = index);
            },
            onThumbnailTap: (index) {
              setState(() => _selectedImageIndex = index);
              _imagePageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
              );
            },
          ),
          SizedBox(height: context.res.hsm),
          _InfoRow(icon: getIcon(event.category), text: event.category),
          SizedBox(height: context.res.hxs),
          _InfoRow(icon: Icons.person, text: event.creatorName),
          if (event.venueName.isNotEmpty) ...[
            SizedBox(height: context.res.hxs),
            _InfoRow(icon: Icons.stadium_outlined, text: event.venueName),
          ],
          SizedBox(height: context.res.hxs),
          FutureBuilder<String>(
            future: getAddressFromLatLng(event.latitude, event.longitude),
            builder: (context, snapshot) {
              return _InfoRow(
                icon: Icons.location_on,
                text: snapshot.data ?? 'Loading location...',
                textColor: context.hitText,
              );
            },
          ),
          SizedBox(height: context.res.hxs),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: formatEventDate(event.eventDate),
            textColor: context.hitText,
          ),
          if (event.savedUsers.isNotEmpty) ...[
            SizedBox(height: context.res.hsm),
            _AttendeesRow(
              attendees: event.savedUsers.entries.take(5).map((entry) {
                return {
                  'initial': entry.value[0].toUpperCase(),
                  'color': Colors
                      .primaries[entry.key.hashCode % Colors.primaries.length],
                };
              }).toList(),
              goingCount: event.savedUsers.length,
              interestedCount: 0,
            ),
          ],
          SizedBox(height: context.res.hmd),
          Text('About Event', style: AppTextStyles.titleLarge),
          SizedBox(height: context.res.hsm),
          Text(event.description, style: AppTextStyles.bodyLarge),
          if (event.source == 'ticketmaster') ...[
            SizedBox(height: context.res.hmd),
            Text('Ticket information', style: AppTextStyles.titleLarge),
            if (event.ticketStatus.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.res.hxs),
                child: Text('Status: ${event.ticketStatus}'),
              ),
            if (event.priceInfo.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.res.hxs),
                child: Text('Price: ${event.priceInfo}'),
              ),
          ],
          SizedBox(height: context.res.hmd),
          ElevatedButton(
            onPressed: _openGoogleMaps,
            child: const Text("View on Google Maps"),
          ),
          if (event.externalUrl.isNotEmpty) ...[
            SizedBox(height: context.res.hsm),
            OutlinedButton.icon(
              onPressed: _openExternalEvent,
              icon: const Icon(Icons.confirmation_number_outlined),
              label: const Text('View tickets on Ticketmaster'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final double lat = widget.event.latitude;
    final double lng = widget.event.longitude;

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

  Future<void> _openExternalEvent() async {
    final uri = Uri.tryParse(widget.event.externalUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'Could not open the Ticketmaster event page',
        );
      }
    }
  }
}

class _ImageGallery extends StatelessWidget {
  final String heroTag;
  final List<String> imageUrls;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;

  const _ImageGallery({
    required this.heroTag,
    required this.imageUrls,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.image_not_supported_rounded, color: context.primary),
      );
    }

    return Column(
      children: [
        Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      );
                    },
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (index) {
                          final isSelected = index == selectedIndex;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 6,
                            width: isSelected ? 18 : 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => onThumbnailTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? context.primary
                            : context.primary.withValues(alpha: 0.14),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? textColor;

  const _InfoRow({required this.icon, required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        SizedBox(width: context.res.wxs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

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
                    border: Border.all(color: context.background, width: 1.5),
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
                style: TextStyle(
                  fontSize: AppSizes.textXs,
                  color: context.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
