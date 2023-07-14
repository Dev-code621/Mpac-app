import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/sport_models/event_model.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_expand_section.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_state.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/widgets/event_type_selection_widget.dart';
import 'package:sizer/sizer.dart';

class SkillWidget extends StatelessWidget {
  final SportModel skillModel;
  final AppLocalizations localizations;
  final String localeName;
  final Function(Map) onUpdateSport;
  final Function(Map) onRemoveVariationInsideSport;
  final SportSelectionState state;

  const SkillWidget({
    required this.skillModel,
    required this.localeName,
    required this.state,
    required this.onUpdateSport,
    required this.onRemoveVariationInsideSport,
    required this.localizations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        width: context.w,
        // height: context.h * 0.12,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                skillModel.isExpanded = !skillModel.isExpanded;
                (context as Element).markNeedsBuild();
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Stack(
                      children: [
                        Container(
                          width: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.2
                              : context.w * 0.25,
                          height: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.2
                              : context.w * 0.25,
                          decoration: BoxDecoration(
                            color: skillModel.color.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            image: DecorationImage(
                              image: AssetImage(skillModel.backgroundPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.2
                              : context.w * 0.25,
                          height: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.2
                              : context.w * 0.25,
                          child: Align(
                            alignment: localeName == "ar"
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16.0,
                                left: 16.0,
                                top: 12.0,
                              ),
                              child: Image.asset(
                                skillModel.subImagePath,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Dimensions.checkKIsWeb(context)
                            ? const SizedBox(
                                height: 16,
                              )
                            : Container(),
                        Text(
                          skillModel.name,
                          style: TextStyle(
                            fontSize: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.03
                                : 14.sp,
                            color: AppColors.primaryFontColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Lorem Ipsum is simply dummy text of the...",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryFontColor,
                            fontSize: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.025
                                : 10.sp,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        skillModel.attributeModel.positions != null &&
                                skillModel.attributeModel.positions!.isNotEmpty
                            ? Text(
                                // localizations.n_out_of_ten_selected(skillModel.selectedPositions!.length),
                                state.missedSportsNames
                                        .toLowerCase()
                                        .contains(skillModel.name.toLowerCase())
                                    ? "Select one at least!"
                                    : "${skillModel.selectedPositions!.length} out of ${skillModel.attributeModel.positions!.length} selected",
                                style: TextStyle(
                                  color: state.missedSportsNames
                                          .toLowerCase()
                                          .contains(
                                            skillModel.name.toLowerCase(),
                                          )
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.026
                                      : 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                state.missedSportsNames
                                        .toLowerCase()
                                        .contains(skillModel.name.toLowerCase())
                                    ? "Add one event at least!"
                                    : "",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.026
                                      : 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        Dimensions.checkKIsWeb(context)
                            ? const SizedBox(
                                height: 16,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Container(
                      width: Dimensions.checkKIsWeb(context)
                          ? context.w * 0.08
                          : context.w * 0.14,
                      height: Dimensions.checkKIsWeb(context)
                          ? context.w * 0.08
                          : context.w * 0.14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Center(
                        child: Icon(
                          skillModel.isExpanded
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xffFF5247),
                          size: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.05
                              : context.w * 0.09,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            ExpandedSection(
              expand: skillModel.isExpanded,
              child: getExpandedWidget(context),
            )
          ],
        ),
      ),
    );
  }

  Widget getExpandedWidget(BuildContext context) {
    if (skillModel.name == "Swimming") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.player_event,
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.035 : 16.sp,
                color: AppColors.primaryFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            Column(
              children: List.generate(
                skillModel.attributeModel.events!.length,
                (index) => eventCardWidget(
                  skillModel.attributeModel.events![index],
                  context,
                  true,
                  "Swimming",
                ),
              ),
            )
          ],
        ),
      );
    } else if (skillModel.name == "Athletics") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.player_event,
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.035 : 16.sp,
                color: AppColors.primaryFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            EventTypeSelectionWidget(
              withRadioButton: true,
              isSelected1: skillModel.skillType == "Outdoor",
              isSelected2: skillModel.skillType == "Indoor",
              title1: 'Outdoor',
              title2: 'Indoor',
              path1: 'assets/images/general/outdoor.png',
              path2: 'assets/images/general/indoor.png',
              click1: () {
                skillModel.skillType = "Outdoor";
                (context as Element).markNeedsBuild();
              },
              click2: () {
                skillModel.skillType = "Indoor";
                (context as Element).markNeedsBuild();
              },
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            Column(
              children: List.generate(
                skillModel.attributeModel.events!.where((element) {
                  return element.category == skillModel.skillType;
                }).length,
                (index) => eventCardWidget(
                  // skillModel.attributeModel.events![index],
                  skillModel.attributeModel.events!.where((element) {
                    return element.category == skillModel.skillType;
                  }).toList()[index],
                  context,
                  false,
                  "Athletics",
                ),
              ),
            )
          ],
        ),
      );
    } else if (skillModel.name == "Road Racing") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.player_event,
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.035 : 16.sp,
                color: AppColors.primaryFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            EventTypeSelectionWidget(
              withRadioButton: true,
              isSelected1: skillModel.skillTypeRoadRacing == "Running Events",
              isSelected2: skillModel.skillTypeRoadRacing == "Walking Events",
              title1: 'Running',
              title2: 'Walking',
              path1: 'assets/images/general/running.png',
              path2: 'assets/images/general/walking.png',
              click1: () {
                skillModel.skillTypeRoadRacing = "Running Events";
                (context as Element).markNeedsBuild();
              },
              click2: () {
                skillModel.skillTypeRoadRacing = "Walking Events";
                (context as Element).markNeedsBuild();
              },
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            Column(
              children: List.generate(
                // skillModel.attributeModel.events!.length,
                skillModel.attributeModel.events!.where((element) {
                  return element.name == skillModel.skillTypeRoadRacing;
                }).length,
                (index) => eventCardWidget(
                  skillModel.attributeModel.events!.where((element) {
                    return element.name == skillModel.skillTypeRoadRacing;
                  }).toList()[index],
                  context,
                  false,
                  "Road Racing",
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.player_position,
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.035 : 16.sp,
                color: AppColors.primaryFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            Wrap(
              children: List.generate(
                skillModel.attributeModel.positions!.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    left: 4.0,
                    right: 4.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (skillModel.selectedPositions!.contains(
                        skillModel.attributeModel.positions![index],
                      )) {
                        // skillModel.selectedPositions!.remove(
                        //     skillModel.attributeModel.positions![index]);
                        List<String> pos = skillModel.selectedPositions!
                            .where(
                              (element) =>
                                  element !=
                                  skillModel.attributeModel.positions![index],
                            )
                            .toList();
                        onUpdateSport({
                          'type': 'positions',
                          'sport': skillModel,
                          'index': index,
                          'value': pos,
                        });

                        (context as Element).markNeedsBuild();
                      } else {
                        List<String> pos = skillModel.selectedPositions!;
                        pos.add(
                          skillModel.attributeModel.positions![index],
                        );

                        onUpdateSport({
                          'type': 'positions',
                          'sport': skillModel,
                          'index': index,
                          'value': pos,
                        });
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: skillModel.selectedPositions!.contains(
                          skillModel.attributeModel.positions![index],
                        )
                            ? AppColors.selectedPrimaryColor
                            : AppColors.unSelectedPrimaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          skillModel.attributeModel.positions![index],
                          style: TextStyle(
                            color: AppColors.primaryFontColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  // Swimming & Athletics card sub widgets.
  Widget eventCardWidget(
    EventModel event,
    BuildContext context,
    bool withTopPadding,
    String sportString,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: withTopPadding ? 8.0 : 0.0, bottom: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              event.isExpanded = !event.isExpanded;
              (context as Element).markNeedsBuild();
            },
            child: Container(
              decoration: BoxDecoration(
                color: getSubEventColor(event, sportString),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(event.isExpanded ? 0.0 : 5.0),
                  topRight: const Radius.circular(5.0),
                  topLeft: const Radius.circular(5.0),
                  bottomLeft: Radius.circular(event.isExpanded ? 0.0 : 5.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.name,
                          style: TextStyle(
                            color: AppColors.primaryFontColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Personal Best",
                          style: TextStyle(color: AppColors.primaryFontColor),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Icon(
                          event.isExpanded
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down,
                          size: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.05
                              : context.w * 0.09,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          event.variations == null
              ? Container()
              : getEventPointsWidget(event, context, sportString),
          // event.subEvents == null
          //     ? Container()
          //     : getAthleticsEventPointsWidget(event, context),
        ],
      ),
    );
  }

  Widget getEventPointsWidget(
    EventModel event,
    BuildContext context,
    String sportString,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: event.isExpanded ? AppColors.borderColor : Colors.white,
        ),
      ),
      child: ExpandedSection(
        expand: event.isExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: event.variations!.isEmpty
              ? getAthleticsEventPointsWidget(event, context)
              : Column(
                  children: List.generate(
                    event.variations!.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (checkIfThisVariationSelected(
                                    event.variations![index].id,
                                  )) {
                                    onRemoveVariationInsideSport({
                                      'sport': skillModel,
                                      'index': index,
                                      'variation_id':
                                          event.variations![index].id
                                    });
                                  }
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: checkIfThisVariationSelected(
                                      event.variations![index].id,
                                    )
                                        ? getSubEventColor(
                                            event,
                                            sportString,
                                          )
                                        : Colors.white,
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                event.variations![index].name,
                                style: TextStyle(
                                  color: AppColors.primaryFontColor,
                                ),
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              DatePicker.showTimePicker(
                                context,
                                showTitleActions: true,
                                onChanged: (date) {},
                                onConfirm: (date) {
                                  onUpdateSport({
                                    'type': 'variations',
                                    'sport': skillModel,
                                    'index': index,
                                    'value':
                                        "${date.hour}:${date.minute}:${date.second}",
                                    'sport_path':
                                        "${skillModel.id}/${event.id}/${event.variations![index].id}",
                                    'variation_id': event.variations![index].id
                                  });
                                },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 16.0,
                                  left: 16.0,
                                  top: 6.0,
                                  bottom: 6.0,
                                ),
                                child: Text(
                                  getValueOfSelectedVariation(
                                    event.variations![index].id,
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget getAthleticsEventPointsWidget(EventModel event, BuildContext context) {
    return ExpandedSection(
      expand: event.isExpanded,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
        child: Column(
          children: List.generate(
            event.subEvents!.length,
            (indexS) => getAthleticsSubEventsWidget(context, event, indexS),
          ),
        ),
      ),
    );
  }

  Widget getAthleticsSubEventsWidget(
    BuildContext context,
    EventModel event,
    int indexS,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
          child: Container(
            width: context.w,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: getSubEventColor(event, "Athletics"),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 6,
                top: 6,
              ),
              child: Text(
                event.subEvents![indexS].name,
                style: TextStyle(
                  color: AppColors.primaryFontColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: List.generate(
              event.subEvents![indexS].variations!.length,
              (indexP) => Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (checkIfThisVariationSelected(
                              event.subEvents![indexS].variations![indexP].id,
                            )) {
                              onRemoveVariationInsideSport({
                                'sport': skillModel,
                                'index': indexS,
                                'variation_id': event
                                    .subEvents![indexS].variations![indexP].id
                              });
                            }
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: checkIfThisVariationSelected(
                                event.subEvents![indexS].variations![indexP].id,
                              )
                                  ? getSubEventColor(event, "athletics")
                                  : Colors.white,
                              border: Border.all(
                                color: AppColors.borderColor,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          event.subEvents![indexS].variations![indexP].name,
                          style: TextStyle(
                            color: AppColors.primaryFontColor,
                          ),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showTimePicker(
                          context,
                          showTitleActions: true,
                          onChanged: (date) {},
                          onConfirm: (date) {
                            onUpdateSport({
                              'type': 'variations',
                              'sport': skillModel,
                              'index': indexS,
                              'value':
                                  "${date.hour}:${date.minute}:${date.second}",
                              'sport_path':
                                  "${skillModel.id}/${event.id}/${event.subEvents![indexS].id}/${event.subEvents![indexS].variations![indexP].id}",
                              'variation_id': event
                                  .subEvents![indexS].variations![indexP].id
                            });
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.en,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          child: Text(
                            getValueOfSelectedVariation(
                              event.subEvents![indexS].variations![indexP].id,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color getSubEventColor(EventModel event, String sportString) {
    if (sportString == "Swimming") {
      switch (event.name) {
        case "Free Style":
          return const Color(0xffFFA24A).withOpacity(0.9);
        case "Back Stroke":
          return const Color(0xff64D098).withOpacity(0.9);
        case "Breaststroke":
          return const Color(0xff64D098).withOpacity(0.9);
        case "Butterfly":
          return const Color(0xff64D098).withOpacity(0.9);
        default:
          return const Color(0xffFFA24A).withOpacity(0.9);
      }
    } else if (sportString == "Athletics") {
      switch (event.name) {
        case "Track Events":
          return const Color(0xffFFECDB).withOpacity(0.9);
        case "Jump Events":
          return const Color(0xffFFA24A).withOpacity(0.9);
        case "Throw Events":
          return const Color(0xff64D098).withOpacity(0.9);
        default:
          return const Color(0xffFFA24A).withOpacity(0.9);
      }
    } else {
      switch (event.name) {
        case "Free Style":
          return const Color(0xffFFA24A).withOpacity(0.9);
        case "Back Stroke":
          return const Color(0xff64D098).withOpacity(0.9);
        case "Breaststroke":
          return const Color(0xff64D098).withOpacity(0.9);
        case "Butterfly":
          return const Color(0xff64D098).withOpacity(0.9);
        default:
          return const Color(0xffFFA24A).withOpacity(0.9);
      }
    }
  }

  bool checkIfThisVariationSelected(String id) {
    for (int i = 0; i < state.selectedSportFromAPI.length; i++) {
      if (state.selectedSportFromAPI[i].sportPath2.endsWith(id)) {
        return true;
      }
    }
    return false;
  }

  String getValueOfSelectedVariation(String id) {
    for (int i = 0; i < state.selectedSportFromAPI.length; i++) {
      if (state.selectedSportFromAPI[i].sportPath2.endsWith(id)) {
        return state.selectedSportFromAPI[i].value;
      }
    }
    return "-:-:-";
  }
}
