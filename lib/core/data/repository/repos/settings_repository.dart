import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/settings_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';

import 'package:mpac_app/core/utils/constants/dio_options.dart';

abstract class SettingsRepository extends BaseRepository {
  Future<Either<Failure, List<SettingsModel>>> settings();
}

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl extends BaseRepositoryImpl
    implements SettingsRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  SettingsRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, List<SettingsModel>>> settings() async {
    try {
      final result = await dio.get(EndPoints.settings,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<SettingsModel> settings = [];
        for (var item in json.decode(result.data)) {
          settings.add(SettingsModel.fromJson(item));
        }
        await prefsHelper.saveUserSettings(settings);
        return Right(settings);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(ServerFailure(ErrorCodes.unAuth,
            errorMessage: "Unauthenticated",),);
        } else {
          return Left(ServerFailure(ErrorCodes.serverError,
            errorMessage: "Server error!",),);
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response == null) {
          return Left(ServerFailure(ErrorCodes.noConnection,
            errorMessage: "No internet connection!",),);
        } else {
          if (json.decode(e.response?.data) != null &&
              json.decode(e.response?.data)['message'] != null) {
            return Left(ServerFailure(ErrorCodes.serverError,
              errorMessage: json.decode(e.response?.data)['message'],),);
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
