import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/error/failures.dart';

part 'my_account_state.g.dart';

abstract class MyAccountState
    implements Built<MyAccountState, MyAccountStateBuilder> {
  MyAccountState._();

  factory MyAccountState([Function(MyAccountStateBuilder b) updates]) =
      _$MyAccountState;

  bool get isUploadingPicture;

  bool get errorUploadingPicture;

  bool get pictureUploaded;

  Failure? get failure;

  factory MyAccountState.initial() {
    return MyAccountState((b) => b
      ..isUploadingPicture = false
      ..errorUploadingPicture = false
      ..pictureUploaded = false,);
  }
}
