import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/classes/profile_params.dart';

part 'create_profile_state.g.dart';

abstract class CreateProfileState
    implements Built<CreateProfileState, CreateProfileStateBuilder> {
  CreateProfileState._();

  factory CreateProfileState([Function(CreateProfileStateBuilder b) updates]) =
      _$CreateProfileState;

  int get currentPageIndex;

  ProfileParams get profileParams;

  bool get errorValidationUsername;

  bool get errorValidationGender;

  bool get errorValidationFirstName;

  bool get errorValidationLastName;

  bool get errorValidationDateOfBirth;

  bool get errorValidationPhoneNumber;

  bool get errorValidationOriginCountry;

  bool get errorValidationOriginState;

  bool get errorValidationOriginCity;

  bool get errorValidationOriginAddress;

  bool get errorValidationProfileImage;

  bool get errorValidationHeight;

  bool get errorValidationHeightSymbol;

  bool get errorValidationWeight;

  bool get errorValidationWeightSymbol;
  bool get errorValidationCurrentCountry;
  bool get errorValidationCurrentCity;
  bool get errorValidationCurrentState;
  bool get errorValidationCurrentAddress;

  bool get isUpdatingInformation;
  bool get errorUpdatingInformation;
  bool get informationUpdated;

  Failure? get failure;

  List<CountryModel> get countries;
  bool get isLoadingCountries;
  bool get errorLoadingCountries;
  bool get countriesLoaded;

  StateModel? get loadedStateModelForStep1;
  StateModel? get loadedStateModelForStep2;
  bool get isLoadingState;
  bool get errorLoadingState;
  bool get stateLoaded;

  bool get isLoadingCurrentUser;
  bool get errorLoadingCurrentUser;
  bool get currentUserLoaded;
  UserModel? get currentUser;

  factory CreateProfileState.initial() {
    return CreateProfileState((b) => b
      ..currentPageIndex = 0
      ..profileParams = ProfileParams(
          type: "player",
          gender: "male",
        heightSymbol: "Cm",
        weightSymbol: "Kg",
      )
      ..countries = []
      ..stateLoaded = false
      ..isLoadingCurrentUser = false
      ..errorLoadingCurrentUser = false
      ..currentUserLoaded = false
      ..errorLoadingState = false
      ..isLoadingState = false
      ..countriesLoaded = false
      ..errorLoadingCountries = false
      ..isLoadingCountries = false
      ..errorValidationUsername = false
      ..errorValidationProfileImage = false
      ..errorValidationGender = false
      ..errorValidationFirstName = false
      ..errorValidationLastName = false
      ..errorValidationDateOfBirth = false
      ..errorValidationPhoneNumber = false
      ..errorValidationOriginCountry = false
      ..errorValidationOriginState = false
      ..errorValidationOriginCity = false
      ..errorValidationOriginAddress = false
      ..errorValidationHeight = false
      ..errorValidationHeightSymbol = false
      ..errorValidationWeight = false
      ..errorValidationWeightSymbol = false
      ..errorValidationCurrentCountry = false
      ..errorValidationCurrentCity = false
      ..errorValidationCurrentState = false
      ..errorValidationCurrentAddress = false
      ..isUpdatingInformation = false
      ..errorUpdatingInformation = false
      ..informationUpdated = false,);
  }
}
