import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/models/event_model.dart';
import 'package:near_vibe/widgets/category_widget.dart';

class CardWidget extends StatelessWidget {
  final EventModel event;
  const CardWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              // Container(
              //   height: 180,

              //   decoration: BoxDecoration(
              //     gradient: AppColors.primaryGradient,
              //     borderRadius: const BorderRadius.vertical(
              //       top: Radius.circular(20),
              //     ),
              //     image: DecorationImage(

              //       image: CachedNetworkImageProvider(event.imageUrl),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  placeholder: (context, url) => Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const CircularProgressIndicator(),
                  ),

                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(Icons.broken_image_rounded, size: 50),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: context.text,
                      ),
                    ),

                    SizedBox(height: context.res.hxs),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: context.hitText,
                        ),

                        SizedBox(width: context.res.wxs),

                        FutureBuilder<String>(
                          future: getAddressFromLatLng(
                            event.latitude,
                            event.longitude,
                          ),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Loading...",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.hitText,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: context.res.hxs),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: context.hitText,
                        ),

                        SizedBox(width: context.res.wxs),

                        Text(
                          formatEventDate(event.eventDate),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.hitText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          CategoryWidget(
            icon: getIcon(event.category),
            title: event.category,
            bgColor: context.secondary,
            titleColor: context.whiteText,
          ),
        ],
      ),
    );
  }
}
