import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';

class SportWidget extends StatelessWidget {
  final SportModel sportModel;
  final String localeName;
  final Function(SportModel) onClickOnAddSport;
  final bool isSelected;

  const SportWidget(this.sportModel, this.localeName,
      {required this.onClickOnAddSport, required this.isSelected, super.key,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClickOnAddSport(sportModel);
      },
      child: Column(
        children: [
          Container(
              height: context.h * 0.14, // 0.165
              decoration: BoxDecoration(
                  // color: Colors.yellow.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),),
                  image: DecorationImage(
                      image: AssetImage(sportModel.backgroundPath),
                      fit: BoxFit.cover,),),
              child: Stack(
                children: [
                  Container(
                    height: context.h * 0.14, // 0.165
                    decoration: BoxDecoration(
                      color: sportModel.color.withOpacity(0.4),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),),
                    ),
                  ),
                  Align(
                    alignment: localeName == "ar"
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16.0, top: 12.0,),
                      child: Image.asset(sportModel.subImagePath,
                          fit: BoxFit.fitHeight,),
                    ),
                  ),
                  Align(
                    alignment: localeName == "ar"
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0, left: 8.0, top: 8.0,),
                        child:/* sportModel.isAddingToServer
                            ? Container(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1.5,
                                ))
                            : */GestureDetector(
                                onTap: () {
                                  onClickOnAddSport(sportModel);
                                },
                                child: isSelected
                                    ? Icon(
                                        Icons.remove_circle,
                                        color: AppColors.logoColor,
                                        size: context.h * 0.035,
                                      )
                                    : Icon(
                                        Icons.add_circle_sharp,
                                        color: Colors.white,
                                        size: context.h * 0.035,
                                      ),
                              ),),
                  ),
                ],
              ),),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: context.h * 0.045,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),),
              ),
              child: Center(
                child: Text(sportModel.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black,),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
