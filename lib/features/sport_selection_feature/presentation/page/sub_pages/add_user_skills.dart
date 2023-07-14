import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/widgets/skill_widget.dart';

class AddUserSkills extends StatefulWidget {
  final SportSelectionState state;
  final AppLocalizations localizations;
  final Function onSubmit;
  final List<SportModel> selectedSports;
  final Function(Map) onUpdateSport;
  final Function(Map) onRemoveVariationInsideSport;

  const AddUserSkills(
      {required this.state,
      required this.localizations,
      required this.selectedSports,
      required this.onSubmit,
      required this.onUpdateSport,
      required this.onRemoveVariationInsideSport,
      Key? key,})
      : super(key: key);

  @override
  State<AddUserSkills> createState() => _AddUserSkillsState();
}

class _AddUserSkillsState extends State<AddUserSkills> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
            child: Text(
              widget.localizations.you_must_add_one_in_each_sport,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.03 :12.sp,),
            ),
          ),
          Column(
            children: List.generate(
                widget.selectedSports.length,
                (index) => SkillWidget(
                    skillModel: widget.selectedSports[index],
                    localizations: widget.localizations,
                    localeName: widget.localizations.localeName,
                    state: widget.state,
                    onUpdateSport: (Map map) {
                      map['sIndex'] = index;
                      widget.onUpdateSport(map);
                    },
                    onRemoveVariationInsideSport: (Map map) {
                      map['sIndex'] = index;
                      widget.onRemoveVariationInsideSport(map);
                    },),),
          ),
          // Padding(
          //   padding:
          //       EdgeInsets.only(bottom: 6.h, top: 4.h, left: 12, right: 12),
          //   child: CustomSubmitButton(
          //     buttonText: widget.localizations.continue_n.toUpperCase(),
          //     backgroundColor: AppColors.primaryColor,
          //     onPressed: () {
          //       widget.onSubmit();
          //     },
          //     hoverColor: Colors.grey.withOpacity(0.5),
          //     textColor: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }
}
