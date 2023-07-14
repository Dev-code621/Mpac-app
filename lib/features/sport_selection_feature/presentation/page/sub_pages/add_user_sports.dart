import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/widgets/sport_widget.dart';

class AddUserSports extends StatefulWidget {
  final SportSelectionState state;
  final AppLocalizations localizations;
  final Function onSubmit;
  final Function(Map) onClickOnAddSport;
  final List<SportModel> selectedSports;

  const AddUserSports(
      {required this.state,
      required this.localizations,
      required this.selectedSports,
      required this.onSubmit,
      required this.onClickOnAddSport,
      Key? key,})
      : super(key: key);

  @override
  State<AddUserSports> createState() => _AddUserSportsState();
}

class _AddUserSportsState extends State<AddUserSports> {
  @override
  Widget build(BuildContext context) {
    if(widget.state.isLoadingSports){
      return Center(
        child:CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryColor,),
      );
    } else {
       return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.w < 450
                        ? 2
                        : kIsWeb
                            ? 3
                            : 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: kIsWeb
                        ? context.w < 550
                            ? 1.1
                            : context.w < 650
                                ? 1.2
                                : context.w < 800
                                    ? 1.3
                                    : 1.7
                        : 1.1,
                  ),
                  itemCount: widget.state.sportsModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SportWidget(widget.state.sportsModels[index],
                        widget.localizations.localeName,
                        onClickOnAddSport: (s) {
                      widget.onClickOnAddSport({'sport': s, 'index': index});
                      setState(() {});
                    },
                        isSelected: widget.selectedSports
                            .contains(widget.state.sportsModels[index]),);
                  },),
            ),
            /*Column(
              children: List.generate(
                  widget.state.sports.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: SportWidget(widget.state.sports[index],
                                    widget.localizations.localeName)),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                                child: SportWidget(widget.state.sports[index],
                                    widget.localizations.localeName))
                          ],
                        ),
                      )),
            ),*/
          ],
        ),
      ),
    );
 
    }
   
  }
}
