import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/dialogs/custom_dialog.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_event.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/page/sub_pages/add_user_skills.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/page/sub_pages/add_user_sports.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/widgets/custom_step_holder_page.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_state.dart';
import 'package:another_flushbar/flushbar.dart';

class SportSelectionPage extends StatefulWidget {
  final ViewType viewType;
  final String profileType;

  const SportSelectionPage({
    required this.viewType,
    Key? key,
    this.profileType = "athlete",
  }) : super(key: key);

  @override
  State<SportSelectionPage> createState() => _SportSelectionPageState();
}

class _SportSelectionPageState extends State<SportSelectionPage>
    with FlushBarMixin {
  final _bloc = getIt<SportSelectionBloc>();
  late AppLocalizations localizations;
  final PageController _pageController = PageController();

  FlushbarStatus flushbarStatus = FlushbarStatus.DISMISSED;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    _bloc.onGetSports();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, SportSelectionState state) {
        if (state.maximumSportsSelect) {
          _bloc.onClearFailures();
          exceptionFlushBar(
            context: context,
            onChangeStatus: (s) {
              flushbarStatus = s;
            },
            onHidden: () {
              _bloc.onClearFailures();
            },
            duration: const Duration(milliseconds: 1200),
            message: 'You cannot select more than 3 sports',
          );
        }
        if (state.selectAtLeastOneSport) {
          _bloc.onClearFailures();
          exceptionFlushBar(
            context: context,
            onChangeStatus: (s) {
              flushbarStatus = s;
            },
            onHidden: () {
              _bloc.onClearFailures();
            },
            duration: const Duration(milliseconds: 1200),
            message: 'You should select at least one sport!',
          );
        }
        if (state.sportsUpdated) {
          setState(() {});
          _bloc.onClearFailures();
        }
        if (state.missingVariationsSelection) {
          _bloc.onClearFailures();
          CustomDialogs.missingVariationsSelection(
            context: context,
            missedSportsNames: state.missedSportsNames,
            localizations: localizations,
            onSubmit: () {
              // Navigator.pushNamed(context, AppScreens.holderPage);
              Navigator.pop(context);
              _bloc.add(UpdateInformation());
            },
          );
        }
        if (state.noThingIsMissed) {
          _bloc.onClearFailures();
          _bloc.add(UpdateInformation());
          // Navigator.pushNamed(context, AppScreens.holderPage);
        }
        if (state.informationUpdated) {
          if (widget.viewType == ViewType.profile) {
            Navigator.pop(context, {'withReloading': true});
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, AppScreens.holderPage, (route) => false);
            _bloc.onClearFailures();
          }
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, SportSelectionState state) {
          if (widget.profileType == "enthusiast") {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.zero,
                child: AppBar(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        leading: widget.viewType == ViewType.splash
                            ? null
                            : CustomBackButton(
                                onBackClicked: () {
                                  Navigator.pop(context);
                                },
                                localeName: localizations.localeName,
                              ),
                        title: Text(
                          localizations.add_your_sports,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: kIsWeb ? context.h * 0.032 : 14.sp,
                          ),
                        ),
                      ),
                      body: AddUserSports(
                        state: state,
                        localizations: localizations,
                        onSubmit: () {
                          if (widget.viewType == ViewType.initial) {
                            Navigator.pushNamed(context, AppScreens.holderPage);
                          } else {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        onClickOnAddSport: (Map sport) {
                          if (flushbarStatus != FlushbarStatus.IS_APPEARING &&
                              flushbarStatus != FlushbarStatus.IS_HIDING &&
                              flushbarStatus != FlushbarStatus.SHOWING) {
                            _bloc.onClickOnAddSport(
                              sport['sport'],
                              sport['index'],
                            );
                          } else {}
                        },
                        selectedSports: state.selectedSports,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 4.h,
                      top: 2.h,
                      right: 16.0,
                      left: 16.0,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: CustomSubmitButton(
                          buttonText: localizations.continue_n.toUpperCase(),
                          backgroundColor: AppColors.primaryColor,
                          onPressed: () {
                            if (widget.viewType == ViewType.initial ||
                                widget.viewType == ViewType.splash ||
                                widget.viewType == ViewType.profile) {
                              _bloc.onCheckVariationsSelection(widget.profileType);
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                          hoverColor: Colors.grey.withOpacity(0.5),
                          textColor: Colors.white,
                          isLoading: state.isUpdatingInformation,
                          disable: state.isUpdatingInformation,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: CustomStepHolderPage(
                    hideBackButton: widget.viewType == ViewType.splash,
                    title: state.currentPageIndex == 0
                        ? localizations.add_your_sports
                        : localizations.add_your_skills,
                    viewType: widget.viewType,
                    step1: AddUserSports(
                      state: state,
                      localizations: localizations,
                      onSubmit: () {
                        _pageController.animateToPage(
                          state.currentPageIndex + 1,
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 500),
                        );
                        _bloc.onChangePageIndex(state.currentPageIndex + 1);
                        if (flushbarStatus != FlushbarStatus.IS_APPEARING &&
                            flushbarStatus != FlushbarStatus.IS_HIDING &&
                            flushbarStatus != FlushbarStatus.SHOWING) {
                          if (state.selectedSports.length > 3) {
                            _bloc.onMaximumSportsFailure();
                          } else if (state.selectedSports.isEmpty) {
                            _bloc.onAtLeastOneSport();
                          } else {
                            _pageController.animateToPage(
                              state.currentPageIndex + 1,
                              curve: Curves.ease,
                              duration: const Duration(milliseconds: 500),
                            );
                            _bloc.onChangePageIndex(
                              state.currentPageIndex + 1,
                            );
                          }
                        }
                      },
                      onClickOnAddSport: (Map sport) {
                        if (flushbarStatus != FlushbarStatus.IS_APPEARING &&
                            flushbarStatus != FlushbarStatus.IS_HIDING &&
                            flushbarStatus != FlushbarStatus.SHOWING) {
                          _bloc.onClickOnAddSport(
                            sport['sport'],
                            sport['index'],
                          );
                        } else {}
                      },
                      selectedSports: state.selectedSports,
                    ),
                    step2: AddUserSkills(
                      state: state,
                      localizations: localizations,
                      onSubmit: () {
                        if (widget.viewType == ViewType.initial) {
                          Navigator.pushNamed(context, AppScreens.holderPage);
                        } else {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      selectedSports: state.selectedSports,
                      onUpdateSport: (Map map) {
                        if (map['type'] == "positions") {
                          String value = "";
                          for (int i = 0; i < map['value'].length; i++) {
                            if (i == map['value'].length - 1) {
                              value = "$value${map['value'][i]}";
                            } else {
                              value = "$value${map['value'][i]},";
                            }
                          }
                          _bloc.onUpdateSport(
                            sportModel: map['sport'],
                            index: map['index'],
                            value: value,
                            sIndex: map['sIndex'],
                            type: map['type'],
                          );
                        } else {
                          _bloc.onUpdateSport(
                            sportModel: map['sport'],
                            type: map['type'],
                            index: map['index'],
                            value: map['value'],
                            sIndex: map['sIndex'],
                            sportPath: map['sport_path'],
                            variationId: map['variation_id'],
                          );
                        }
                      },
                      onRemoveVariationInsideSport: (map) {
                        _bloc.onRemoveVariationInsideSport(
                          map['sport'],
                          map['index'],
                          map['variation_id'],
                        );
                      },
                    ),
                    currentPageIndex: state.currentPageIndex,
                    pageController: _pageController,
                    onBackButtonClicked: () {
                      if (state.currentPageIndex == 1) {
                        _pageController.animateToPage(
                          0,
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 500),
                        );
                        _bloc.onChangePageIndex(0);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 4.h,
                    top: 2.h,
                    right: 16.0,
                    left: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: CustomSubmitButton(
                        buttonText: localizations.continue_n.toUpperCase(),
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () {
                          if (state.currentPageIndex == 0) {
                            if (flushbarStatus != FlushbarStatus.IS_APPEARING &&
                                flushbarStatus != FlushbarStatus.IS_HIDING &&
                                flushbarStatus != FlushbarStatus.SHOWING) {
                              /*if (state.selectedSports.length > 3) {
                                  _bloc.onMaximumSportsFailure();
                                } else*/
                              if (state.selectedSports.isEmpty) {
                                _bloc.onAtLeastOneSport();
                              } else {
                                _pageController.animateToPage(
                                  state.currentPageIndex + 1,
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 500),
                                );
                                _bloc.onChangePageIndex(
                                  state.currentPageIndex + 1,
                                );
                              }
                            }
                          } else {
                            if (widget.viewType == ViewType.initial ||
                                widget.viewType == ViewType.splash ||
                                widget.viewType == ViewType.profile) {
                              _bloc.onCheckVariationsSelection(widget.profileType);
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          }
                        },
                        hoverColor: Colors.grey.withOpacity(0.5),
                        textColor: Colors.white,
                        isLoading: state.isUpdatingInformation,
                        disable: state.isUpdatingInformation,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
