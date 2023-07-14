import 'dart:io';
import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';

abstract class CreateProfileEvent {}

class GetCurrentUser extends CreateProfileEvent {}

class ChangingFirebaseToken extends CreateProfileEvent {
  final String token;

  ChangingFirebaseToken(this.token);
}

class ChangePageIndex extends CreateProfileEvent {
  final int index;

  ChangePageIndex(this.index);
}

class ChangingGender extends CreateProfileEvent {
  final String val;

  ChangingGender(this.val);
}

class ChangingUsername extends CreateProfileEvent {
  final String val;

  ChangingUsername(this.val);
}

class ChangingFirstName extends CreateProfileEvent {
  final String firstName;

  ChangingFirstName(this.firstName);
}

class ChangingLastName extends CreateProfileEvent {
  final String firstName;

  ChangingLastName(this.firstName);
}

class ChangingBio extends CreateProfileEvent {
  final String bio;

  ChangingBio(this.bio);
}

class ChangingDateOfBirth extends CreateProfileEvent {
  final DateTime date;

  ChangingDateOfBirth(this.date);
}

class ChangingPhoneNumber extends CreateProfileEvent {
  final PhoneNumber phoneNumber;

  ChangingPhoneNumber(this.phoneNumber);
}

class ChangingCodePhoneNumber extends CreateProfileEvent {
  final int code;

  ChangingCodePhoneNumber(this.code);
}

class ChangingOriginCountry extends CreateProfileEvent {
  final CountryModel val;

  ChangingOriginCountry(this.val);
}

class ChangingOriginState extends CreateProfileEvent {
  final State val;

  ChangingOriginState(this.val);
}

class ChangingOriginCity extends CreateProfileEvent {
  final String val;

  ChangingOriginCity(this.val);
}

class ChangingOriginAddress extends CreateProfileEvent {
  final String val;

  ChangingOriginAddress(this.val);
}

class ChangingPhoneValidation extends CreateProfileEvent {
  final bool val;

  ChangingPhoneValidation(this.val);
}

//

class ChangingProfileImage extends CreateProfileEvent {
  final File? file;
  final CroppedFile? croppedFile;
  final Uint8List? uint8list;
  final XFile? xfile;

  ChangingProfileImage({this.file, this.uint8list, this.croppedFile, this.xfile});
}


class ChangingFootHeight extends CreateProfileEvent {
  final String val;

  ChangingFootHeight(this.val);
}


class ChangingInchHeight extends CreateProfileEvent {
  final String val;

  ChangingInchHeight(this.val);
}

class ChangingHeight extends CreateProfileEvent {
  final String val;

  ChangingHeight(this.val);
}

class ChangingHeightSymbol extends CreateProfileEvent {
  final String val;

  ChangingHeightSymbol(this.val);
}

class ChangingWeightSymbol extends CreateProfileEvent {
  final String val;

  ChangingWeightSymbol(this.val);
}

class ChangingWeight extends CreateProfileEvent {
  final String val;

  ChangingWeight(this.val);
}

class ChangingCurrentCountry extends CreateProfileEvent {
  final CountryModel val;

  ChangingCurrentCountry(this.val);
}

class ChangingCurrentState extends CreateProfileEvent {
  final State val;

  ChangingCurrentState(this.val);
}

class ChangingCurrentCity extends CreateProfileEvent {
  final String val;

  ChangingCurrentCity(this.val);
}

class ChangingCurrentAddress extends CreateProfileEvent {
  final String val;

  ChangingCurrentAddress(this.val);
}

class HitUpdateButton extends CreateProfileEvent {
  final int currentIndex;

  HitUpdateButton(this.currentIndex);
}

class ClearFailures extends CreateProfileEvent {}

class UpdateType extends CreateProfileEvent {
  final String type;

  UpdateType(this.type);
}

class LoadStates extends CreateProfileEvent {
  final String name;
  final bool fromStep2;

  LoadStates(this.name, this.fromStep2);
}

class LoadCountries extends CreateProfileEvent {}
