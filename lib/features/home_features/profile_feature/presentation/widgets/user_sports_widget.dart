import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserSportsWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final List<SelectedSportModel> sports;
  final bool isLoadingProfile;
  final String flowCalled;
  final String selectedSport;
  final Function(String) onFilter;
  final Function? onEditSports;
  final bool withEdit;

  const UserSportsWidget({
    super.key,
    required this.localizations,
    required this.sports,
    required this.isLoadingProfile,
    required this.selectedSport,
    required this.onFilter,
    required this.flowCalled,
    this.onEditSports,
    this.withEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoadingProfile && sports.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 50.sp,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: sports.length,
            itemBuilder: (context, index){
              return getCircleSportWidget(context, index);
            },
          ),
        ),
      );
    } else {
      return shimmerLoadingWidget(context);
    }
  }

  Widget getCircleSportWidget(BuildContext context, int index) {
    return Row(
      children: [
        if (index == 0)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4.0,
            ),
            child: GestureDetector(
              onTap: () {
                onFilter("general");
              },
              child: Container(
                width: kIsWeb ? context.w * 0.15 : context.w * 0.15,
                height: kIsWeb ? context.w * 0.15 : context.w * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                  height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.unSelectedWidgetColor.withOpacity(0.5),
                    border: selectedSport == "general"
                        ? Border.all(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    )
                        : null,
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/images/sports_new/general_sports.jpg',
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () {
              onFilter(sports[index].sport!.name);
            },
            child: Container(
              width: kIsWeb ? context.w * 0.15 : context.w * 0.15,
              height: kIsWeb ? context.w * 0.15 : context.w * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selectedSport == sports[index].sport!.name
                    ? Border.all(
                  color: AppColors.primaryColor,
                  width: 1.5,
                )
                    : null,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    sports[index].sport!.backgroundPath,
                  ),
                ),
              ),
              child: Container(
                width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: sports[index].sport!.color.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Align(
                      alignment: localizations.localeName == "ar"
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                          left: 8.0,
                          top: 0.0,
                        ),
                        child: Image.asset(
                          sports[index].sport!.subImagePath,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (index == sports.length - 1 && withEdit)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4.0,
            ),
            child: GestureDetector(
              onTap: () {
                onEditSports!();
              },
              child: Container(
                width: kIsWeb ? context.w * 0.15 : context.w * 0.15,
                height: kIsWeb ? context.w * 0.15 : context.w * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                  height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.unSelectedWidgetColor.withOpacity(0.9),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget shimmerLoadingWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            child: Shimmer.fromColors(
              baseColor: AppColors.unSelectedWidgetColor.withOpacity(0.8),
              highlightColor: Colors.black,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.unSelectedWidgetColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            child: Shimmer.fromColors(
              baseColor: AppColors.unSelectedWidgetColor.withOpacity(0.8),
              highlightColor: Colors.black,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.unSelectedWidgetColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            height: kIsWeb ? context.w * 0.07 : context.w * 0.15,
            child: Shimmer.fromColors(
              baseColor: AppColors.unSelectedWidgetColor.withOpacity(0.8),
              highlightColor: Colors.black,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.unSelectedWidgetColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
