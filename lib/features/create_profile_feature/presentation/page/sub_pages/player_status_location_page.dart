import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart' as state_model;
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/converters.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/custom_image_picker.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_dropdown_widget.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_bloc.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_event.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_state.dart';
import 'package:sizer/sizer.dart';

class PlayerStatusLocationPage extends StatefulWidget {
  final AppLocalizations localizations;
  final Function onStepSubmit;
  final CreateProfileBloc bloc;
  final Function(String) onChangeCountry;

  const PlayerStatusLocationPage({
    required this.localizations,
    required this.onStepSubmit,
    required this.onChangeCountry,
    required this.bloc,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerStatusLocationPage> createState() =>
      _PlayerStatusLocationPageState();
}

class _PlayerStatusLocationPageState extends State<PlayerStatusLocationPage>
    with FlushBarMixin {
  TextEditingController _playerHeightController = TextEditingController();
  TextEditingController _playerFootHeightController = TextEditingController();
  TextEditingController _playerInchHeightController = TextEditingController();
  TextEditingController _playerWeightController = TextEditingController();
  TextEditingController _homeAddressController = TextEditingController();
  CustomImagePicker ciPicker = CustomImagePicker();
  Uint8List webImage = Uint8List(10);

  @override
  void initState() {
    super.initState();
    // UserModel user = getIt<PrefsHelper>().userInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.bloc,
      listener: (BuildContext context, CreateProfileState state) {
        if (state.currentUserLoaded) {
          UserModel user = state.currentUser!;
          _playerHeightController = TextEditingController(
            text: user.height == null ? "" : user.height.toString(),
          );
          _playerWeightController = TextEditingController(
            text: user.weight == null ? "" : user.weight.toString(),
          );
          _homeAddressController = TextEditingController(
            text: user.originAddress ?? "",
          );
          widget.bloc.onClearFailures();
        }
      },
      child: BlocBuilder(
        bloc: widget.bloc,
        builder: (BuildContext context, CreateProfileState state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          onTap: () async {
                            ciPicker.pickImage(
                              context: context,
                              source: ImageSource.camera,
                              onMobilePicked: (XFile? file) async {
                                CroppedFile? cFile = await _cropImage(file!);
                                widget.bloc.add(
                                  ChangingProfileImage(
                                    file:
                                        cFile == null ? File(file.path) : null,
                                    croppedFile: cFile,
                                  ),
                                );
                                setState(() {});
                              },
                              onWebPicked: (XFile? file) async {
                                CroppedFile? cFile = await _cropImage(file!);
                                final data = await file.readAsBytes();
                                widget.bloc.add(
                                  ChangingProfileImage(
                                    xfile: file,
                                    uint8list: cFile != null
                                        ? await cFile.readAsBytes()
                                        : data,
                                  ),
                                );
                                setState(() {});
                              },
                            );
                          },
                          child: Text(
                            widget.localizations.camera,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            ciPicker.pickImage(
                              context: context,
                              source: ImageSource.gallery,
                              onMobilePicked: (XFile? file) async {
                                CroppedFile? cFile = await _cropImage(file!);
                                widget.bloc.add(
                                  ChangingProfileImage(
                                    file:
                                        cFile == null ? File(file.path) : null,
                                    croppedFile: cFile,
                                  ),
                                );
                                setState(() {});
                              },
                              onWebPicked: (XFile? file) async {
                                final data = await file!.readAsBytes();
                                widget.bloc.add(
                                  ChangingProfileImage(
                                    uint8list: data,
                                    xfile: file,
                                  ),
                                );
                                setState(() {});
                              },
                            );
                          },
                          child: Text(
                            widget.localizations.gallery,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ];
                    },
                    offset: const Offset(0.1, 0),
                    child: Container(
                      width: context.h * 0.2,
                      height: context.h * 0.2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: state.profileParams.profileImage == null &&
                              state.profileParams.profileImageWeb == null &&
                              state.profileParams.croppedProfileImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/general/profile.svg',
                                  width: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.06
                                      : context.w * 0.085,
                                  height: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.06
                                      : context.w * 0.085,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  widget.localizations.upload_profile_photo,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.secondaryFontColor,
                                    fontSize: Dimensions.checkKIsWeb(context)
                                        ? context.h * 0.025
                                        : 10.sp,
                                  ),
                                ),
                              ],
                            )
                          : ClipOval(
                              clipBehavior: Clip.hardEdge,
                              child: kIsWeb
                                  ? state.profileParams.croppedProfileImage !=
                                          null
                                      ? Image.file(
                                          File(
                                            state.profileParams
                                                .croppedProfileImage!.path,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          state.profileParams.profileImageWeb!,
                                        )
                                  : state.profileParams.croppedProfileImage !=
                                          null
                                      ? Image.file(
                                          File(
                                            state.profileParams
                                                .croppedProfileImage!.path,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          state.profileParams.profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.03,
                  ),
                  Text(
                    widget.localizations.player_status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.03
                          : 13.sp,
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      state.profileParams.heightSymbol == "Cm"
                          ? Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CustomTextFieldWidget(
                                  onChanged: (String val) {
                                    widget.bloc.add(ChangingHeight(val));
                                  },
                                  // showError: state.errorValidationHeight,
                                  showError: false,
                                  // errorText: widget.localizations.invalid_input,
                                  hintText: widget.localizations.enter_height,
                                  controller: _playerHeightController,
                                  inputType: TextInputType.number,
                                ),
                              ),
                            )
                          : Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CustomTextFieldWidget(
                                  onlyDigits: true,
                                  onChanged: (String val) {
                                    widget.bloc.add(ChangingFootHeight(val));
                                  },
                                  // showError: state.errorValidationHeight,
                                  showError: false,
                                  // errorText: widget.localizations.invalid_input,
                                  hintText: "Ft",
                                  controller: _playerFootHeightController,
                                  inputType: TextInputType.number,
                                ),
                              ),
                            ),
                      state.profileParams.heightSymbol == "Cm"
                          ? Container()
                          : const Text(
                              "'",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                              ),
                            ),
                      state.profileParams.heightSymbol == "Cm"
                          ? Container()
                          : Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CustomTextFieldWidget(
                                  onlyDigits: true,
                                  onChanged: (String val) {
                                    widget.bloc.add(ChangingInchHeight(val));
                                  },
                                  // showError: state.errorValidationHeight,
                                  showError: false,
                                  // errorText: widget.localizations.invalid_input,
                                  hintText: "Inch",
                                  controller: _playerInchHeightController,
                                  inputType: TextInputType.number,
                                ),
                              ),
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CustomDropDownWidget<String>(
                            options: const ["Cm", "Ft"],
                            onChange: (String val) {
                              onChangeHeightSymbol(val, state);
                            },
                            // showError: state.errorValidationHeightSymbol,
                            showError: false,
                            messageError: widget.localizations.required_field,
                            hint: 'Cm',
                            selectedOption:
                                state.profileParams.heightSymbol.isEmpty
                                    ? null
                                    : state.profileParams.heightSymbol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomTextFieldWidget(
                          onChanged: (String val) {
                            widget.bloc.add(ChangingWeight(val));
                          },
                          // showError: state.errorValidationWeight,
                          showError: false,
                          errorText: widget.localizations.invalid_input,
                          hintText: widget.localizations.enter_weight,
                          controller: _playerWeightController,
                          inputType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomDropDownWidget<String>(
                          options: const ["Kg", "Pound"],
                          onChange: (String val) {
                            onChangeWeightSymbol(val, state);
                          },
                          hint: 'Kg',
                          // showError: state.errorValidationWeightSymbol,
                          showError: false,
                          messageError: widget.localizations.required_field,
                          selectedOption:
                              state.profileParams.weightSymbol.isEmpty
                                  ? null
                                  : state.profileParams.weightSymbol,
                        ),
                      ),
                    ],
                  ),
                  getErrorValidationMessage(state).isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            getErrorValidationMessage(state),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  Text(
                    widget.localizations.my_current_location,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.03
                          : 13.sp,
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.02,
                  ),
                  CustomDropDownWidget<CountryModel>(
                    options: state.countries,
                    showFlags: true,
                    onChange: (val) {
                      setState(() {
                        widget.bloc.add(ChangingCurrentCountry(val));
                      });
                      widget.onChangeCountry(val.name);
                    },
                    showError: state.errorValidationCurrentCountry,
                    messageError: widget.localizations.required_field,
                    hint: widget.localizations.country,
                    selectedOption: state.profileParams.currentCountry,
                    isLoading: state.isLoadingCountries,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomDropDownWidget<state_model.State>(
                    options: state.loadedStateModelForStep2 == null
                        ? []
                        : state.loadedStateModelForStep2!.states,
                    onChange: (val) {
                      setState(() {
                        widget.bloc.add(ChangingCurrentState(val));
                      });
                    },
                    showError: state.errorValidationCurrentState,
                    messageError: widget.localizations.required_field,
                    hint: widget.localizations.state,
                    selectedOption: state.profileParams.currentState,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomDropDownWidget<String>(
                    options: state.profileParams.currentState == null
                        ? []
                        : state.profileParams.currentState!.cities,
                    onChange: (val) {
                      setState(() {
                        widget.bloc.add(ChangingCurrentCity(val));
                      });
                    },
                    showError: state.errorValidationCurrentCity,
                    messageError: widget.localizations.required_field,
                    hint: widget.localizations.city_town,
                    selectedOption: state.profileParams.currentCity,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingCurrentAddress(val));
                    },
                    showError: state.errorValidationCurrentAddress,
                    errorText: widget.localizations.required_field,
                    hintText: widget.localizations.home_address,
                    controller: _homeAddressController,
                    inputType: TextInputType.name,
                    maxLines: 4,
                  ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  CustomSubmitButton(
                    buttonText: widget.localizations.yes_done.toUpperCase(),
                    backgroundColor: AppColors.primaryColor,
                    onPressed: () {
                      widget.onStepSubmit();
                    },
                    hoverColor: Colors.grey.withOpacity(0.5),
                    textColor: Colors.white,
                    isLoading: state.isUpdatingInformation,
                    disable: state.isUpdatingInformation,
                  ),
                  SizedBox(
                    height: context.h * 0.07,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  onChangeWeightSymbol(String val, CreateProfileState state) {
    if (val != state.profileParams.weightSymbol) {
      setState(() {
        widget.bloc.add(ChangingWeightSymbol(val));
        widget.bloc.add(ChangingHeightSymbol(val == "Kg" ? "Cm" : "Ft"));
      });

      if (val == "Kg") {
        widget.bloc.add(
          ChangingWeight(
            Converters.poundToKg(state.profileParams.weight!).toString(),
          ),
        );

        double theHeight = Converters.ftToCm(
          state.profileParams.footHeight +
              (state.profileParams.inchHeight /
                  pow(10, (state.profileParams.inchHeight.toString().length))),
        );
        widget.bloc.add(ChangingHeight(theHeight.toString()));

        _playerHeightController = TextEditingController(
          text: theHeight == 0.0
              ? ""
              : num.parse(theHeight.toString()).toStringAsFixed(2),
        );
        _playerWeightController = TextEditingController(
          text: state.profileParams.weight == 0.0
              ? ""
              : num.parse(
                  Converters.poundToKg(state.profileParams.weight!).toString(),
                ).toStringAsFixed(2),
        );
      } else {
        widget.bloc.add(
          ChangingWeight(
            Converters.kgToPound(state.profileParams.weight!).toString(),
          ),
        );

        _playerFootHeightController = TextEditingController(
          text: state.profileParams.footHeight == 0.0
              ? ""
              : state.profileParams.footHeight.toString(),
        );

        _playerInchHeightController = TextEditingController(
          text: state.profileParams.inchHeight == 0.0
              ? ""
              : state.profileParams.inchHeight.toString().length > 2
                  ? state.profileParams.inchHeight.toString().substring(0, 2)
                  : state.profileParams.inchHeight.toString(),
        );

        _playerWeightController = TextEditingController(
          text: state.profileParams.weight == 0.0
              ? ""
              : num.parse(
                  Converters.kgToPound(state.profileParams.weight!).toString(),
                ).toStringAsFixed(2),
        );
      }
    }
  }

  onChangeHeightSymbol(String val, CreateProfileState state) {
    if (val != state.profileParams.heightSymbol) {
      setState(() {
        widget.bloc.add(ChangingHeightSymbol(val));
        widget.bloc.add(ChangingWeightSymbol(val == "Cm" ? "Kg" : "Pound"));
      });

      if (val == "Cm") {
        widget.bloc.add(
          ChangingWeight(
            Converters.poundToKg(state.profileParams.weight!).toString(),
          ),
        );
        double theHeight = Converters.ftToCm(
          state.profileParams.footHeight +
              (state.profileParams.inchHeight /
                  pow(10, (state.profileParams.inchHeight.toString().length))),
        );
        widget.bloc.add(ChangingHeight(theHeight.toString()));

        _playerHeightController = TextEditingController(
          text: theHeight == 0.0
              ? ""
              : num.parse(theHeight.toString()).toStringAsFixed(2),
        );
        _playerWeightController = TextEditingController(
          text: state.profileParams.weight == 0.0
              ? ""
              : num.parse(
                  Converters.poundToKg(state.profileParams.weight!).toString(),
                ).toStringAsFixed(2),
        );
      } else {
        widget.bloc.add(
          ChangingWeight(
            Converters.kgToPound(state.profileParams.weight!).toString(),
          ),
        );

        _playerFootHeightController = TextEditingController(
          text: state.profileParams.footHeight == 0.0
              ? ""
              : state.profileParams.footHeight.toString(),
        );

        _playerInchHeightController = TextEditingController(
          text: state.profileParams.inchHeight == 0.0
              ? ""
              : state.profileParams.inchHeight.toString().length > 2
                  ? state.profileParams.inchHeight.toString().substring(0, 2)
                  : state.profileParams.inchHeight.toString(),
        );

        _playerWeightController = TextEditingController(
          text: state.profileParams.weight == 0.0
              ? ""
              : num.parse(
                  Converters.kgToPound(state.profileParams.weight!).toString(),
                ).toStringAsFixed(2),
        );
      }
    }
  }

  String getErrorValidationMessage(CreateProfileState state) {
    if (state.errorValidationHeight) {
      return "You should enter valid height value!";
    } else if (state.errorValidationWeight) {
      return "You should enter valid weight value!";
    } else if (state.errorValidationHeightSymbol) {
      return "You should select the symbols before going forward!";
    } else {
      return "";
    }
  }

  Future<CroppedFile?> _cropImage(XFile pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: CroppieBoundary(
            width: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.w * 0.6).toInt(),
            height: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.h * 0.6).toInt(), // 520
          ),
          viewPort: CroppieViewPort(
            width: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.w * 0.6).toInt(),
            height: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.h * 0.6).toInt(), // 520
            type: 'square',
          ),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      return croppedFile;
    }
    return null;
    return null;
  }
}
