import 'package:built_value/built_value.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/pages/edit_post_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'edit_post_state.g.dart';

abstract class EditPostState
    implements Built<EditPostState, EditPostStateBuilder> {
  EditPostState._();

  factory EditPostState([Function(EditPostStateBuilder b) updates]) =
      _$EditPostState;

  bool get isLoadingSports;

  bool get errorLoadingSports;

  bool get sportsLoaded;

  List<SelectedSportModel> get userSports;

  bool get isUpdatingPost;

  bool get loadingAssets;

  bool get errorUpdatingPost;

  bool get postUpdated;

  bool get errorValidationDesc;

  Failure? get failure;

  String get description;

  String get postSport;

  List<AssetEntity> get newAssets;

  List<XFile> get newAssetsWeb;

  List<CustomMediaAsset> get allAssets;

  Map<String, dynamic> get croppedFilesMap;

  List<String> get mediasIdsForDelete;

  PostModel? get updatedPost;

  factory EditPostState.initial() {
    return EditPostState(
      (b) => b
        ..isLoadingSports = false
        ..errorLoadingSports = false
        ..loadingAssets = false
        ..sportsLoaded = false
        ..postSport = "general"
        ..userSports = []
        ..newAssets = []
        ..newAssetsWeb = []
        ..allAssets = []
        ..mediasIdsForDelete = []
        ..croppedFilesMap = {}
        ..description = ""
        ..isUpdatingPost = false
        ..errorValidationDesc = false
        ..errorUpdatingPost = false
        ..postUpdated = false,
    );
  }
}
