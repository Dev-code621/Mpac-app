import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/countries_repository.dart';
import 'package:mpac_app/core/data/repository/repos/profile_repository.dart';
import 'package:mpac_app/core/utils/constants/converters.dart';
import 'package:mpac_app/core/utils/validator/input_validators.dart';

import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_event.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_state.dart';

@Injectable()
class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final InputValidators inputValidators;
  final ProfileRepository profileRepository;
  final CountriesRepository countriesRepository;

  CreateProfileBloc(
      this.profileRepository, this.countriesRepository, this.inputValidators,)
      : super(CreateProfileState.initial());

  void onChangePageIndex(int index) {
    add(ChangePageIndex(index));
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onUpdateType(String type) {
    add(UpdateType(type));
  }

  void onLoadCountries() {
    add(LoadCountries());
  }

  void onLoadStates(String name, bool fromStep2) {
    add(LoadStates(name, fromStep2));
  }

  void onGetCurrentUser() {
    add(GetCurrentUser());
  }

  @override
  Stream<CreateProfileState> mapEventToState(CreateProfileEvent event) async* {
    if (event is ChangePageIndex) {
      yield state.rebuild((p0) => p0..currentPageIndex = event.index);
    } else if (event is ChangingFirebaseToken) {
      yield state
          .rebuild((p0) => p0..profileParams!.firebaseToken = event.token);
    } else if (event is ChangingUsername) {
      yield state.rebuild((p0) => p0
        ..profileParams!.username = event.val
        ..errorValidationUsername = false,);
    } else if (event is ChangingFirstName) {
      yield state.rebuild((p0) => p0
        ..profileParams!.firstName = event.firstName
        ..errorValidationFirstName = false,);
    } else if (event is ChangingGender) {
      yield state.rebuild((p0) => p0
        ..profileParams!.gender = event.val
        ..errorValidationGender = false,);
    } else if (event is ChangingLastName) {
      yield state.rebuild((p0) => p0
        ..profileParams!.lastName = event.firstName
        ..errorValidationLastName = false,);
    } else if (event is ChangingBio) {
      yield state.rebuild((p0) => p0
        ..profileParams!.bio = event.bio);
    } else if (event is ChangingDateOfBirth) {
      yield state.rebuild((p0) => p0
        ..profileParams!.dob = event.date
        ..errorValidationDateOfBirth = false,);
    } else if (event is ChangingPhoneNumber) {
      yield state.rebuild((p0) => p0
        ..profileParams!.mobileNumber = event.phoneNumber.phoneNumber == null
            ? 0
            : num.tryParse(event.phoneNumber.parseNumber()) == null? 0 
            :num.parse(event.phoneNumber.parseNumber()) .toInt()
        ..profileParams!.codePhoneNumber = event.phoneNumber.dialCode == null
            ? 0
            : int.parse(event.phoneNumber.dialCode!.replaceAll('+', ''))
        ..errorValidationPhoneNumber = false,);
    } else if (event is ChangingCodePhoneNumber) {
      yield state.rebuild((p0) => p0
        ..profileParams!.codePhoneNumber = event.code
        ..errorValidationPhoneNumber = false,);
    } else if(event is ChangingPhoneValidation){
      yield state.rebuild((p0) => p0
        ..errorValidationPhoneNumber = event.val,);
    }else if (event is ChangingOriginCountry) {
      yield state.rebuild((p0) => p0
        ..profileParams!.originState = null
        ..profileParams!.originCity = null
        ..profileParams!.originCountry = event.val
        ..errorValidationOriginCountry = false,);
    } else if (event is ChangingOriginState) {
      yield state.rebuild((p0) => p0
        ..profileParams!.originCity = null
        ..profileParams!.originState = event.val
        ..errorValidationOriginState = false,);
    } else if (event is ChangingOriginCity) {
      yield state.rebuild((p0) => p0
        ..profileParams!.originCity = event.val
        ..errorValidationOriginCity = false,);
    } else if (event is ChangingOriginAddress) {
      yield state.rebuild((p0) => p0
        ..profileParams!.originAddress = event.val
        ..errorValidationOriginAddress = false,);
    }
    //
    else if (event is ChangingProfileImage) {
      if (event.croppedFile != null) {
        yield state.rebuild((p0) => p0
          ..profileParams!.croppedProfileImage = event.croppedFile
          ..profileParams!.profileImageWeb = null
          ..profileParams!.profileImage = null,);
      } else if (event.file == null) {
        yield state.rebuild((p0) => p0
          ..profileParams!.profileImageWeb = event.uint8list
          ..profileParams!.xFile = event.xfile
          ..profileParams!.profileImage = null
          ..profileParams!.croppedProfileImage = null,);
      } else {
        yield state.rebuild((p0) => p0
          ..profileParams!.profileImage = event.file
          ..profileParams!.croppedProfileImage = null
          ..profileParams!.profileImageWeb = null,);
      }
    } else if (event is ChangingHeight) {
      double theHeight = event.val.isEmpty
          ? 0
          : Converters.cmToFt(double.tryParse(event.val)!);
      if (inputValidators.validateStringIsNumber(event.val)) {
        yield state.rebuild((p0) => p0
          ..profileParams!.footHeight = theHeight.toString().split('.').isEmpty
              ? theHeight.toInt()
              : int.tryParse(theHeight.toString().split('.').first)!
          ..profileParams!.inchHeight =
              theHeight.toString().split('.').length == 2
                  ? int.tryParse(theHeight.toString().split('.')[1])!
                  : 0
          ..profileParams!.height = num.tryParse(event.val)!
          ..errorValidationHeight = false,);
      }
    } else if (event is ChangingFootHeight) {
      yield state.rebuild((p0) => p0
        ..profileParams!.footHeight =
            event.val.isEmpty ? 0 : int.tryParse(event.val)!
        ..errorValidationHeight = false,);
    } else if (event is ChangingInchHeight) {
      yield state.rebuild((p0) => p0
        ..profileParams!.inchHeight =
            event.val.isEmpty ? 0 : int.tryParse(event.val)!
        ..errorValidationHeight = false,);
    } else if (event is ChangingHeightSymbol) {
      yield state.rebuild((p0) => p0
        ..profileParams!.height = event.val == "Cm"
            ? Converters.ftToCm(state.profileParams.footHeight +
                (state.profileParams.inchHeight /
                    pow(10,
                        (state.profileParams.footHeight.toString().length),)),)
            : Converters.cmToFt(state.profileParams.height!)
        ..profileParams!.heightSymbol = event.val
        ..errorValidationHeightSymbol = false,);
    } else if (event is ChangingWeight) {
      if (inputValidators.validateStringIsNumber(event.val)) {
        yield state.rebuild((p0) => p0
          ..profileParams!.weight = num.tryParse(event.val)!
          ..errorValidationWeight = false,);
      }
    } else if (event is ChangingWeightSymbol) {
      yield state.rebuild((p0) => p0
        ..profileParams!.weight = event.val == "Kg"
            ? Converters.poundToKg(state.profileParams.weight!)
            : Converters.kgToPound(state.profileParams.weight!)
        ..profileParams!.weightSymbol = event.val
        ..errorValidationWeightSymbol = false,);
    } else if (event is ChangingCurrentCountry) {
      yield state.rebuild((p0) => p0
        ..profileParams!.currentState = null
        ..profileParams!.currentCity = null
        ..profileParams!.currentCountry = event.val
        ..errorValidationCurrentCountry = false,);
    } else if (event is ChangingCurrentState) {
      yield state.rebuild((p0) => p0
        ..profileParams!.originCity = null
        ..profileParams!.currentState = event.val
        ..errorValidationCurrentState = false,);
    } else if (event is ChangingCurrentCity) {
      yield state.rebuild((p0) => p0
        ..profileParams!.currentCity = event.val
        ..errorValidationCurrentCity = false,);
    } else if (event is ChangingCurrentAddress) {
      yield state.rebuild((p0) => p0
        ..profileParams!.currentAddress = event.val
        ..errorValidationCurrentAddress = false,);
    } else if (event is HitUpdateButton) {
      if (event.currentIndex == 0) {
        yield* mapToUpdateProfileInformationStep1();
      } else {
        yield* mapToUpdateProfileInformationStep2();
      }
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0
        ..failure = null
        ..currentUserLoaded = false
        ..informationUpdated = false,);
    } else if (event is UpdateType) {
      yield* updateInformation(type: event.type);
    } else if (event is LoadCountries) {
      yield* mapToLoadCountries();
    } else if (event is LoadStates) {
      yield* mapToLoadStates(event.name, event.fromStep2);
    } else if (event is GetCurrentUser) {
      yield* mapToGetCurrentUser();
    }
  }

  Stream<CreateProfileState> mapToGetCurrentUser() async* {
    yield state.rebuild((p0) => p0
      ..isLoadingCurrentUser = true
      ..errorLoadingCurrentUser = false
      ..currentUserLoaded = false,);
    final result = await profileRepository.getCurrentUser();
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isLoadingCurrentUser = false
        ..errorLoadingCurrentUser = true
        ..currentUserLoaded = false,);
    }, (r) async* {
      CountryModel? currentCountry;
      CountryModel? originCountry;
      for (int i = 0; i < state.countries.length; i++) {
        if (state.countries[i].name == r.currentCountry) {
          currentCountry = state.countries[i];
        }
        if (state.countries[i].name == r.originCountry) {
          originCountry = state.countries[i];
        }
      }

      yield state.rebuild((p0) => p0
        ..isLoadingCurrentUser = false
        ..errorLoadingCurrentUser = false
        ..currentUserLoaded = true
        ..currentUser = r
        ..profileParams!.gender = r.gender == null ? "male" : r.gender!
        ..profileParams!.username = r.username == null ? "" : r.username!
        ..profileParams!.firstName = r.firstName == null ? "" : r.firstName!
        ..profileParams!.lastName = r.lastName == null ? "" : r.lastName!
        ..profileParams!.dob = r.dob == null
            ? null
            : DateTime(
                int.tryParse(r.dob!.substring(0, 4))!,
                int.tryParse(r.dob!.substring(5, 7))!,
                int.tryParse(r.dob!.substring(8, 10))!,
              )
        ..profileParams!.mobileNumber =
            r.mobileNumber == null ? 0 : num.parse(r.mobileNumber!).toInt()
        ..profileParams!.currentAddress =
            r.currentAddress == null ? "" : r.currentAddress!
        ..profileParams!.originAddress =
            r.originAddress == null ? "" : r.originAddress!
        ..profileParams!.height = r.height == null ? 0 : r.height!
        ..profileParams!.weight = r.weight == null ? 0 : r.weight!
        ..profileParams!.currentCountry = currentCountry
        ..profileParams!.originCountry = originCountry,);
    });
  }

  Stream<CreateProfileState> mapToLoadCountries() async* {
    yield state.rebuild((p0) => p0
      ..isLoadingCountries = true
      ..errorLoadingCountries = false
      ..countriesLoaded = false,);
    final result = await countriesRepository.getCountries();
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..isLoadingCountries = false
        ..errorLoadingCountries = true
        ..countriesLoaded = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..loadedStateModelForStep1 = null
        ..loadedStateModelForStep2 = null
        ..profileParams!.originState = null
        ..profileParams!.originCity = null
        ..countries = r
        ..isLoadingCountries = false
        ..errorLoadingCountries = false
        ..countriesLoaded = true,);
    });
  }

  Stream<CreateProfileState> mapToLoadStates(
      String countryName, bool fromStep2,) async* {
    yield state.rebuild((p0) => p0
      ..profileParams!.originCity = null
      ..isLoadingState = true
      ..errorLoadingState = false
      ..stateLoaded = false,);
    final result = await countriesRepository.getState(countryName: countryName);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..isLoadingState = false
        ..errorLoadingState = true
        ..stateLoaded = false,);
    }, (r) async* {
      if (fromStep2) {
        yield state.rebuild((p0) => p0
          ..profileParams!.originCity = null
          ..loadedStateModelForStep2 = r
          ..isLoadingState = false
          ..errorLoadingState = true
          ..stateLoaded = false,);
      } else {
        yield state.rebuild((p0) => p0
          ..profileParams!.originCity = null
          ..loadedStateModelForStep1 = r
          ..isLoadingState = false
          ..errorLoadingState = true
          ..stateLoaded = false,);
      }
    });
  }

  Stream<CreateProfileState> mapToUpdateProfileInformationStep1() async* {
    if (state.profileParams.gender.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationGender = true);
    } else if (state.profileParams.username.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationUsername = true);
    } else if (state.profileParams.firstName.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationFirstName = true);
    } else if (state.profileParams.lastName.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationLastName = true);
    } else if (state.profileParams.dob == null) {
      yield state.rebuild((p0) => p0..errorValidationDateOfBirth = true);
    } else if (state.profileParams.mobileNumber ==
            0 /* ||
        !inputValidators.validatePhoneNumberInput(
            state.profileParams.mobileNumber.toString())*/
        ) {
      yield state.rebuild((p0) => p0..errorValidationPhoneNumber = true);
    } else if (state.profileParams.originCountry == null) {
      yield state.rebuild((p0) => p0..errorValidationOriginCountry = true);
    }
    /*else if (state.profileParams.originState == null) {
      yield state.rebuild((p0) => p0..errorValidationOriginState = true);
    } else if (state.profileParams.originCity == null) {
      yield state.rebuild((p0) => p0..errorValidationOriginCity = true);
    }*/
    else if (state.profileParams.originAddress.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationOriginAddress = true);
    } else {
      yield* updateInformation();
    }
  }

  Stream<CreateProfileState> mapToUpdateProfileInformationStep2() async* {
    if ((state.profileParams.height == 0 ||
            state.profileParams.height.toString().isEmpty) &&
        ((state.profileParams.inchHeight == 0 ||
                state.profileParams.inchHeight.toString().isEmpty) ||
            (state.profileParams.footHeight == 0 ||
                state.profileParams.footHeight.toString().isEmpty))) {
      yield state.rebuild((p0) => p0..errorValidationHeight = true);
    } else if (state.profileParams.heightSymbol.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationHeightSymbol = true);
    } else if (state.profileParams.weight == 0) {
      yield state.rebuild((p0) => p0..errorValidationWeight = true);
    } else if (state.profileParams.weightSymbol.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationWeightSymbol = true);
    } else if (state.profileParams.currentCountry == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentCountry = true);
    }
    /*else if (state.profileParams.currentState == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentState = true);
    } else if (state.profileParams.currentCity == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentCity = true);
    }*/
    else if (state.profileParams.currentAddress.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationCurrentAddress = true);
    } else {
      yield* updateInformation();
    }
  }

  Stream<CreateProfileState> updateInformation({String? type}) async* {
    yield state.rebuild((p0) => p0
      ..profileParams!.onBoardingStep = state.currentPageIndex == 1 ? 3 : 2
      ..isUpdatingInformation = true
      ..errorUpdatingInformation = false
      ..informationUpdated = false,);
    final result = await profileRepository.updateUserInformation(
        params: state.profileParams, profileType: type,);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isUpdatingInformation = false
        ..errorUpdatingInformation = true
        ..informationUpdated = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..isUpdatingInformation = false
        ..errorUpdatingInformation = false
        ..informationUpdated = true,);
    });
  }
}
