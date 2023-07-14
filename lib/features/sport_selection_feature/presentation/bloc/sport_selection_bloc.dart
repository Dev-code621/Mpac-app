import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/data/repository/repos/profile_repository.dart';
import 'package:mpac_app/core/data/repository/repos/sports_repository.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_event.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/bloc/sport_selection_state.dart';

@Injectable()
class SportSelectionBloc
    extends Bloc<SportSelectionEvent, SportSelectionState> {
  final SportsRepository sportsRepository;
  final ProfileRepository profileRepository;

  SportSelectionBloc(this.sportsRepository, this.profileRepository)
      : super(SportSelectionState.initial());

  void onChangePageIndex(int index) {
    add(ChangePageIndex(index));
  }

  void onClickOnAddSport(SportModel sportModel, int index) {
    add(ClickOnAddSport(sportModel, index));
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onMaximumSportsFailure() {
    add(MaximumSportsFailure());
  }

  void onAtLeastOneSport() {
    add(AtLeastOneSport());
  }

  void onGetSports() {
    add(GetSports());
  }

  void onCheckVariationsSelection(String profileType) {
    add(CheckVariationsSelection(profileType));
  }

  void onGetProfileSports() {
    add(GetProfileSports());
  }

  void onUpdateSport({
    required SportModel sportModel,
    required String type,
    required int index,
    required String value,
    required int sIndex,
    String? sportPath,
    String? variationId,
  }) {
    add(
      UpdateSport(
        sportModel: sportModel,
        type: type,
        value: value,
        index: index,
        sIndex: sIndex,
        variationId: variationId,
        sportPath: sportPath,
      ),
    );
  }

  void onRemoveVariationInsideSport(
    SportModel sportModel,
    int index,
    String variationId,
  ) {
    add(RemoveVariationInsideSport(sportModel, index, variationId));
  }

  @override
  Stream<SportSelectionState> mapEventToState(
    SportSelectionEvent event,
  ) async* {
    if (event is ChangePageIndex) {
      yield state.rebuild((p0) => p0..currentPageIndex = event.index);
    } else if (event is MaximumSportsFailure) {
      yield state.rebuild((p0) => p0..maximumSportsSelect = true);
    } else if (event is AtLeastOneSport) {
      yield state.rebuild((p0) => p0..selectAtLeastOneSport = true);
    } else if (event is ClickOnAddSport) {
      if (state.selectedSports.contains(event.sportModel)) {
        yield* mapToRemoveSport(event, false);
      } else {
        if (state.selectedSports.length == 3) {
          yield state.rebuild((p0) => p0..maximumSportsSelect = true);
        } else {
          yield* mapToAddSport(event);
        }
      }
    } else if (event is ClearFailures) {
      yield state.rebuild(
        (p0) => p0
          ..missingVariationsSelection = false
          ..noThingIsMissed = false
          ..maximumSportsSelect = false
          ..selectAtLeastOneSport = false
          // ..missedSportsNames = ""
          ..sportsUpdated = false,
      );
    } else if (event is GetSports) {
      yield* mapToGetSports();
      yield* mapToGetProfileSports();
    } else if (event is UpdateSport) {
      yield* mapToUpdateSport(event);
    } else if (event is RemoveVariationInsideSport) {
      yield* mapToRemoveVariationInsideSport(event);
    } else if (event is CheckVariationsSelection) {
      bool isMissedSomeThing = false;
      List<String> paths = [];
      for (int i = 0; i < state.selectedSportFromAPI.length; i++) {
        if (state.selectedSportFromAPI[i].sportPath2.split('/').isNotEmpty) {
          if (!paths.contains(
            state.selectedSportFromAPI[i].sportPath2.split('/').first,
          )) {
            paths
                .add(state.selectedSportFromAPI[i].sportPath2.split('/').first);
          }
        } else {
          if (!paths.contains(
            state.selectedSportFromAPI[i].sportPath2.split('/').first,
          )) {
            paths.add(state.selectedSportFromAPI[i].sportPath2);
          }
        }
      }

      if (event.profileType != "enthusiast") {
        if (paths.length != state.selectedSports.length) {
          List<SportModel> list = state.selectedSports
              .where((element) => !paths.contains(element.id))
              .toList();
          String str = "";
          for (int i = 0; i < list.length; i++) {
            if (!str.trim().contains(list[i].name.trim())) {
              if (i == list.length - 1) {
                str += list[i].name;
              } else {
                str += "${list[i].name}, ";
              }
            }
          }
          yield state.rebuild(
            (p0) => p0
              ..missingVariationsSelection = true
              ..missedSportsNames = str,
          );
        } else {
          yield state.rebuild((p0) => p0..noThingIsMissed = true);
        }
      } else {
        yield* mapToAddSportEnthusiast();
        yield state.rebuild((p0) => p0..noThingIsMissed = true);
      }
    } else if (event is UpdateInformation) {
      yield* mapToUpdateOnBoardingStep();
    }
  }

  Stream<SportSelectionState> checkingMissedSports() async* {
    List<String> paths = [];
    for (int i = 0; i < state.selectedSportFromAPI.length; i++) {
      if (state.selectedSportFromAPI[i].sportPath2.split('/').isNotEmpty) {
        if (!paths.contains(
          state.selectedSportFromAPI[i].sportPath2.split('/').first,
        )) {
          paths.add(state.selectedSportFromAPI[i].sportPath2.split('/').first);
        }
      } else {
        if (!paths.contains(
          state.selectedSportFromAPI[i].sportPath2.split('/').first,
        )) {
          paths.add(state.selectedSportFromAPI[i].sportPath2);
        }
      }
    }
    if (paths.length != state.selectedSports.length) {
      List<SportModel> list = state.selectedSports
          .where((element) => !paths.contains(element.id))
          .toList();
      String str = "";
      for (int i = 0; i < list.length; i++) {
        if (!str.trim().contains(list[i].name.trim())) {
          if (i == list.length - 1) {
            str += list[i].name;
          } else {
            str += "${list[i].name}, ";
          }
        }
      }

      yield state.rebuild((p0) => p0..missedSportsNames = str);
    } else {
      yield state.rebuild((p0) => p0..missedSportsNames = "");
    }
  }

  Stream<SportSelectionState> mapToRemoveSport(
    ClickOnAddSport event,
    bool fromPositionsSelection,
  ) async* {
    List<SelectedSportModel> ids = state.selectedSportFromAPI
        .where((element) => element.sportPath2.startsWith(event.sportModel.id))
        .toList();

    if (ids.isNotEmpty) {
      yield state.rebuild(
        (p0) => p0
          ..sportsModels![event.index].isAddingToServer = true
          ..sportsModels![event.index].errorAddingToServer = false
          ..sportsModels![event.index].addedToServer = false,
      );
      dynamic result;
      for (int i = 0; i < ids.length; i++) {
        result = await sportsRepository.removeSport(ids[i].id);
      }
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..sportsModels![event.index].isAddingToServer = false
            ..sportsModels![event.index].errorAddingToServer = true
            ..sportsModels![event.index].addedToServer = false,
        );
      }, (r) async* {
        if (fromPositionsSelection) {
          yield state.rebuild(
            (p0) => p0
              ..sportsModels![event.index].isAddingToServer = false
              ..sportsModels![event.index].errorAddingToServer = false
              ..sportsModels![event.index].addedToServer = true
              ..selectedSports!
                  .where((element) => element.id == event.sportModel.id)
                  .first
                  .selectedPositions = []
              ..selectedSportFromAPI!.removeWhere(
                (element) => element.sportPath2 == event.sportModel.id,
              )
              ..sportsUpdated = true,
          );
        } else {
          yield state.rebuild(
            (p0) => p0
              ..sportsModels![event.index].isAddingToServer = false
              ..sportsModels![event.index].errorAddingToServer = false
              ..sportsModels![event.index].addedToServer = true
              ..selectedSports!.remove(event.sportModel)
              ..selectedSportFromAPI!.removeWhere(
                (element) => element.sportPath2 == event.sportModel.id,
              )
              ..sportsUpdated = true,
          );
        }
      });
    } else {
      yield state.rebuild((p0) => p0..selectedSports!.remove(event.sportModel));
    }
  }

  Stream<SportSelectionState> mapToRemoveVariationInsideSport(
    RemoveVariationInsideSport event,
  ) async* {
    List<SelectedSportModel> ids = state.selectedSportFromAPI
        .where((element) => element.sportPath2.endsWith(event.variationId))
        .toList();
    yield state.rebuild(
      (p0) => p0
        // ..sportsModels![event.index].isAddingToServer = true
        ..sportsModels![event.index].errorAddingToServer = false
        ..sportsModels![event.index].addedToServer = false,
    );
    final result = await sportsRepository.removeSport(ids.first.id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..sportsModels![event.index].isAddingToServer = false
          ..sportsModels![event.index].errorAddingToServer = true
          ..sportsModels![event.index].addedToServer = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..sportsModels![event.index].isAddingToServer = false
          ..sportsModels![event.index].errorAddingToServer = false
          ..sportsModels![event.index].addedToServer = true
          ..selectedSportFromAPI!.removeWhere(
            (element) => element.sportPath2.endsWith(event.variationId),
          )
          ..sportsUpdated = true,
      );
    });
  }

  Stream<SportSelectionState> mapToAddSport(ClickOnAddSport event) async* {
    // yield state.rebuild((p0) => p0
    //   ..sportsModels![event.index].isAddingToServer = true
    //   ..sportsModels![event.index].errorAddingToServer = false
    //   ..sportsModels![event.index].addedToServer = false);
    // final result = await sportsRepository.addSport(event.sportModel.id);
    // yield* result.fold((l) async* {
    //   yield state.rebuild((p0) => p0
    //     ..sportsModels![event.index].isAddingToServer = false
    //     ..sportsModels![event.index].errorAddingToServer = true
    //     ..sportsModels![event.index].addedToServer = false);
    // }, (r) async* {
    //   yield state.rebuild((p0) => p0
    //     ..sportsModels![event.index].isAddingToServer = false
    //     ..sportsModels![event.index].errorAddingToServer = false
    //     ..sportsModels![event.index].addedToServer = true
    //     ..selectedSports!.add(event.sportModel)
    //     ..selectedSportFromAPI!.add(r)
    //     ..sportsUpdated = true);
    // });
    yield state.rebuild((p0) => p0..selectedSports!.add(event.sportModel));
  }

  Stream<SportSelectionState> mapToAddSportEnthusiast() async* {
    List<String> interestedSports = [];
    for (int i = 0; i < state.selectedSports.length; i++) {
      interestedSports.add(state.selectedSports[i].name);
    }
    final result = await profileRepository.updateUserInformation(
      dataForEdit: {"interested_sports": interestedSports},
    );
    yield* result.fold((l) async* {}, (r) async* {});
  }

  Stream<SportSelectionState> mapToUpdateSport(UpdateSport event) async* {
    yield state.rebuild(
      (p0) => p0
        ..selectedSports![event.sIndex].isAddingToServer = true
        ..selectedSports![event.sIndex].errorAddingToServer = false
        ..selectedSports![event.sIndex].addedToServer = false,
    );
    String id = state.selectedSportFromAPI
            .where(
              (element) => event.type == "variations"
                  ? element.sportPath2 == event.sportPath
                  : element.sportPath2.startsWith(event.sportModel.id),
            )
            .isEmpty
        ? ""
        : state.selectedSportFromAPI
            .where(
              (element) => event.type == "variations"
                  ? element.sportPath2 == event.sportPath
                  : element.sportPath2.startsWith(event.sportModel.id),
            )
            .first
            .id;

    if (event.value.isEmpty) {
      yield* mapToRemoveSport(
        ClickOnAddSport(event.sportModel, event.index),
        true,
      );
    } else {
      if (id.isEmpty) {
        yield state.rebuild(
          (p0) => p0
            ..sportsModels![event.index].isAddingToServer = true
            ..sportsModels![event.index].errorAddingToServer = false
            ..sportsModels![event.index].addedToServer = false,
        );
        final result = await sportsRepository.addSport(
          sportPath: event.sportPath ?? event.sportModel.id,
          value: event.value,
        );
        yield* result.fold((l) async* {
          yield state.rebuild(
            (p0) => p0
              ..sportsModels![event.index].isAddingToServer = false
              ..sportsModels![event.index].errorAddingToServer = true
              ..sportsModels![event.index].addedToServer = false,
          );
        }, (r) async* {
          yield state.rebuild(
            (p0) => p0
              ..sportsModels![event.index].isAddingToServer = false
              ..sportsModels![event.index].errorAddingToServer = false
              ..sportsModels![event.index].addedToServer = true
              ..selectedSportFromAPI!.add(r)
              ..sportsUpdated = true,
          );
        });
        yield* checkingMissedSports();
      } else {
        final result = await sportsRepository.updateSport(
          sportPath: id,
          value: event.value,
        );
        yield* result.fold((l) async* {
          yield state.rebuild(
            (p0) => p0
              ..selectedSports![event.sIndex].isAddingToServer = false
              ..selectedSports![event.sIndex].errorAddingToServer = true
              ..selectedSports![event.sIndex].addedToServer = false,
          );
        }, (r) async* {
          yield state.rebuild(
            (p0) => p0
              ..selectedSports![event.sIndex].isAddingToServer = false
              ..selectedSports![event.sIndex].errorAddingToServer = false
              ..selectedSports![event.sIndex].addedToServer = true
              ..sportsUpdated = true
              ..sportsModels![event.sIndex].selectedPositions =
                  getSelectedPositions(r.value)
              ..selectedSports![event.sIndex].selectedPositions =
                  getSelectedPositions(r.value),
          );
        });
        yield* checkingMissedSports();
        if (event.type == "variations") {
          yield* mapToGetProfileSports();
        }
      }
    }
    // yield state.rebuild((p0) => p0..selectedSports!.add(event.sportModel));
  }

  Stream<SportSelectionState> mapToGetProfileSports() async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingSports = true
        ..errorLoadingSports = false
        ..sportsLoaded = false,
    );

    final result = await sportsRepository.getProfileSports(false);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingSports = false
          ..errorLoadingSports = true
          ..sportsLoaded = false
          ..failure = l,
      );
    }, (r) async* {
      List<SportModel> sSports = [];
      List<SelectedSportModel> selectedSModels = [];
      for (int i = 0; i < r.length; i++) {
        for (int j = 0; j < state.sportsModels.length; j++) {
          if (sSports.isEmpty) {
            if (r[i].sportPath2.startsWith(state.sportsModels[j].id)) {
              state.sportsModels[j].selectedPositions =
                  getSelectedPositions(r[i].value);
              sSports.add(state.sportsModels[j]);
            }
          } else {
            bool hasThisSport = checkIfListContainSportPathForTheSameSport(
              r[i].sportPath2,
              sSports,
            );
            if (r[i].sportPath2.startsWith(state.sportsModels[j].id) &&
                !hasThisSport) {
              state.sportsModels[j].selectedPositions =
                  getSelectedPositions(r[i].value);
              sSports.add(state.sportsModels[j]);
            }
          }
        }
      }

      yield state.rebuild(
        (p0) => p0
          ..selectedSports = sSports
          ..selectedSportFromAPI = r
          ..isLoadingSports = false
          ..errorLoadingSports = false
          ..sportsLoaded = true,
      );
    });
  }

  bool checkIfListContainSportPathForTheSameSport(
    String path,
    List<SportModel> models,
  ) {
    for (int i = 0; i < models.length; i++) {
      if (path.split("/").isNotEmpty) {
        if (models[i].id == path.split("/").first) {
          return true;
        }
      }
    }
    return false;
  }

  Stream<SportSelectionState> mapToGetSports() async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingSports = true
        ..errorLoadingSports = false
        ..sportsLoaded = false,
    );
    final result = await sportsRepository.getSports();
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingSports = false
          ..errorLoadingSports = true
          ..sportsLoaded = false
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingSports = false
          ..errorLoadingSports = false
          ..sportsLoaded = true
          ..sportsModels = r,
      );
    });
  }

  Stream<SportSelectionState> mapToUpdateOnBoardingStep() async* {
    yield state.rebuild(
      (p0) => p0
        ..isUpdatingInformation = true
        ..errorUpdatingInformation = false
        ..informationUpdated = false,
    );
    final result =
        await profileRepository.updateUserInformation(boardingStep: 4);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isUpdatingInformation = false
          ..errorUpdatingInformation = true
          ..informationUpdated = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isUpdatingInformation = false
          ..errorUpdatingInformation = false
          ..informationUpdated = true,
      );
    });
  }

  List<String> getSelectedPositions(String val) {
    List<String> res = [];
    if (val.isEmpty) {
      return [];
    } else {
      if (val.contains(",")) {
        return val.split(',');
      } else {
        return [val];
      }
    }
  }
}
