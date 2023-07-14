import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/repos/auth_repository.dart';
import 'package:mpac_app/core/data/repository/repos/profile_repository.dart';
import 'package:mpac_app/core/data/repository/repos/settings_repository.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/bloc/splash_event.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/bloc/splash_state.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable()
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final SettingsRepository settingsRepository;

  SplashBloc(
      this.authRepository, this.profileRepository, this.settingsRepository)
      : super(SplashState.initial());

  void onCheckJWT() {
    add(CheckJWT());
  }

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is CheckJWT) {
      final token = getIt<PrefsHelper>().getUserToken;


      if (token.isEmpty) {
        yield state.rebuild((p0) => p0..notLoggedIn = true);
      } else {

        await getIt<AuthRepository>().getSendBirdAppId();
        await getIt<AuthRepository>().getSendbirdToken(token: token);

        yield* mapToGetSettings();
        yield* mapToGenerateSendbirdToken(token);
        yield* mapToGetNotificationsCount();
        yield* mapToCheckingJWT();
      }
    } else if (event is GetSettings) {
      yield* mapToGetSettings();
    }
  }

  Stream<SplashState> mapToGetSettings() async* {
    yield state.rebuild(
      (p0) => p0
        ..isCheckingJWT = true
        ..errorCheckingJWT = false
        ..jwtChecked = false,
    );
    final result = await settingsRepository.settings();
    yield* result.fold((l) async* {}, (r) async* {});
  }

  Stream<SplashState> mapToGetNotificationsCount() async* {
    final result = await profileRepository.getCurrentUser();
    yield* result.fold((l) async* {}, (r) async* {
      notificationsCount =
          r.notificationsCount == null ? 0 : r.notificationsCount!;
    });
  }

  Stream<SplashState> mapToGenerateSendbirdToken(String token) async* {
    int diff = getDateDiff();
    String? sendbirdToken = getIt<SharedPreferences>()
        .getString(SharedPreferencesKeys.sendbirdToken);
    // if (sendbirdToken == null || diff <= 1) {
    //   await authRepository.getSendbirdToken(token: token);
    // }
  }

  Stream<SplashState> mapToCheckingJWT() async* {
    yield state.rebuild(
      (p0) => p0
        ..isCheckingJWT = true
        ..errorCheckingJWT = false
        ..jwtChecked = false,
    );
    final result = await authRepository.checkJwt();
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isCheckingJWT = false
          ..errorCheckingJWT = true
          ..jwtChecked = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isCheckingJWT = false
          ..errorCheckingJWT = false
          ..jwtChecked = true
          ..currentSignedInUser = r,
      );
    });
  }

  int getDateDiff() {
    int? timestamp = getIt<SharedPreferences>()
        .getInt(SharedPreferencesKeys.sendbirdTokenExpires);
    if (timestamp != null) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final difference = date.difference(DateTime.now()).inDays;
      return difference;
    } else {
      return 0;
    }
  }
}
