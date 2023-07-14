import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_bloc.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_state.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:sizer/sizer.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/widgets/select_profile_widget.dart';

//
class SelectYourProfilePage extends StatefulWidget {
  const SelectYourProfilePage({Key? key}) : super(key: key);

  @override
  State<SelectYourProfilePage> createState() => _SelectYourProfilePageState();
}

class _SelectYourProfilePageState extends State<SelectYourProfilePage> {
  late AppLocalizations localizations;
  String profileType = "athlete";
  final _bloc = getIt<CreateProfileBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, CreateProfileState state) {
        if (state.informationUpdated) {
          Navigator.pushNamed(
            context,
            AppScreens.sportSelectionPage,
            arguments: {
              'viewType': ViewType.initial,
              'profileType': profileType,
            },
          );
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, CreateProfileState state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              leading: CustomBackButton(
                onBackClicked: () {
                  Navigator.pop(context);
                },
                localeName: localizations.localeName,
              ),
              title: Text(
                localizations.select_your_profile,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: context.h * 0.02,
                        ),
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          onTap: () {
                            setState(() {
                              profileType = "athlete";
                            });
                          },
                          child: SelectProfileWidget(
                            title: "Athlete",
                            isSelected: profileType == "athlete",
                            containerColor: const Color(0xff8E97FD),
                            description: '',
                            svgPath: 'assets/images/general/player.svg',
                          ),
                        ),
                        // SizedBox(
                        //   height: context.h * 0.02,
                        // ),
                        // InkWell(
                        //   borderRadius:
                        //       const BorderRadius.all(Radius.circular(16)),
                        //   onTap: () {
                        //     setState(() {
                        //       profileType = "coach";
                        //     });
                        //   },
                        //   child: SelectProfileWidget(
                        //     title: "Coach",
                        //     isSelected: profileType == "coach",
                        //     containerColor: const Color(0xffFFA24A),
                        //     description:
                        //         "You'll have access to tools and resources to help you lead your team to victory!",
                        //     svgPath: 'assets/images/general/partner.svg',
                        //   ),
                        // ),
                        SizedBox(
                          height: context.h * 0.02,
                        ),
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          onTap: () {
                            setState(() {
                              profileType = "enthusiast";
                            });
                          },
                          child: SelectProfileWidget(
                            title: "Enthusiast",
                            isSelected: profileType == "enthusiast",
                            containerColor: const Color(0xffFFA24A),
                            description: "",
                            svgPath: 'assets/images/general/enthusiast.svg',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.h, top: 4.h),
                    child: CustomSubmitButton(
                      buttonText: localizations.continue_n.toUpperCase(),
                      backgroundColor: AppColors.primaryColor,
                      onPressed: () {
                        _bloc.onUpdateType(profileType);
                      },
                      hoverColor: Colors.grey.withOpacity(0.5),
                      textColor: Colors.white,
                      isLoading: state.isUpdatingInformation,
                      disable: state.isUpdatingInformation,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
