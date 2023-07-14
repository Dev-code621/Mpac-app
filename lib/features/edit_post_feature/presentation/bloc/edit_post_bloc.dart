import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/core/data/repository/repos/sports_repository.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/bloc/edit_post_event.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/bloc/edit_post_state.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/pages/edit_post_page.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

@Injectable()
class EditPostBloc extends Bloc<EditPostEvent, EditPostState> {
  final PostRepository postRepository;
  final SportsRepository sportsRepository;
  final HomeBloc homeBloc;

  EditPostBloc({
    required this.postRepository,
    required this.sportsRepository,
    required this.homeBloc,
  }) : super(EditPostState.initial());

  void onCropImage(CroppedFile croppedFile, int index, String assetId) {
    add(CropImage(croppedFile: croppedFile, index: index, assetId: assetId));
  }

  @override
  Stream<EditPostState> mapEventToState(EditPostEvent event) async* {
    if (event is InitializeEditPost) {
      List<CustomMediaAsset> assets = [];
      for (int i = 0; i < event.postModel.medias.length; i++) {
        assets.add(
          CustomMediaAsset(mediaModelForOldAsset: event.postModel.medias[i]),
        );
      }
      yield state.rebuild((p0) => p0
        ..allAssets = assets
        ..postSport = event.postModel.sport ?? "general");
      yield* mapToGetSports();
    } else if (event is ChangingPostDescription) {
      yield state.rebuild(
        (p0) => p0
          ..description = event.val
          ..errorValidationDesc = false,
      );
    } else if (event is EditPost) {
      yield* mapToEditPost(event.id);
    } else if (event is ChangingAssetEntities) {
      List<CustomMediaAsset> assets = [];
      for (int i = 0; i < event.assets.length; i++) {
        if (event.assets[i].type == AssetType.video) {
          File? file = await event.assets[i].file;
          VideoPlayerController videoPlayerController =
              VideoPlayerController.file(file!)..initialize().then((v) {});
          CustomMediaAsset c = CustomMediaAsset(
            assetId: event.assets[i].id,
            assetEntity: event.assets[i],
            videoPlayerController: videoPlayerController,
          );
          if (!checkAssetsHasThisId(event.assets[i].id)) {
            assets.add(c);
          }
        } else {
          CustomMediaAsset c = CustomMediaAsset(
            assetId: event.assets[i].id,
            assetEntity: event.assets[i],
            file: await event.assets[i].file,
          );
          if (!checkAssetsHasThisId(event.assets[i].id)) {
            assets.add(c);
          }
        }
      }
      yield state.rebuild(
        (p0) => p0
          ..newAssets = event.assets
          ..allAssets!.addAll(assets),
      );
    } else if (event is ChangingAssetEntitiesWeb) {
      yield state.rebuild(
        (p0) => p0..loadingAssets = true,
      );
      List<CustomMediaAsset> assets = [];
      for (int i = 0; i < event.list.length; i++) {
        CustomMediaAsset c = CustomMediaAsset(
          webUrl: event.list[i].path,
        );
        assets.add(c);
        yield state.rebuild(
          (p0) => p0
            ..newAssetsWeb!.add(event.list[i])
            ..loadingAssets = false
            ..allAssets!.add(c),
        );
      }
    } else if (event is DeleteOldMedia) {
      yield state.rebuild(
        (p0) => p0
          ..mediasIdsForDelete!.add(event.mediaId)
          ..allAssets!.remove(event.customMediaAsset),
      );
    } else if (event is DeleteNewMedia) {
      yield state.rebuild(
        (p0) => p0..allAssets!.remove(event.customMediaAsset),
      );
    } else if (event is CropImage) {
      yield state.rebuild(
        (p0) => p0
          ..croppedFilesMap![event.assetId.toString()] = {
            'file': event.croppedFile,
            'index': event.index,
            'assetId': event.assetId
          },
      );
    } else if (event is ChangingPostSport) {
      yield state.rebuild((p0) => p0..postSport = event.val);
    }
  }

  bool checkAssetsHasThisId(String id) {
    for (int i = 0; i < state.allAssets.length; i++) {
      if (state.allAssets[i].assetId == id) {
        return true;
      }
    }
    return false;
  }

  Stream<EditPostState> mapToGetSports() async* {
    yield state.rebuild((p0) => p0
      ..isLoadingSports = false
      ..errorLoadingSports = false
      ..sportsLoaded = false);
    final result = await sportsRepository.getProfileSports(true);
    yield* result.fold((l) async* {}, (r) async* {
      // String selectedFilter = (getIt<PrefsHelper>().getSelectedFilter == null ||
      //         getIt<PrefsHelper>().getSelectedFilter.isEmpty)
      //     ? "general"
      //     : getIt<PrefsHelper>().getSelectedFilter;
      yield state.rebuild(
        (p0) => p0
          ..userSports = r
          // ..postSport = selectedFilter
          ..isLoadingSports = false
          ..errorLoadingSports = false
          ..sportsLoaded = true,
      );
    });
  }

  Stream<EditPostState> mapToEditPost(String id) async* {
    if (state.description.trim().isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationDesc = true);
    } else {
      yield state.rebuild(
        (p0) => p0
          ..isUpdatingPost = true
          ..errorUpdatingPost = false
          ..postUpdated = false,
      );
      final result = await postRepository.editPost(
        sport: state.postSport,
        description: state.description,
        newAssets: state.newAssets,
        croppedFiles: state.croppedFilesMap,
        deletedMediaIds: state.mediasIdsForDelete,
        postId: id,
        homeBloc: homeBloc,
        newWebAssets: state.newAssetsWeb,
      );
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..failure = l
            ..isUpdatingPost = false
            ..errorUpdatingPost = true
            ..postUpdated = false,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..updatedPost = r
            ..isUpdatingPost = false
            ..errorUpdatingPost = false
            ..postUpdated = true,
        );
      });
    }
  }
}
