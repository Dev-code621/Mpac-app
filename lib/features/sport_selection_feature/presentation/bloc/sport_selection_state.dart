import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/error/failures.dart';
part 'sport_selection_state.g.dart';

abstract class SportSelectionState
    implements Built<SportSelectionState, SportSelectionStateBuilder> {
  SportSelectionState._();

  factory SportSelectionState(
      [Function(SportSelectionStateBuilder b) updates,]) = _$SportSelectionState;

  int get currentPageIndex;

  List<SportModel> get selectedSports;

  bool get maximumSportsSelect;
  bool get selectAtLeastOneSport;

  List<SportModel> get sportsModels;
  bool get isLoadingSports;
  bool get errorLoadingSports;
  bool get sportsLoaded;

  Failure? get failure;

  List<SelectedSportModel> get selectedSportFromAPI;
  bool get isUpdatingSports;
  bool get errorUpdatingSports;
  bool get sportsUpdated;

  bool get missingVariationsSelection;
  String get missedSportsNames;
  bool get noThingIsMissed;

  bool get isUpdatingInformation;
  bool get errorUpdatingInformation;
  bool get informationUpdated;

  factory SportSelectionState.initial() {
    return SportSelectionState((b) => b
      ..sportsModels = []
      ..missedSportsNames = ""
      ..selectedSportFromAPI = []
      ..sportsUpdated = false
      ..missingVariationsSelection = false
      ..noThingIsMissed = false
      ..errorUpdatingSports = false
      ..isUpdatingSports = false
      ..isLoadingSports = false
      ..errorLoadingSports = false
      ..sportsLoaded = false
      ..maximumSportsSelect = false
      ..selectAtLeastOneSport = false
      ..isUpdatingInformation = false
      ..errorUpdatingInformation = false
      ..informationUpdated = false
      ..currentPageIndex = 0
      ..selectedSports = [],);
  }
}
