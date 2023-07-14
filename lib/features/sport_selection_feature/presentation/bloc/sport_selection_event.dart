import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';

abstract class SportSelectionEvent {}

class ChangePageIndex extends SportSelectionEvent {
  final int index;

  ChangePageIndex(this.index);
}

class UpdateInformation extends SportSelectionEvent {}

class ClickOnAddSport extends SportSelectionEvent {
  final SportModel sportModel;
  final int index;

  ClickOnAddSport(this.sportModel, this.index);
}

class RemoveVariationInsideSport extends SportSelectionEvent {
  final SportModel sportModel;
  final int index;
  final String variationId;

  RemoveVariationInsideSport(this.sportModel, this.index, this.variationId);
}

class UpdateSport extends SportSelectionEvent {
  final SportModel sportModel;
  final String type; // variations or positions
  final String value;
  final int index;
  final int sIndex;
  final String? sportPath;
  final String? variationId;

  UpdateSport({
    required this.sportModel,
    required this.type,
    required this.index,
    required this.variationId,
    required this.sIndex,
    required this.value,
    this.sportPath,
  });
}

class ClearFailures extends SportSelectionEvent {}

class MaximumSportsFailure extends SportSelectionEvent {}

class AtLeastOneSport extends SportSelectionEvent {}

class GetSports extends SportSelectionEvent {}

class CheckVariationsSelection extends SportSelectionEvent {
  final String profileType;

  CheckVariationsSelection(this.profileType);
}

class GetProfileSports extends SportSelectionEvent {}
