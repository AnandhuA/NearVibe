import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/dummy_data.dart';
import 'package:near_vibe/core/utils/helper_funtions.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';
import 'package:near_vibe/core/widgets/category_widget.dart';
import 'package:near_vibe/core/widgets/card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scrollable: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              HelperFuntions.getGreeting(),
              style: AppTextStyles.titleMedium,
            ),
            Text("What's Nearby", style: AppTextStyles.titleLarge),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: context.primary,
            child: Text("A", style: AppTextStyles.bodyLarge),
          ),
          SizedBox(width: context.res.wsm),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: context.res.h(0.08),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dummyCategoriesList.length,
              itemBuilder: (context, index) {
                final isAll = index == 0;

                final category = isAll
                    ? {"title": "All"}
                    : dummyCategoriesList[index - 1];
                return CategoryWidget(
                  icon: category["icon"],
                  title: category["title"],
                  bgColor: context.primary.withValues(alpha: 0.09),
                );
              },
            ),
          ),
          SizedBox(height: context.res.hxs),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: 5,

            separatorBuilder: (context, index) {
              return SizedBox(height: context.res.hsm);
            },

            itemBuilder: (context, index) {
              return CardWidget();
            },
          ),
        ],
      ),
    );
  }
}
