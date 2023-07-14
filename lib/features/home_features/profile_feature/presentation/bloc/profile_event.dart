import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';

abstract class ProfileEvent {}

class GetProfileInformation extends ProfileEvent {
  final String id;

  GetProfileInformation(this.id);
}

class GetSpecificPost extends ProfileEvent {
  final String id;

  GetSpecificPost(this.id);
}

class DeletePost extends ProfileEvent {
  final String id;
  final String userId;

  DeletePost(this.id, this.userId);
}

class GetUserPosts extends ProfileEvent {
  final String id;

  GetUserPosts(this.id);
}

class ClearFailures extends ProfileEvent {}

class GetFollowings extends ProfileEvent {
  final String id;
  final String type;

  GetFollowings(this.id, this.type);
}

class InitializeEditProfile extends ProfileEvent {}

class UpdateProfileInformation extends ProfileEvent {}

class GetCountries extends ProfileEvent {}

class FollowUser extends ProfileEvent {}

class UnFollowUser extends ProfileEvent {}

class GetStates extends ProfileEvent {
  final String? country;

  GetStates(this.country);
}

class ChangingCurrentCountry extends ProfileEvent {
  final CountryModel countryModel;

  ChangingCurrentCountry(this.countryModel);
}

class ChangingFirstName extends ProfileEvent {
  final String val;

  ChangingFirstName(this.val);
}

class ChangingLastName extends ProfileEvent {
  final String val;

  ChangingLastName(this.val);
}

class ChangingBio extends ProfileEvent {
  final String val;

  ChangingBio(this.val);
}

class ChangingCurrentState extends ProfileEvent {
  final State val;

  ChangingCurrentState(this.val);
}

class ChangingPhoneNumber extends ProfileEvent {
  final PhoneNumber phoneNumber;

  ChangingPhoneNumber(this.phoneNumber);
}

class ChangingValidationPhoneNumber extends ProfileEvent {
  final bool val;

  ChangingValidationPhoneNumber(this.val);
}

class ChangingHeight extends ProfileEvent {
  final String val;

  ChangingHeight(this.val);
}

class ChangingFootHeight extends ProfileEvent {
  final String val;

  ChangingFootHeight(this.val);
}

class ChangingInchHeight extends ProfileEvent {
  final String val;

  ChangingInchHeight(this.val);
}

class ChangingWeight extends ProfileEvent {
  final String val;

  ChangingWeight(this.val);
}

class ChangingHeightSymbol extends ProfileEvent {
  final String symbol;

  ChangingHeightSymbol(this.symbol);
}

class ChangingWeightSymbol extends ProfileEvent {
  final String symbol;

  ChangingWeightSymbol(this.symbol);
}

class ChangingCurrentAddress extends ProfileEvent {
  final String val;

  ChangingCurrentAddress(this.val);
}

class GetImagesMedias extends ProfileEvent {
  final String userId;

  GetImagesMedias(this.userId);
}

class GetVideoMedias extends ProfileEvent {
  final String userId;

  GetVideoMedias(this.userId);
}

class GetMoreVideoMedias extends ProfileEvent {
  final String userId;

  GetMoreVideoMedias(this.userId);
}

class GetMoreImagesMedias extends ProfileEvent {
  final String userId;

  GetMoreImagesMedias(this.userId);
}

class ChangeFilterSportType extends ProfileEvent {
  final String val;
  final String userId;

  ChangeFilterSportType(this.val, this.userId);
}
