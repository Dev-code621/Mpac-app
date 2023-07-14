import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

abstract class AuthRepository extends BaseRepository {
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> getSendBirdAppId();

  Future<Either<Failure, UserModel>> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> checkJwt();

  Future<Either<Failure, UserModel>> continueWithGoogleAccount({
    required String googleToken,
  });

  Future<Either<Failure, UserModel>> continueWithAppleAccount();

  Future<Either<Failure, bool>> checkCode({required String code});

  Future<Either<Failure, String>> getSendbirdToken({required String token});

  Future<Either<Failure, bool>> resendOTPCode();
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends BaseRepositoryImpl implements AuthRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  AuthRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, bool>> getSendBirdAppId() async {
    try {
      final result = await dio.get(
        EndPoints.sendBirdId,
      );

      if (result.data != "") {
        sendbirdAppId = result.data;

        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await dio.post(
        EndPoints.signIn,
        data: jsonEncode({'email': email, 'password': password}),
      );

      if (result.data != "" && json.decode(result.data) != null) {
        //  await getSendbirdToken(token: json.decode(result.data)['token']);
        final userResponse = UserModel.fromJson(json.decode(result.data));
        await prefsHelper.saveUserInfo(userResponse);
        notificationsCount = int.tryParse(
          json.decode(result.data)['user']['notifications_count'].toString(),
        )!;

        await _updateUserDeviceType();

        return Right(userResponse);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final result = await dio.post(
        EndPoints.signUp,
        data: jsonEncode(
          {'username': username, 'email': email, 'password': password},
        ),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        //  await getSendbirdToken(token: json.decode(result.data)['token']);
        final userResponse = UserModel.fromJson(json.decode(result.data));
        await prefsHelper.saveUserInfo(userResponse);

        await _updateUserDeviceType();

        return Right(userResponse);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkJwt() async {
    try {
      final result = await dio.post(
        EndPoints.jwtCheck,
        options: GetOptions.getOptionsWithToken(prefsHelper.getUserToken),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        final UserModel user = UserModel.fromJson(
          json.decode(result.data),
          token: prefsHelper.getUserToken,
        );

        await _updateUserDeviceType();

        return Right(user);
      } else {
        getIt<SharedPreferences>().clear();
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      getIt<SharedPreferences>().clear();
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  Future<Either<Failure, bool>> _updateUserDeviceType() async {
    try {
      late final String deviceType;

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        deviceType = "ios";
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        deviceType = "android";
      } else {
        deviceType = "web";
      }

      final result = await dio.put(
        EndPoints.profile,
        data: jsonEncode({'device_type': deviceType}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );

      if (result.data != "" && json.decode(result.data) != null) {
        await prefsHelper
            .saveUserInfo(UserModel.fromJson(json.decode(result.data)));
        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> continueWithGoogleAccount({
    required String googleToken,
  }) async {
    try {
      final result = await dio.post(
        EndPoints.firebaseSignIn,
        data: jsonEncode({'token': googleToken}),
        options: GetOptions.getOptionsWithToken(prefsHelper.getUserToken),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        final userResponse = UserModel.fromJson(json.decode(result.data));
        await prefsHelper.saveUserInfo(userResponse);
        return Right(userResponse);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: "Server error!",
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> continueWithAppleAccount() async {
    try {
      final FirebaseAuthenticationService authService =
          FirebaseAuthenticationService();

      final authResult = await authService.signInWithApple(
        appleClientId: '',
        appleRedirectUri: 'https://mpac-sports.firebaseapp.com/__/auth/handler',
      );

      if (authResult.hasError) {
        return Left(
          ServerFailure(
            ErrorCodes.unAuth,
            errorMessage: authResult.errorMessage,
          ),
        );
      }

      final String? appleToken = await authResult.user?.getIdToken();

      final result = await dio.post(
        EndPoints.firebaseSignIn,
        data: jsonEncode({'token': appleToken}),
        options: GetOptions.getOptionsWithToken(prefsHelper.getUserToken),
      );

      if (result.data != "" && json.decode(result.data) != null) {
        final userResponse = UserModel.fromJson(json.decode(result.data));
        await prefsHelper.saveUserInfo(userResponse);
        return Right(userResponse);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: "Server error!",
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, String>> getSendbirdToken({String? token}) async {
    try {
      final result = await dio.post(
        EndPoints.generateSendbirdToken,
        options: GetOptions.getOptionsWithToken(
          token ?? prefsHelper.getUserToken,
        ),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        getIt<SharedPreferences>().setString(
          SharedPreferencesKeys.sendbirdToken,
          json.decode(result.data)['token'],
        );
        getIt<SharedPreferences>().setInt(
          SharedPreferencesKeys.sendbirdTokenExpires,
          json.decode(result.data)['expires_at'],
        );
        sendbirdToken = json.decode(result.data)['token'];

        return Right(json.decode(result.data)['token']);
      } else {
        // getIt<SharedPreferences>().clear();
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      // getIt<SharedPreferences>().clear();
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> checkCode({required String code}) async {
    try {
      final result = await dio.post(
        EndPoints.profileVerifyEmail,
        data: jsonEncode({'code': code}),
        options: GetOptions.getOptionsWithToken(prefsHelper.getUserToken),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        final userResponse = UserModel.fromJson(
          json.decode(result.data),
          token: prefsHelper.getUserToken,
        );
        await prefsHelper.saveUserInfo(userResponse);
        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> resendOTPCode() async {
    try {
      final result = await dio.post(
        EndPoints.resendOTPCode,
        options: GetOptions.getOptionsWithToken(prefsHelper.getUserToken),
      );
      if (json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              ErrorCodes.serverError,
              errorMessage: "Server error!",
            ),
          );
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(
            ServerFailure(
              ErrorCodes.noConnection,
              errorMessage: "No internet connection!",
            ),
          );
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(
              ServerFailure(
                ErrorCodes.serverError,
                errorMessage: json.decode(e.response?.data)['message'],
              ),
            );
          } else {
            return Left(ServerFailure(ErrorCodes.unKnownError));
          }
        }
      } else {
        return e is ServerException
            ? Left(ServerFailure(ErrorCodes.serverError))
            : Left(ServerFailure(ErrorCodes.unKnownError));
      }
    }
  }
}
