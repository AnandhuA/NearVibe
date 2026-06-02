import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text("Saved", style: AppTextStyles.headlineLarge),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => _savedCard(context: context),
      ),
    );
  }

  Widget _savedCard({required BuildContext context}) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.secondary,
      ),
      child: Row(
        children: [
          Container(
            width: context.res.h(0.1),
            height: context.res.h(0.1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.primary,
            ),
          ),
          SizedBox(width: context.res.wsm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                Text(
                  "ExternalSyntheticLambda0",
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                ),
                SizedBox(height: context.res.hxs),
                Text("Today - 0.5 km", style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          SizedBox(width: context.res.wsm),
          Text("Today"),
        ],
      ),
    );
  }
}
