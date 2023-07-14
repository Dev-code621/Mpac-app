import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mpac_app/core/data/repository/repos/account_repository.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_event.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_state.dart';

import 'package:universal_io/io.dart' as uio;

@Injectable()
class MyAccountBloc extends Bloc<MyAccountEvent, MyAccountState> {
  final AccountRepository accountRepository;

  MyAccountBloc(this.accountRepository) : super(MyAccountState.initial());

  void onChangeProfilePicture({File? file, Uint8List? data}) {
    add(ChangeProfilePicture(file: file, data: data));
  }

  @override
  Stream<MyAccountState> mapEventToState(MyAccountEvent event) async* {
    if (event is ChangeProfilePicture) {
      yield* mapToChangeProfilePicture(event);
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0
        ..failure = null
        ..errorUploadingPicture = false
        ..pictureUploaded = false,);
    }
  }

  Stream<MyAccountState> mapToChangeProfilePicture(
      ChangeProfilePicture event,) async* {
    yield state.rebuild((p0) => p0
      ..isUploadingPicture = true
      ..errorUploadingPicture = false
      ..pictureUploaded = false,);
    final result = await accountRepository.updateProfilePicture(
        file: event.file == null ? null : uio.File(event.file!.path),
        imageData: event.data,);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isUploadingPicture = false
        ..errorUploadingPicture = true
        ..pictureUploaded = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..isUploadingPicture = false
        ..errorUploadingPicture = false
        ..pictureUploaded = true,);
    });
  }
}
