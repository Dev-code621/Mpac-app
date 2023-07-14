import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/media_model.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/presentation/controllers/pagination_controller.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/classes/profile_params.dart';

import 'package:mpac_app/core/data/models/state_model.dart';

part 'profile_state.g.dart';

abstract class ProfileState
    implements Built<ProfileState, ProfileStateBuilder> {
  ProfileState._();

  factory ProfileState([Function(ProfileStateBuilder b) updates]) =
      _$ProfileState;

  int get currentPageIndex;

  bool get isLoadingProfile;

  bool get errorLoadingProfile;

  bool get profileLoaded;

  UserModel? get profileModelLoaded;

  Failure? get failure;

  bool get isLoadingUserPosts;

  bool get errorLoadingUserPosts;

  bool get userPostsLoaded;

  List<PostModel> get userPosts;

  bool get isLoadingFollowings;

  bool get errorLoadingFollowings;

  bool get followingsLoaded;

  List<UserModel> get followers;

  List<UserModel> get followings;

  ProfileParams get profileParamsForEdit;

  bool get isEditingProfile;

  bool get errorEditingProfile;

  bool get profileEdited;

  bool get errorValidationFirstName;

  bool get errorValidationLastName;

  bool get errorValidationPhoneNumber;

  bool get errorValidationCurrentCountry;

  bool get errorValidationCurrentState;

  bool get errorValidationCurrentCity;

  bool get errorValidationOriginAddress;

  List<CountryModel> get countries;

  bool get isLoadingCountries;

  bool get errorLoadingCountries;

  bool get countriesLoaded;

  StateModel? get loadedStateModel;

  bool get isLoadingState;

  bool get errorLoadingState;

  bool get stateLoaded;

  bool get isLoadingSpecificPost;

  bool get errorLoadingSpecificPost;

  bool get specificPostLoaded;

  PostModel? get specificPostModel;

  bool get isFollowingUser;
  bool get errorFollowingUser;
  bool get userFollowed;

  bool get thumbnailLoaded;

  String get currentSelectedFilterSportType;

  List<MediaModel> get imagesMedias;
  List<MediaModel> get videosMedias;

  bool get isLoadingImagesMedias;
  bool get errorLoadingImagesMedias;
  bool get imagesMediasLoaded;

  bool get isLoadingVideosMedias;
  bool get errorLoadingVideosMedias;
  bool get videosMediasLoaded;

  PaginationController get paginationControllerAll;
  PaginationController get paginationControllerImages;
  PaginationController get paginationControllerVideos;

  bool get canLoadMoreVideos;
  bool get canLoadMoreImages;
  bool get canLoadMoreAll;

  factory ProfileState.initial() {
    return ProfileState((b) => b
      ..paginationControllerAll = PaginationController()
      ..paginationControllerVideos = PaginationController()
      ..paginationControllerImages = PaginationController()
      ..currentSelectedFilterSportType = "general"
      ..imagesMedias = []
      ..videosMedias = []
      ..isLoadingImagesMedias = false
      ..canLoadMoreAll = false
      ..canLoadMoreImages = false
      ..canLoadMoreVideos = false
      ..errorLoadingImagesMedias = false
      ..imagesMediasLoaded = false
      ..isLoadingVideosMedias = false
      ..errorLoadingVideosMedias = false
      ..videosMediasLoaded = false
      ..thumbnailLoaded = false
      ..userFollowed = false
      ..errorFollowingUser = false
      ..isFollowingUser = false
      ..isLoadingSpecificPost = false
      ..errorLoadingSpecificPost = false
      ..specificPostLoaded = false
      ..profileParamsForEdit = ProfileParams(
          weightSymbol: "Kg", heightSymbol: "Cm", onBoardingStep: 4,)
      ..countries = []
      ..errorValidationLastName = false
      ..errorValidationPhoneNumber = false
      ..errorValidationCurrentCountry = false
      ..errorValidationCurrentState = false
      ..errorValidationCurrentCity = false
      ..errorValidationOriginAddress = false
      ..errorValidationFirstName = false
      ..stateLoaded = false
      ..errorLoadingState = false
      ..isLoadingState = false
      ..countriesLoaded = false
      ..errorLoadingCountries = false
      ..isLoadingCountries = false
      ..isLoadingFollowings = false
      ..isEditingProfile = false
      ..errorEditingProfile = false
      ..profileEdited = false
      ..errorLoadingFollowings = false
      ..followingsLoaded = false
      ..followers = []
      ..followings = []
      ..isLoadingUserPosts = false
      ..errorLoadingUserPosts = false
      ..userPostsLoaded = false
      ..userPosts = []
      ..currentPageIndex = 0
      ..isLoadingProfile = false
      ..errorLoadingProfile = false
      ..profileLoaded = false,);
  }
}
