import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart' as stateModel;
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/repos/countries_repository.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/core/data/repository/repos/user_repository.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/converters.dart';
import 'package:mpac_app/core/utils/validator/input_validators.dart';

import 'package:mpac_app/core/data/repository/repos/profile_repository.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_event.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_state.dart';

@Injectable()
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final ProfileRepository profileRepository;
  final CountriesRepository countriesRepository;
  final InputValidators inputValidators;
  final PostRepository postRepository;

  ProfileBloc(
    this.userRepository,
    this.profileRepository,
    this.inputValidators,
    this.postRepository,
    this.countriesRepository,
  ) : super(ProfileState.initial());

  void onGetProfileInformation(String id) {
    add(GetProfileInformation(id));
  }

  void onGetSpecificPost(String id) {
    add(GetSpecificPost(id));
  }

  void onDeletePost(String id, String userId) {
    add(DeletePost(id, userId));
  }

  void onGetProfilePosts(String id) {
    add(GetUserPosts(id));
  }

  void onGetFollowings(String userId, String type) {
    add(GetFollowings(userId, type));
  }

  void onInitializeEditProfile() {
    add(InitializeEditProfile());
  }

  void onGetCountries() {
    add(GetCountries());
  }

  void onUnFollowUser() {
    add(UnFollowUser());
  }

  void onFollowUser() {
    add(FollowUser());
  }

  void onGetStates(String? country) {
    add(GetStates(country));
  }

  void onClearFailure() {
    add(ClearFailures());
  }

  void onChangeFilterSportType(String val, String userId) {
    add(ChangeFilterSportType(val, userId));
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is GetProfileInformation) {
      yield* mapToGetProfileInformation(event.id);
    } else if (event is GetUserPosts) {
      yield* mapToGetUserPosts(event.id);
    } else if (event is GetFollowings) {
      yield* mapToGetFollowings(event);
    } else if (event is InitializeEditProfile) {
      UserModel user = getIt<PrefsHelper>().userInfo();
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.firstName = user.firstName!
          ..profileParamsForEdit!.lastName = user.lastName!
          ..profileParamsForEdit!.mobileNumber =
              num.parse(user.mobileNumber!).toInt()
          ..profileParamsForEdit!.footHeight = user.height == null
              ? 0
              : Converters.cmToFt(user.height!).toString().split('.').isEmpty
                  ? Converters.cmToFt(user.height!).toInt()
                  : int.tryParse(
                      Converters.cmToFt(user.height!)
                          .toString()
                          .split('.')
                          .first,
                    )!
          ..profileParamsForEdit!.inchHeight = user.height == null
              ? 0
              : Converters.cmToFt(user.height!).toString().split('.').length ==
                      2
                  ? int.tryParse(
                      Converters.cmToFt(user.height!).toString().split('.')[1],
                    )!
                  : 0
          ..profileParamsForEdit!.height = user.measureSystem == "metric"
              ? user.height
              : Converters.cmToFt(user.height!)
          ..profileParamsForEdit!.weight = user.measureSystem == "metric"
              ? user.weight
              : Converters.kgToPound(user.weight!)
          ..profileParamsForEdit!.heightSymbol =
              user.measureSystem == "metric" ? "Cm" : "Ft"
          ..profileParamsForEdit!.weightSymbol =
              user.measureSystem == "metric" ? "Kg" : "Pound"
          ..profileParamsForEdit!.currentAddress = user.currentAddress!,
      );
    } else if (event is UpdateProfileInformation) {
      yield* mapToUpdateInformation();
    } else if (event is GetCountries) {
      yield* mapToLoadCountries(true);
    } else if (event is GetStates) {
      if (event.country != null) {
        yield* mapToLoadStates(event.country!);
      }
    } else if (event is ChangingCurrentCountry) {
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.currentCountry = event.countryModel
          ..profileParamsForEdit!.currentState = null
          ..loadedStateModel = null,
      );
      yield* mapToLoadStates(event.countryModel.name);
    } else if (event is ChangingFirstName) {
      yield state
          .rebuild((p0) => p0..profileParamsForEdit!.firstName = event.val);
    } else if (event is ChangingLastName) {
      yield state
          .rebuild((p0) => p0..profileParamsForEdit!.lastName = event.val);
    } else if (event is ChangingBio) {
      yield state.rebuild((p0) => p0..profileParamsForEdit!.bio = event.val);
    } else if (event is ChangingPhoneNumber) {
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.codePhoneNumber =
              int.parse(event.phoneNumber.dialCode!.replaceAll('+', ''))
          ..profileParamsForEdit!.mobileNumber =
              num.tryParse(event.phoneNumber.parseNumber()) == null
                  ? 0
                  : num.parse(event.phoneNumber.parseNumber()).toInt(),
      ); // save
    } else if (event is ChangingHeight) {
      // double theHeight = event.val.isEmpty
      //     ? 0
      //     : Converters.cmToFt(double.parse(event.val));

      double theHeight = double.parse(event.val);
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.footHeight =
              theHeight.toString().split('.').isEmpty
                  ? theHeight.toInt()
                  : int.parse(theHeight.toString().split('.').first)
          ..profileParamsForEdit!.inchHeight =
              theHeight.toString().split('.').length == 2
                  ? int.parse(theHeight.toString().split('.')[1])
                  : 0
          ..profileParamsForEdit!.height = double.parse(event.val),
      );
    } else if (event is ChangingWeight) {
      yield state.rebuild(
        (p0) => p0..profileParamsForEdit!.weight = num.tryParse(event.val),
      );
    } else if (event is ChangingFootHeight) {
      double theHeight = (event.val.isEmpty ? 0 : int.tryParse(event.val)!) +
          (state.profileParamsForEdit.inchHeight /
              pow(
                10,
                (state.profileParamsForEdit.inchHeight.toString().length),
              ));
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.height = theHeight
          ..profileParamsForEdit!.footHeight =
              event.val.isEmpty ? 0 : int.tryParse(event.val)!,
      );
    } else if (event is ChangingInchHeight) {
      double theHeight = state.profileParamsForEdit.footHeight +
          ((event.val.isEmpty ? 0 : int.tryParse(event.val)!) /
              pow(
                10,
                ((event.val.isEmpty ? 1 : int.tryParse(event.val)!)
                    .toString()
                    .length),
              ));
      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.height = theHeight
          ..profileParamsForEdit!.inchHeight =
              event.val.isEmpty ? 0 : int.tryParse(event.val)!,
      );
    } else if (event is ChangingHeightSymbol) {
      yield state.rebuild(
        (p0) => p0..profileParamsForEdit!.heightSymbol = event.symbol,
      );
    } else if (event is ChangingWeightSymbol) {
      yield state.rebuild(
        (p0) => p0..profileParamsForEdit!.weightSymbol = event.symbol,
      );
    } else if (event is ChangingCurrentAddress) {
      yield state.rebuild(
        (p0) => p0..profileParamsForEdit!.currentAddress = event.val,
      );
    } else if (event is ChangingCurrentState) {
      yield state
          .rebuild((p0) => p0..profileParamsForEdit!.currentState = event.val);
    } else if (event is ClearFailures) {
      yield state.rebuild(
        (p0) => p0
          ..thumbnailLoaded = false
          ..profileEdited = false
          ..failure = null,
      );
    } else if (event is GetSpecificPost) {
      yield* mapToGetSpecificPost(event.id);
    } else if (event is FollowUser) {
      yield* mapToFollowUser();
    } else if (event is UnFollowUser) {
      yield* mapToUnFollowUser();
    } else if (event is DeletePost) {
      yield* mapToDeletePost(event.id, event.userId);
    } else if (event is ChangingValidationPhoneNumber) {
      yield state.rebuild((p0) => p0..errorValidationPhoneNumber = event.val);
    } else if (event is GetVideoMedias) {
      yield* mapToGetVideoMedias(event);
    } else if (event is GetMoreVideoMedias) {
      yield* mapToGetMoreVideoMedias(event);
    } else if (event is GetImagesMedias) {
      yield* mapToGetImageMedias(event);
    } else if (event is GetMoreImagesMedias) {
      yield* mapToGetMoreImageMedias(event);
    } else if (event is ChangeFilterSportType) {
      getIt<PrefsHelper>().savePostFilter(event.val);
      yield state
          .rebuild((p0) => p0..currentSelectedFilterSportType = event.val);
      yield* mapToGetUserPosts(event.userId);
      yield* mapToGetVideoMedias(GetVideoMedias(event.userId));
      yield* mapToGetImageMedias(GetImagesMedias(event.userId));
    }
  }

  Stream<ProfileState> mapToGetVideoMedias(GetVideoMedias event) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingVideosMedias = true
        ..errorLoadingVideosMedias = false
        ..videosMediasLoaded = false,
    );
    final result = await profileRepository.getMedias(
      type: "video",
      sport: state.currentSelectedFilterSportType,
      userId: event.userId,
    );

    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isLoadingVideosMedias = false
          ..errorLoadingVideosMedias = true
          ..videosMediasLoaded = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..paginationControllerVideos!.offset = 0
          ..canLoadMoreVideos = r.length > 14
          ..isLoadingVideosMedias = false
          ..errorLoadingVideosMedias = false
          ..videosMediasLoaded = true
          ..videosMedias = r,
      );
    });
  }

  Stream<ProfileState> mapToGetMoreVideoMedias(
    GetMoreVideoMedias event,
  ) async* {
    if (state.canLoadMoreVideos && state.videosMedias.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingVideosMedias = true
          ..errorLoadingVideosMedias = false
          ..videosMediasLoaded = false,
      );
      final result = await profileRepository.getMedias(
        type: "video",
        userId: event.userId,
        sport: state.currentSelectedFilterSportType,
        offset: state.paginationControllerVideos.offset + 15,
        limit: state.paginationControllerVideos.limit,
      );

      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..failure = l
            ..isLoadingVideosMedias = false
            ..errorLoadingVideosMedias = true
            ..videosMediasLoaded = false,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..canLoadMoreImages =
                r.length > state.paginationControllerVideos.limit - 1
            ..paginationControllerImages!.offset =
                state.paginationControllerVideos.offset + 15
            ..isLoadingVideosMedias = false
            ..errorLoadingVideosMedias = false
            ..videosMediasLoaded = true
            ..videosMedias = r,
        );
      });
    }
  }

  Stream<ProfileState> mapToGetImageMedias(GetImagesMedias event) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingImagesMedias = true
        ..errorLoadingImagesMedias = false
        ..imagesMediasLoaded = false,
    );
    final result = await profileRepository.getMedias(
      type: "image",
      sport: state.currentSelectedFilterSportType,
      userId: event.userId,
    );

    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isLoadingImagesMedias = false
          ..errorLoadingImagesMedias = true
          ..imagesMediasLoaded = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..paginationControllerImages!.offset = 0
          ..canLoadMoreImages = r.length > 14
          ..isLoadingImagesMedias = false
          ..errorLoadingImagesMedias = false
          ..imagesMediasLoaded = true
          ..imagesMedias = r,
      );
    });
  }

  Stream<ProfileState> mapToGetMoreImageMedias(
    GetMoreImagesMedias event,
  ) async* {
    if (state.canLoadMoreAll && state.imagesMedias.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingImagesMedias = true
          ..errorLoadingImagesMedias = false
          ..imagesMediasLoaded = false,
      );
      final result = await profileRepository.getMedias(
        type: "image",
        userId: event.userId,
        sport: state.currentSelectedFilterSportType,
        offset: state.paginationControllerImages.offset + 15,
        limit: state.paginationControllerImages.limit,
      );

      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..failure = l
            ..isLoadingImagesMedias = false
            ..errorLoadingImagesMedias = true
            ..imagesMediasLoaded = false,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..canLoadMoreImages =
                r.length > state.paginationControllerImages.limit - 1
            ..paginationControllerImages!.offset =
                state.paginationControllerImages.offset + 15
            ..isLoadingImagesMedias = false
            ..errorLoadingImagesMedias = false
            ..imagesMediasLoaded = true
            ..imagesMedias = r,
        );
      });
    }
  }

  Stream<ProfileState> mapToDeletePost(String id, String userId) async* {
    final result = await postRepository.deletePost(id);
    yield* mapToGetUserPosts(userId);
    yield* mapToGetVideoMedias(GetVideoMedias(userId));
    yield* mapToGetImageMedias(GetImagesMedias(userId));
  }

  Stream<ProfileState> mapToFollowUser() async* {
    yield state.rebuild(
      (p0) => p0
        ..isFollowingUser = true
        ..errorFollowingUser = false
        ..userFollowed = false,
    );
    final result = await userRepository.follow(state.profileModelLoaded!.id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isFollowingUser = false
          ..errorFollowingUser = true
          ..userFollowed = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..profileModelLoaded!.isFollowed = true
          ..isFollowingUser = false
          ..errorFollowingUser = false
          ..userFollowed = true,
      );
    });
    yield* mapToGetProfileInformation(state.profileModelLoaded!.id);
  }

  Stream<ProfileState> mapToUnFollowUser() async* {
    yield state.rebuild(
      (p0) => p0
        ..isFollowingUser = true
        ..errorFollowingUser = false
        ..userFollowed = false,
    );
    final result = await userRepository.unfollow(state.profileModelLoaded!.id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isFollowingUser = false
          ..errorFollowingUser = true
          ..userFollowed = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..profileModelLoaded!.isFollowed = false
          ..isFollowingUser = false
          ..errorFollowingUser = false
          ..userFollowed = true,
      );
    });
    yield* mapToGetProfileInformation(state.profileModelLoaded!.id);
  }

  Stream<ProfileState> mapToGetSpecificPost(String id) async* {
    yield state.rebuild((p0) => p0..isLoadingSpecificPost = true);
    final result = await postRepository.getSpecificPost(id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingSpecificPost = false
          ..errorLoadingSpecificPost = true
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..specificPostModel = r
          ..specificPostLoaded = true
          ..isLoadingSpecificPost = false
          ..errorLoadingSpecificPost = false,
      );
    });
  }

  Stream<ProfileState> mapToLoadCountries(bool withReassign) async* {
    CountryModel? country;

    yield state.rebuild(
      (p0) => p0
        ..isLoadingCountries = true
        ..errorLoadingCountries = false
        ..countriesLoaded = false,
    );
    final result = await countriesRepository.getCountries();
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingCountries = false
          ..errorLoadingCountries = true
          ..countriesLoaded = false,
      );
    }, (r) async* {
      // final cc = state.profileParamsForEdit.currentCountry == null
      //     ? state.profileParamsForEdit.currentCountry!.name
      //     : getIt<PrefsHelper>().userInfo().currentCountry;
      for (int i = 0; i < r.length; i++) {
        if (r[i].name == getIt<PrefsHelper>().userInfo().currentCountry) {
          country = r[i];
        }
      }

      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.currentCountry = country
          ..loadedStateModel = null
          ..profileParamsForEdit!.currentState = null
          ..profileParamsForEdit!.currentCity = null
          ..countries = r
          ..isLoadingCountries = false
          ..errorLoadingCountries = false
          ..countriesLoaded = true,
      );
    });
    if (country != null) {
      yield* mapToLoadStates(country!.name);
    }
  }

  Stream<ProfileState> mapToLoadStates(String countryName) async* {
    yield state.rebuild(
      (p0) => p0
        ..profileParamsForEdit!.currentCity = null
        ..isLoadingState = true
        ..errorLoadingState = false
        ..stateLoaded = false,
    );
    final result = await countriesRepository.getState(countryName: countryName);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingState = false
          ..errorLoadingState = true
          ..stateLoaded = false,
      );
    }, (r) async* {
      stateModel.State? stateModelV;
      final user = getIt<PrefsHelper>().userInfo();
      for (int i = 0; i < r.states.length; i++) {
        if (r.states[i].name == user.currentState) {
          stateModelV = r.states[i];
        }
      }

      yield state.rebuild(
        (p0) => p0
          ..profileParamsForEdit!.currentState = stateModelV
          ..profileParamsForEdit!.currentCity = null
          ..loadedStateModel = r
          ..isLoadingState = false
          ..errorLoadingState = true
          ..stateLoaded = false,
      );
    });
  }

  Stream<ProfileState> mapToUpdateInformation() async* {
    if (state.profileParamsForEdit.firstName.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationFirstName = true);
    } else if (state.profileParamsForEdit.lastName.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationLastName = true);
    } else if (state.profileParamsForEdit.mobileNumber ==
            0 /* ||
        !inputValidators.validatePhoneNumberInput(
            state.profileParamsForEdit.mobileNumber.replaceAll(' ', ''))*/
        ) {
      yield state.rebuild((p0) => p0..errorValidationPhoneNumber = true);
    } else if (state.profileParamsForEdit.currentCountry == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentCountry = true);
    }
    /*else if (state.profileParamsForEdit.currentState == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentState = true);
    } else if (state.profileParamsForEdit.currentCity == null) {
      yield state.rebuild((p0) => p0..errorValidationCurrentCity = true);
    } */
    else if (state.profileParamsForEdit.currentAddress.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationOriginAddress = true);
    } else {
      yield* updateInformation();
    }
  }

  Stream<ProfileState> updateInformation() async* {
    yield state.rebuild(
      (p0) => p0
        ..isEditingProfile = true
        ..errorEditingProfile = false
        ..profileEdited = false,
    );

    final result = await profileRepository.updateUserInformation(
      dataForEdit: {
        'first_name': state.profileParamsForEdit.firstName,
        'last_name': state.profileParamsForEdit.lastName,
        'mobile_number': state.profileParamsForEdit.mobileNumber,
        'mobile_country_code': state.profileParamsForEdit.codePhoneNumber,
        "bio": state.profileParamsForEdit.bio,
        // 'height': state.profileParamsForEdit.height,
        // 'weight': state.profileParamsForEdit.weight,
        "height": state.profileParamsForEdit.height == 0
            ? null
            : state.profileParamsForEdit.heightSymbol == "Cm"
                ? state.profileParamsForEdit.height
                : Converters.ftToCm(state.profileParamsForEdit.height!),
        "weight": state.profileParamsForEdit.weight == 0
            ? null
            : state.profileParamsForEdit.weightSymbol == "Kg"
                ? state.profileParamsForEdit.weight
                : Converters.poundToKg(state.profileParamsForEdit.weight!),
        'current_country': state.profileParamsForEdit.currentCountry!.name,
        'current_state': state.profileParamsForEdit.currentState == null
            ? ""
            : state.profileParamsForEdit.currentState!.name,
        'current_address': state.profileParamsForEdit.currentAddress,
        "measure_system": state.profileParamsForEdit.weightSymbol == "Kg"
            ? "metric"
            : "imperial"
      },
    );
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isEditingProfile = false
          ..errorEditingProfile = false
          ..profileEdited = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isEditingProfile = false
          ..errorEditingProfile = false
          ..profileEdited = true,
      );
    });
  }

  Stream<ProfileState> mapToGetFollowings(GetFollowings event) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingFollowings = true
        ..errorLoadingFollowings = false
        ..followingsLoaded = false,
    );
    dynamic result;
    if (event.type == "followers") {
      result = await userRepository.getFollowers(event.id);
    } else {
      result = await userRepository.getFollowings(event.id);
    }
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingFollowings = false
          ..errorLoadingFollowings = true
          ..followingsLoaded = false,
      );
    }, (r) async* {
      if (event.type == "followers") {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingFollowings = false
            ..errorLoadingFollowings = false
            ..followingsLoaded = true
            ..followers = r,
        );
      } else {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingFollowings = false
            ..errorLoadingFollowings = false
            ..followingsLoaded = true
            ..followings = r,
        );
      }
    });
  }

  Stream<ProfileState> mapToGetProfileInformation(String id) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingProfile = true
        ..errorLoadingProfile = false
        ..profileLoaded = false,
    );
    final result = await userRepository.getUser(id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingProfile = false
          ..errorLoadingProfile = true
          ..profileLoaded = false
          ..failure = l,
      );
    }, (r) async* {
      String selectedFilter = (getIt<PrefsHelper>().getSelectedFilter.isEmpty)
          ? "general"
          : getIt<PrefsHelper>().getSelectedFilter;
      yield state.rebuild(
        (p0) => p0
          ..currentSelectedFilterSportType = selectedFilter
          ..isLoadingProfile = false
          ..errorLoadingProfile = false
          ..profileLoaded = true
          ..profileModelLoaded = r,
      );
    });
  }

  Stream<ProfileState> mapToGetUserPosts(String id) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingUserPosts = true
        ..errorLoadingUserPosts = false
        ..userPostsLoaded = false,
    );
    final result = await userRepository.getPosts(
      id,
      sport: state.currentSelectedFilterSportType,
    );
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingUserPosts = false
          ..errorLoadingUserPosts = true
          ..userPostsLoaded = false
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..paginationControllerAll!.offset = 0
          ..canLoadMoreAll = r.length > 14
          ..isLoadingUserPosts = false
          ..errorLoadingUserPosts = false
          ..userPostsLoaded = true
          ..userPosts = r,
      );
    });
  }

  Stream<ProfileState> mapToGetMoreUserPosts(String id) async* {
    if (state.canLoadMoreAll && state.userPosts.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingUserPosts = true
          ..errorLoadingUserPosts = false
          ..userPostsLoaded = false,
      );
      final result = await userRepository.getPosts(
        id,
        sport: state.currentSelectedFilterSportType,
      );
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingUserPosts = false
            ..errorLoadingUserPosts = true
            ..userPostsLoaded = false
            ..failure = l,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..paginationControllerAll!.offset = 0
            ..canLoadMoreAll = r.length > 14
            ..isLoadingUserPosts = false
            ..errorLoadingUserPosts = false
            ..userPostsLoaded = true
            ..userPosts = r,
        );
      });
    }
  }
}
