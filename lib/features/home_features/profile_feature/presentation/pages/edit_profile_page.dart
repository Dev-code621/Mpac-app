import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart' as state_model;
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/converters.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/custom_image_picker.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_dropdown_widget.dart';
import 'package:mpac_app/core/utils/widgets/custom_profile_information.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_bloc.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_event.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_state.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_bloc.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_state.dart';
import 'package:phone_number/phone_number.dart' as phone_number_validator;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_io/io.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with FlushBarMixin {
  late AppLocalizations localizations;
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _playerHeightController = TextEditingController();
  TextEditingController _playerWeightController = TextEditingController();
  TextEditingController _homeAddressController = TextEditingController();
  TextEditingController _playerFootHeightController = TextEditingController();
  TextEditingController _playerInchHeightController = TextEditingController();

  final _bloc = getIt<ProfileBloc>();
  final _accountBloc = getIt<MyAccountBloc>();

  CustomImagePicker ciPicker = CustomImagePicker();

  PhoneNumber p = PhoneNumber(dialCode: "+971", phoneNumber: "", isoCode: 'AE');

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    UserModel user = getIt<PrefsHelper>().userInfo();
    // _bloc.onGetProfileInformation(user.id);

    _lastNameController = TextEditingController(
      text: user.lastName != null ? user.lastName! : "",
    );
    _firstNameController = TextEditingController(
      text: user.firstName != null ? user.firstName! : "",
    );

    _bioController = TextEditingController(
      text: user.bio != null ? user.bio! : "",
    );
    //_phoneNumberController = TextEditingController(
    //  text: user.mobileNumber == null ? "" : user.mobileNumber!); // save
    _phoneNumberController = TextEditingController(
      text: user.mobileNumber == null ? "" : user.mobileNumber!,
    );

    initializePhoneNumber(user);

    _playerHeightController = TextEditingController(
      text: user.height != null
          ? user.measureSystem == "metric"
              ? num.parse(user.height.toString()).toStringAsFixed(2)
              : num.parse(Converters.cmToFt(user.height!).toString())
                  .toStringAsFixed(2)
          : "",
    );
    double theHeight =
        user.height == null ? 0 : Converters.cmToFt(user.height!);

    _playerFootHeightController = TextEditingController(
      text: theHeight.toString().split('.').isEmpty
          ? theHeight.toString()
          : theHeight.toString().split('.').first,
    );

    _playerInchHeightController = TextEditingController(
      text: theHeight.toString().split('.').length == 2
          ? theHeight.toString().split('.')[1].toString().length > 2
              ? theHeight.toString().split('.')[1].toString().substring(0, 2)
              : theHeight.toString().split('.')[1]
          : theHeight.toString(),
    );

    _playerWeightController = TextEditingController(
      text: user.weight != null
          ? user.measureSystem == "metric"
              ? num.parse(user.weight.toString()).toStringAsFixed(2)
              : num.parse(Converters.kgToPound(user.weight!).toString())
                  .toStringAsFixed(2)
          : "",
    );
    _homeAddressController = TextEditingController(
      text: user.currentAddress != null ? user.currentAddress! : "",
    );

    _bloc.onInitializeEditProfile();
    _bloc.onGetCountries();
    _bloc.onGetStates(user.currentState);
  }

  initializePhoneNumber(UserModel user) async {
    if (user.mobileCountryCode != null && user.mobileNumber != null) {
      setState(() {
        p = PhoneNumber(
          isoCode: 'AE',
          dialCode: "+971",
          phoneNumber: "",
        );
      });

      if (Platform.isIOS) {
        try {
          final validatedPhoneNumber =
              await phone_number_validator.PhoneNumberUtil()
                  .parse("+${user.mobileCountryCode!}${user.mobileNumber!}");
          PhoneNumber number = PhoneNumber(
            phoneNumber: validatedPhoneNumber.nationalNumber, // save
            dialCode: validatedPhoneNumber.countryCode, // save
            isoCode: validatedPhoneNumber.regionCode,
          );
          _phoneNumberController = TextEditingController(
            text: user.mobileNumber == null ? "" : user.mobileNumber!,
          ); // save
          _bloc.add(ChangingPhoneNumber(number)); // save
          setState(() {
            p = number;
          });
        } catch (e) {}
      } else {
        PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
          "+${user.mobileCountryCode!} ${user.mobileNumber!}",
        );
        _bloc.add(ChangingPhoneNumber(number));
        setState(() {
          p = number;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, ProfileState state) {
        if (state.profileEdited) {
          Navigator.pop(context);
          _bloc.add(ClearFailures());
        }
        if (state.failure != null) {
          _bloc.add(ClearFailures());
          exceptionFlushBar(
            onChangeStatus: (s) {},
            onHidden: () {
              _bloc.add(ClearFailures());
            },
            duration: const Duration(milliseconds: 2000),
            message: (state.failure as ServerFailure).errorMessage ?? "Error!",
            context: context,
          );
        }
        if (state.profileLoaded) {
          // _phoneNumberController = TextEditingController(
          //     text: state.profileModelLoaded!.mobileNumber == null ?
          //         ""
          //         : state.profileModelLoaded!.mobileNumber!);
          setState(() {
            // print("state.profileModelLoaded!.mobileNumber = ${state.profileModelLoaded!.mobileNumber}");
          });

          _bloc.onClearFailure();

          // _lastNameController = TextEditingController(text: state.profileModelLoaded!.lastName != null ? state.profileModelLoaded!.lastName! : "");
          // _firstNameController = TextEditingController(
          //     text: state.profileModelLoaded!.firstName != null ? state.profileModelLoaded!.firstName! : "");
          // _phoneNumberController = TextEditingController(
          //     text: state.profileModelLoaded!.mobileNumber != null ? state.profileModelLoaded!.mobileNumber! : "");
          // _playerHeightController = TextEditingController(
          //     text: state.profileModelLoaded!.height != null ? state.profileModelLoaded!.measure_system == "metric" ? state.profileModelLoaded!.height.toString()  : Converters.cmToFt(state.profileModelLoaded!.height!).toString()  : "");
          // double theHeight = state.profileModelLoaded!.height == null ? 0 : Converters.cmToFt(state.profileModelLoaded!.height!);
          //
          // _playerFootHeightController =
          //     TextEditingController(
          //         text: theHeight.toString().split('.').isEmpty? theHeight.toString() : theHeight.toString().split('.').first);
          //
          // _playerInchHeightController =
          //     TextEditingController(
          //         text: theHeight.toString().split('.').length == 2 ?  theHeight.toString().split('.')[1] : theHeight.toString());
          //
          // _playerWeightController = TextEditingController(
          //     text: state.profileModelLoaded!.weight != null ? state.profileModelLoaded!.measure_system == "metric" ? state.profileModelLoaded!.weight.toString()  : Converters.kgToPound(state.profileModelLoaded!.weight!).toString()  : "");
          // _homeAddressController = TextEditingController(
          //     text: state.profileModelLoaded!.currentAddress != null ? state.profileModelLoaded!.currentAddress! : "");
          //
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ProfileState state) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: SizedBox(
                                height: context.h * 0.05,
                                width: context.w * 0.075,
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: const Color(0xffB7B7B7),
                                    size: context.h * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              localizations.edit_profile,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimensions.checkKIsWeb(context)
                                    ? context.h * 0.032
                                    : 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.02,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          BlocBuilder(
                            bloc: _accountBloc,
                            builder: (context, MyAccountState state) {
                              return SizedBox(
                                width: kIsWeb
                                    ? context.w * 0.17
                                    : context.w * 0.35,
                                height: kIsWeb
                                    ? context.w * 0.17
                                    : context.w * 0.35,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: kIsWeb
                                          ? context.w * 0.17
                                          : context.w * 0.35,
                                      height: kIsWeb
                                          ? context.w * 0.17
                                          : context.w * 0.35,
                                      decoration: BoxDecoration(
                                        color: getIt<SharedPreferences>()
                                                    .getString(
                                                  SharedPreferencesKeys
                                                      .userProfilePicture,
                                                ) ==
                                                null
                                            ? Colors.black.withOpacity(0.4)
                                            : Colors.black.withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: state.isUploadingPicture
                                          ? CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                              strokeWidth: 1.5,
                                            )
                                          : getIt<SharedPreferences>()
                                                      .getString(
                                                    SharedPreferencesKeys
                                                        .userProfilePicture,
                                                  ) !=
                                                  null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(100)),
                                                  child: Image.network(
                                                    getIt<SharedPreferences>()
                                                        .getString(
                                                      SharedPreferencesKeys
                                                          .userProfilePicture,
                                                    )!,
                                                    loadingBuilder: (
                                                      BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                      );
                                                    },
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  color: Colors.black54,
                                                  size: kIsWeb
                                                      ? context.w * 0.06
                                                      : context.w * 0.1,
                                                ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: GestureDetector(
                                        onTap: () {
                                          commentBottomSheet(
                                              context, context.h, context.w);
                                        },
                                        child: CustomPaint(
                                          painter: MyPainter(),
                                          size: Size(
                                            kIsWeb
                                                ? context.w * 0.17
                                                : context.w * 0.35,
                                            kIsWeb
                                                ? context.w * 0.1
                                                : context.w * 0.20,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                kIsWeb ? 3.0 : 8.0),
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: SvgPicture.asset(
                                                'assets/images/icons/edit.svg',
                                                color: Colors.black,
                                                width: kIsWeb
                                                    ? context.w * 0.03
                                                    : context.h * 0.022,
                                                height: kIsWeb
                                                    ? context.w * 0.03
                                                    : context.h * 0.022,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      /*child: Container(
                  width: context.w * 0.35,
                  height: context.w * 0.07,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100), bottomRight: Radius.circular(100)),
                    color: AppColors.secondaryFontColor.withOpacity(0.8),

                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset('assets/images/icons/edit.svg',
                        color: Colors.black, width: 20, height: 20),
                  ),
                ),*/
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: context.h * 0.04,
                          ),
                          CustomTextFieldWidget(
                            onChanged: (val) {
                              _bloc.add(ChangingFirstName(val));
                            },
                            hintText: localizations.first_name,
                            controller: _firstNameController,
                            inputType: TextInputType.name,
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          CustomTextFieldWidget(
                            onChanged: (val) {
                              _bloc.add(ChangingLastName(val));
                            },
                            hintText: localizations.last_name,
                            controller: _lastNameController,
                            inputType: TextInputType.name,
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          CustomTextFieldWidget(
                            onChanged: (val) {
                              _bloc.add(ChangingBio(val));
                            },
                            hintText: localizations.bio,
                            controller: _bioController,
                            inputType: TextInputType.name,
                            maxLines: 3,
                          ),
                          // SizedBox(
                          //   height: context.h * 0.01,
                          // ),
                          // CustomDropDownWidget<String>(
                          //   options: ["Male", "Female"],
                          //   onChange: (String val) {},
                          //   hint: 'The Gender',
                          // ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          // birthOfDate(),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          phoneNumberWidget(state),
                          // SizedBox(
                          //   height: context.h * 0.01,
                          // ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              state.profileParamsForEdit.heightSymbol == "Cm"
                                  ? Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: CustomTextFieldWidget(
                                          onChanged: (String val) {
                                            _bloc.add(ChangingHeight(val));
                                          },
                                          showError: false,
                                          hintText: localizations.enter_height,
                                          controller: _playerHeightController,
                                          inputType: TextInputType.number,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: CustomTextFieldWidget(
                                          onlyDigits: true,
                                          onChanged: (String val) {
                                            _bloc.add(ChangingFootHeight(val));
                                          },
                                          showError: false,
                                          hintText: "Ft",
                                          controller:
                                              _playerFootHeightController,
                                          inputType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                              state.profileParamsForEdit.heightSymbol == "Cm"
                                  ? Container()
                                  : const Text(
                                      "'",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                      ),
                                    ),
                              state.profileParamsForEdit.heightSymbol == "Cm"
                                  ? Container()
                                  : Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: CustomTextFieldWidget(
                                          onlyDigits: true,
                                          onChanged: (String val) {
                                            _bloc.add(ChangingInchHeight(val));
                                          },
                                          showError: false,
                                          hintText: "Inch",
                                          controller:
                                              _playerInchHeightController,
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
                                      onChangHeightSymbol(val, state);
                                    },
                                    // showError: state.errorValidationHeightSymbol,
                                    showError: false,
                                    messageError: localizations.required_field,
                                    hint: 'Cm',
                                    selectedOption: state.profileParamsForEdit
                                            .heightSymbol.isEmpty
                                        ? null
                                        : state
                                            .profileParamsForEdit.heightSymbol,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //         flex: 4,
                          //         child: CustomTextFieldWidget(
                          //           onChanged: (String val) {
                          //             _bloc.add(ChangingHeight(val));
                          //           },
                          //           hintText: localizations.enter_height,
                          //           controller: _playerHeightController,
                          //           inputType: TextInputType.number,
                          //         )),
                          //     const SizedBox(
                          //       width: 10,
                          //     ),
                          //     Expanded(
                          //         flex: 2,
                          //         child: CustomDropDownWidget<String>(
                          //           options: const ["Cm", "Ft"],
                          //           onChange: (String val) {
                          //             // setState(() {
                          //             //   _bloc.add(ChangingHeightSymbol(val));
                          //             //   _bloc.add(ChangingWeightSymbol(
                          //             //       val == "Cm" ? "Kg" : "Pound"));
                          //             // });
                          //             if(val != state.profileParamsForEdit.heightSymbol) {
                          //               setState(() {
                          //                 _bloc.add(ChangingHeightSymbol(val));
                          //                 _bloc.add(ChangingWeightSymbol(val == "Cm" ? "Kg" : "Pound"));
                          //               });
                          //
                          //               if (val == "Cm") {
                          //                 _playerHeightController = TextEditingController(text: Converters.ftToCm(state.profileParamsForEdit.height!).toString());
                          //                 _playerWeightController = TextEditingController(text: Converters.poundToKg(state.profileParamsForEdit.weight!).toString());
                          //               } else {
                          //                 _playerHeightController = TextEditingController(text: Converters.cmToFt(state.profileParamsForEdit.height!).toString());
                          //                 _playerWeightController = TextEditingController(text: Converters.kgToPound(state.profileParamsForEdit.weight!).toString());
                          //
                          //               }
                          //             }
                          //           },
                          //           hint: 'Cm',
                          //           selectedOption: state.profileParamsForEdit
                          //                   .heightSymbol.isEmpty
                          //               ? null
                          //               : state.profileParamsForEdit.heightSymbol,
                          //         )),
                          //   ],
                          // ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: CustomTextFieldWidget(
                                  onChanged: (String val) {
                                    _bloc.add(ChangingWeight(val));
                                  },
                                  hintText: localizations.enter_weight,
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
                                  selectedOption: state.profileParamsForEdit
                                          .weightSymbol.isEmpty
                                      ? null
                                      : state.profileParamsForEdit.weightSymbol,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          CustomDropDownWidget<CountryModel>(
                            options: state.countries,
                            onChange: (val) {
                              setState(() {
                                _bloc.add(ChangingCurrentCountry(val));
                              });
                            },
                            showError: state.errorValidationCurrentCountry,
                            messageError: localizations.required_field,
                            hint: localizations.country,
                            selectedOption:
                                state.profileParamsForEdit.currentCountry,
                            isLoading: state.isLoadingCountries,
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          CustomDropDownWidget<state_model.State>(
                            options: state.loadedStateModel == null
                                ? []
                                : state.loadedStateModel!.states,
                            onChange: (val) {
                              setState(() {
                                _bloc.add(ChangingCurrentState(val));
                              });
                            },
                            hint: localizations.state,
                            isLoading: state.isLoadingState,
                            showError: state.errorValidationCurrentState,
                            messageError: localizations.required_field,
                            selectedOption: state.loadedStateModel == null
                                ? null
                                : state.profileParamsForEdit.currentState,
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          CustomTextFieldWidget(
                            onChanged: (val) {
                              _bloc.add(ChangingCurrentAddress(val));
                            },
                            hintText: localizations.home_address,
                            controller: _homeAddressController,
                            inputType: TextInputType.name,
                            maxLines: 4,
                          ),
                          SizedBox(
                            height: context.h * 0.01,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.h, top: 4.h),
                            child: CustomSubmitButton(
                              buttonText: localizations.save.toUpperCase(),
                              backgroundColor: AppColors.primaryColor,
                              onPressed: () {
                                _bloc.add(UpdateProfileInformation());
                              },
                              hoverColor: Colors.grey.withOpacity(0.5),
                              textColor: Colors.white,
                              isLoading: state.isEditingProfile,
                              disable: state.isEditingProfile,
                            ),
                          ),
                        ],
                      ),
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

  onChangHeightSymbol(String val, ProfileState state) {
    if (val != state.profileParamsForEdit.heightSymbol) {
      setState(() {
        _bloc.add(ChangingHeightSymbol(val));
        _bloc.add(ChangingWeightSymbol(val == "Cm" ? "Kg" : "Pound"));
      });

      if (val == "Cm") {
        _bloc.add(
          ChangingWeight(
            Converters.poundToKg(state.profileParamsForEdit.weight!).toString(),
          ),
        );
        _bloc.add(
          ChangingHeight(
            Converters.ftToCm(state.profileParamsForEdit.height!).toString(),
          ),
        );
        // double theHeight = Converters.ftToCm(
        //     state.profileParamsForEdit.footHeight +
        //         (state.profileParamsForEdit.inchHeight /
        //             pow(
        //                 10,
        //                 (state.profileParamsForEdit.inchHeight
        //                     .toString()
        //                     .length))));
        //

        _playerHeightController = TextEditingController(
          text: num.parse(
            Converters.ftToCm(state.profileParamsForEdit.height!).toString(),
          ).toStringAsFixed(2),
        );
        _playerWeightController = TextEditingController(
          text: state.profileParamsForEdit.weight! == 0.0
              ? ""
              : num.parse(
                  Converters.poundToKg(state.profileParamsForEdit.weight!)
                      .toString(),
                ).toStringAsFixed(2),
        );
      } else {
        _bloc.add(
          ChangingWeight(
            Converters.kgToPound(state.profileParamsForEdit.weight!).toString(),
          ),
        );
        _bloc.add(
          ChangingHeight(
            Converters.cmToFt(state.profileParamsForEdit.height!).toString(),
          ),
        );
        double theHeight =
            Converters.cmToFt(state.profileParamsForEdit.height!);
        _playerFootHeightController = TextEditingController(
          text: theHeight.toString().split('.').isEmpty
              ? state.profileParamsForEdit.footHeight == 0.0
                  ? ""
                  : ""
              : int.parse(theHeight.toString().split('.').first).toString(),
        );

        _playerInchHeightController = TextEditingController(
          text: theHeight.toString().split('.').length == 2
              ? int.parse(theHeight.toString().split('.')[1])
                          .toString()
                          .length >
                      2
                  ? int.parse(theHeight.toString().split('.')[1])
                      .toString()
                      .substring(0, 2)
                  : int.parse(theHeight.toString().split('.')[1]).toString()
              : state.profileParamsForEdit.inchHeight == 0.0
                  ? ""
                  : "",
        );

        _playerWeightController = TextEditingController(
          text: state.profileParamsForEdit.weight! == 0.0
              ? ""
              : num.parse(
                  Converters.kgToPound(state.profileParamsForEdit.weight!)
                      .toString(),
                ).toStringAsFixed(2),
        );
      }
    }
  }

  onChangeWeightSymbol(String val, ProfileState state) {
    if (val != state.profileParamsForEdit.weightSymbol) {
      setState(() {
        _bloc.add(ChangingWeightSymbol(val));
        _bloc.add(ChangingHeightSymbol(val == "Kg" ? "Cm" : "Ft"));
      });

      if (val == "Kg") {
        _bloc.add(
          ChangingWeight(
            Converters.poundToKg(state.profileParamsForEdit.weight!).toString(),
          ),
        );
        _bloc.add(
          ChangingHeight(
            Converters.ftToCm(state.profileParamsForEdit.height!).toString(),
          ),
        );
        // double theHeight = Converters.ftToCm(
        //     state.profileParamsForEdit.footHeight +
        //         (state.profileParamsForEdit.inchHeight /
        //             pow(
        //                 10,
        //                 (state.profileParamsForEdit.inchHeight
        //                     .toString()
        //                     .length))));

        _playerHeightController = TextEditingController(
          text: num.parse(
            Converters.ftToCm(state.profileParamsForEdit.height!).toString(),
          ).toStringAsFixed(2),
        );
        _playerWeightController = TextEditingController(
          text: state.profileParamsForEdit.weight! == 0.0
              ? ""
              : num.parse(
                  Converters.poundToKg(state.profileParamsForEdit.weight!)
                      .toString(),
                ).toStringAsFixed(2),
        );
      } else {
        _bloc.add(
          ChangingWeight(
            Converters.kgToPound(state.profileParamsForEdit.weight!).toString(),
          ),
        );
        _bloc.add(
          ChangingHeight(
            Converters.cmToFt(state.profileParamsForEdit.height!).toString(),
          ),
        );

        // _playerFootHeightController = TextEditingController(
        //     text: state.profileParamsForEdit.footHeight == 0.0
        //         ? ""
        //         : state.profileParamsForEdit.footHeight.toString());
        //
        // _playerInchHeightController = TextEditingController(
        //     text: state.profileParamsForEdit.inchHeight == 0.0
        //         ? ""
        //         : state.profileParamsForEdit.inchHeight.toString());

        double theHeight =
            Converters.cmToFt(state.profileParamsForEdit.height!);
        _playerFootHeightController = TextEditingController(
          text: theHeight.toString().split('.').isEmpty
              ? state.profileParamsForEdit.footHeight == 0.0
                  ? ""
                  : ""
              : int.parse(theHeight.toString().split('.').first).toString(),
        );

        _playerInchHeightController = TextEditingController(
          text: theHeight.toString().split('.').length == 2
              ? int.parse(theHeight.toString().split('.')[1])
                          .toString()
                          .length >
                      2
                  ? int.parse(theHeight.toString().split('.')[1])
                      .toString()
                      .substring(0, 2)
                  : int.parse(theHeight.toString().split('.')[1]).toString()
              : state.profileParamsForEdit.inchHeight == 0.0
                  ? ""
                  : "",
        );

        _playerWeightController = TextEditingController(
          text: state.profileParamsForEdit.weight! == 0.0
              ? ""
              : num.parse(
                  Converters.kgToPound(state.profileParamsForEdit.weight!)
                      .toString(),
                ).toStringAsFixed(2),
        );
      }
    }
  }

  Widget phoneNumberWidget(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: const EdgeInsets.only(top: 4.0),
          height: context.h * 0.075,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: AppColors.textFieldColor,
            border: Border.all(color: AppColors.textFieldColor),
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
                    _bloc.add(ChangingPhoneNumber(number));
                  },
                  onInputValidated: (bool value) {
                    _bloc.add(ChangingValidationPhoneNumber(!value));
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                    trailingSpace: false,
                    setSelectorButtonAsPrefixIcon: true,
                  ),
                  ignoreBlank: true,
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      fontSize: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.025
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

  Widget birthOfDate() {
    return GestureDetector(
      onTap: () async {
        final result = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.black,
                colorScheme: const ColorScheme.light(primary: Colors.black),
              ),
              child: child!,
            );
          },
        ).then((value) {});
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4.0),
        height: context.h * 0.075,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: AppColors.textFieldColor,
          border: Border.all(color: AppColors.textFieldColor),
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
                localizations.date_of_birth,
                style: TextStyle(color: AppColors.secondaryFontColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  commentBottomSheet(BuildContext context, double height, double width) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      builder: (BuildContext bc) {
        return SizedBox(
          height: height * 0.3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 12,
                  width: width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: Dimensions.checkKIsWeb(context)
                      ? context.w * 0.03
                      : context.w * 0.06,
                ),
                title: Text(
                  'Pick from the Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.028
                        : 12.sp,
                  ),
                ),
                onTap: () async {
                  ciPicker.pickImage(
                    context: context,
                    source: ImageSource.camera,
                    onMobilePicked: (XFile? file) async {
                      Navigator.pop(context);
                      CroppedFile? cFile = await _cropImage(file!);
                      _accountBloc.onChangeProfilePicture(
                        file: File(
                          cFile != null ? cFile.path : file.path,
                        ),
                      );
                      setState(() {});
                    },
                    onWebPicked: (XFile? file) async {
                      Navigator.pop(context);
                      CroppedFile? cFile = await _cropImage(file!);
                      if (cFile == null) {
                        _accountBloc.onChangeProfilePicture(
                            data: await file.readAsBytes());
                      } else {
                        _accountBloc.onChangeProfilePicture(
                            data: await cFile.readAsBytes());
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: Dimensions.checkKIsWeb(context)
                      ? context.w * 0.03
                      : context.w * 0.06,
                ),
                title: Text(
                  'Pick from the Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.028
                        : 12.sp,
                  ),
                ),
                onTap: () async {
                  ciPicker.pickImage(
                    context: context,
                    source: ImageSource.gallery,
                    onMobilePicked: (XFile? file) async {
                      Navigator.pop(context);
                      CroppedFile? cFile = await _cropImage(file!);
                      _accountBloc.onChangeProfilePicture(
                        file: File(
                          cFile != null ? cFile.path : file.path,
                        ),
                      );
                      setState(() {});
                    },
                    onWebPicked: (XFile? file) async {
                      Navigator.pop(context);
                      CroppedFile? cFile = await _cropImage(file!);
                      if (cFile == null) {
                        _accountBloc.onChangeProfilePicture(
                            data: await file.readAsBytes());
                      } else {
                        _accountBloc.onChangeProfilePicture(
                            data: await cFile.readAsBytes());
                      }
                      setState(() {});
                    },
                  );
                },
              )
            ],
          ),
        );
      },
    );
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
