import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart' as state_model;
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_dropdown_widget.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_bloc.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_event.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_state.dart';
import 'package:phone_number/phone_number.dart' as phone_number_validator;
import 'package:sizer/sizer.dart';

class PlayerInformationPage extends StatefulWidget {
  final AppLocalizations localizations;
  final Function onStepSubmit;
  final CreateProfileBloc bloc;
  final Function(String) onChangeCountry;

  const PlayerInformationPage({
    required this.localizations,
    required this.bloc,
    required this.onStepSubmit,
    required this.onChangeCountry,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerInformationPage> createState() => _PlayerInformationPageState();
}

class _PlayerInformationPageState extends State<PlayerInformationPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _homeAddressController = TextEditingController();
  PhoneNumber p = PhoneNumber(dialCode: "+971", phoneNumber: "", isoCode: 'AE');

  @override
  void initState() {
    UserModel user = getIt<PrefsHelper>().userInfo();
    // _bloc.onGetProfileInformation(user.id);

    // String phoneNumber = user == null
    //     ? ""
    //     : user.mobileNumber == null
    //         ? ""
    //         : user.mobileNumber!.split(' ').isEmpty
    //             ? user.mobileNumber!
    //             : user.mobileNumber!.split(' ')[1];

    // _phoneNumberController = TextEditingController(text: user.mobileNumber);

    _phoneNumberController = TextEditingController(
      text: user.mobileNumber == null ? "" : user.mobileNumber!,
    );
    initializePhoneNumber(user);
    widget.bloc.add(GetCurrentUser());
    super.initState();
  }

  initializePhoneNumber(UserModel user) async {
    if (user.mobileCountryCode != null && user.mobileNumber != null) {
      setState(() {
        p = PhoneNumber(
          isoCode: 'AE',
          dialCode: "+${user.mobileCountryCode}",
          phoneNumber: "",
        );
      });

      if (Platform.isIOS) {
        try {
          final validatedPhoneNumber =
              await phone_number_validator.PhoneNumberUtil()
                  .parse("+${user.mobileCountryCode!}${user.mobileNumber!}");
          PhoneNumber number = PhoneNumber(
            phoneNumber: "", // save
            dialCode: validatedPhoneNumber.countryCode, // save
            isoCode: validatedPhoneNumber.regionCode,
          );
          _phoneNumberController = TextEditingController(
            text: user.mobileNumber == null ? "" : user.mobileNumber!,
          ); // save
          widget.bloc.add(ChangingPhoneNumber(number)); // save
          setState(() {
            p = number;
          });
        } catch (e) {}
      } else {
        PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
          "+${user.mobileCountryCode!} ${user.mobileNumber!}",
        );
        widget.bloc.add(ChangingPhoneNumber(number));
        setState(() {
          p = number;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.bloc,
      listener: (BuildContext context, CreateProfileState state) {
        if (state.currentUserLoaded) {
          UserModel user = state.currentUser!;
          _usernameController = TextEditingController(
            text: user.username ?? "",
          );
          _firstNameController = TextEditingController(
            text: user.firstName ?? "",
          );
          _lastNameController = TextEditingController(
            text: user.lastName ?? "",
          );
          _bioController = TextEditingController(
            text: user.bio ?? "",
          );

          _homeAddressController = TextEditingController(
            text: user.originAddress ?? "",
          );
          // _phoneNumberController = TextEditingController(
          //     text: user.mobileNumber == null ? "" : user.mobileNumber);

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
                  SizedBox(
                    height: context.h * 0.04,
                  ),
                  Text(
                    widget.localizations.select_gender_and_age,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.03
                          : 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      genderWidget(
                        svgPath: 'assets/images/general/male.png',
                        isSelected: state.profileParams.gender == "male",
                        onTap: () {
                          widget.bloc.add(ChangingGender("male"));
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      genderWidget(
                        svgPath: 'assets/images/general/female.png',
                        isSelected: state.profileParams.gender == "female",
                        onTap: () {
                          widget.bloc.add(ChangingGender("female"));
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  Text(
                    widget.localizations.player_information,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.03
                          : 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.02,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingUsername(val));
                    },
                    showError: state.errorValidationUsername,
                    errorText: widget.localizations.invalid_input,
                    hintText: widget.localizations.username,
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    inputType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingFirstName(val));
                    },
                    hintText: widget.localizations.first_name,
                    controller: _lastNameController,
                    showError: state.errorValidationFirstName,
                    errorText: widget.localizations.invalid_input,
                    textInputAction: TextInputAction.next,
                    inputType: TextInputType.name,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingLastName(val));
                    },
                    hintText: widget.localizations.last_name,
                    controller: _firstNameController,
                    showError: state.errorValidationLastName,
                    errorText: widget.localizations.invalid_input,
                    textInputAction: TextInputAction.done,
                    inputType: TextInputType.name,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingBio(val));
                    },
                    hintText: widget.localizations.bio,
                    controller: _bioController,
                    textInputAction: TextInputAction.next,
                    inputType: TextInputType.name,
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  birthOfDate(state),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  phoneNumberWidget(state),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  Text(
                    widget.localizations.i_am_from,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.03
                          : 13.sp,
                      fontWeight: FontWeight.bold,
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
                        widget.bloc.add(ChangingOriginCountry(val));
                      });
                      widget.onChangeCountry(val.name);
                    },
                    showError: state.errorValidationOriginCountry,
                    messageError: widget.localizations.required_field,
                    hint: widget.localizations.country,
                    selectedOption: state.profileParams.originCountry,
                    isLoading: state.isLoadingCountries,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomDropDownWidget<state_model.State>(
                    options: state.loadedStateModelForStep1 == null
                        ? []
                        : state.loadedStateModelForStep1!.states,
                    onChange: (val) {
                      setState(() {
                        widget.bloc.add(ChangingOriginState(val));
                      });
                    },
                    hint: widget.localizations.state,
                    isLoading: state.isLoadingState,
                    showError: state.errorValidationOriginState,
                    messageError: widget.localizations.required_field,
                    selectedOption: state.loadedStateModelForStep1 == null
                        ? null
                        : state.profileParams.originState,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomDropDownWidget<String>(
                    options: state.profileParams.originState == null
                        ? []
                        : state.profileParams.originState!.cities,
                    onChange: (val) {
                      setState(() {
                        widget.bloc.add(ChangingOriginCity(val));
                      });
                    },
                    showError: state.errorValidationOriginCity,
                    messageError: widget.localizations.required_field,
                    hint: widget.localizations.city_town,
                    selectedOption: state.profileParams.originState == null
                        ? null
                        : state.profileParams.originCity,
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  CustomTextFieldWidget(
                    onChanged: (val) {
                      widget.bloc.add(ChangingOriginAddress(val));
                    },
                    showError: state.errorValidationOriginAddress,
                    errorText: widget.localizations.invalid_input,
                    hintText: widget.localizations.home_address,
                    controller: _homeAddressController,
                    textInputAction: TextInputAction.done,
                    onSubmit: (v) {
                      widget.onStepSubmit();
                    },
                    inputType: TextInputType.name,
                    maxLines: 4,
                  ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  CustomSubmitButton(
                    buttonText: widget.localizations.continue_n.toUpperCase(),
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

  Widget phoneNumberWidget(CreateProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          height: context.h * 0.075,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: AppColors.textFieldColor,
            border: Border.all(
              color: state.errorValidationPhoneNumber
                  ? Colors.red
                  : AppColors.textFieldColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InternationalPhoneNumberInput(
                  textStyle: TextStyle(
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.025
                        : 10.sp,
                  ),
                  onInputChanged: (PhoneNumber number) {
                    widget.bloc.add(ChangingPhoneNumber(number));
                  },
                  onInputValidated: (bool value) {
                    widget.bloc.add(ChangingPhoneValidation(!value));
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                    trailingSpace: false,
                    useEmoji: true,
                    setSelectorButtonAsPrefixIcon: true,
                  ),
                  ignoreBlank: true,
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.02
                          : 10.sp, // 10
                      color: AppColors.hintTextFieldColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  initialValue: p,
                  textFieldController: _phoneNumberController,
                  formatInput: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputBorder: const OutlineInputBorder(),
                  onSaved: (PhoneNumber number) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SvgPicture.asset(
                  'assets/images/general/phone.svg',
                  height: context.h * 0.03,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: state.errorValidationPhoneNumber,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Text(
              "Enter a valid mobile number",
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.025 : 10.sp,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget genderWidget({
    required String svgPath,
    required bool isSelected,
    required Function onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: Container(
          height: Dimensions.checkKIsWeb(context)
              ? context.h * 0.15
              : context.w * 0.4,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: AppColors.primaryColor, width: 2)
                : null,
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  svgPath,
                  height: Dimensions.checkKIsWeb(context)
                      ? context.h * 0.12
                      : context.w * 0.35,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
                child: Align(
                  alignment: widget.localizations.localeName == "ar"
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,
                  child: Container(
                    width: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.02
                        : context.w * 0.05,
                    height: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.02
                        : context.w * 0.05,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.015
                                : context.w * 0.03,
                            height: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.015
                                : context.w * 0.03,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget birthOfDate(CreateProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final result = await showDatePicker(
              context: context,
              initialDate: DateTime(1999, 08, 26),
              firstDate: DateTime(1900),
              lastDate: DateTime(DateTime.now().year - 5),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Colors.black,
                    colorScheme: const ColorScheme.light(primary: Colors.black),
                  ),
                  child: child!,
                );
              },
            ).then((value) {
              if (value != null) {
                setState(() {
                  widget.bloc.add(ChangingDateOfBirth(value));
                });
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 4.0),
            height: context.h * 0.075,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: AppColors.textFieldColor,
              border: Border.all(
                color: state.errorValidationDateOfBirth
                    ? Colors.red
                    : AppColors.textFieldColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/general/calender.svg',
                    height: context.h * 0.035,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    state.profileParams.dob == null
                        ? widget.localizations.date_of_birth
                        : state.profileParams.dob.toString().substring(0, 10),
                    style: TextStyle(
                      color: state.profileParams.dob == null
                          ? AppColors.secondaryFontColor
                          : AppColors.primaryFontColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: state.errorValidationDateOfBirth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Text(
              widget.localizations.you_should_select_date_of_birth,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
