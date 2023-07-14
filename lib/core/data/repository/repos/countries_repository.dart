import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';

import 'package:mpac_app/core/utils/constants/dio_options.dart';

abstract class CountriesRepository extends BaseRepository {
  Future<Either<Failure, List<CountryModel>>> getCountries();

  Future<Either<Failure, StateModel>> getState({required String countryName});
}

@LazySingleton(as: CountriesRepository)
class CountriesRepositoryImpl extends BaseRepositoryImpl
    implements CountriesRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  CountriesRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, List<CountryModel>>> getCountries() async {
    try {
      final result = await dio.get(EndPoints.countries,
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<CountryModel> countries = [];
        for (var item in json.decode(result.data)) {
          countries.add(CountryModel.fromJson(item));
        }
        return Right(countries);
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

  @override
  Future<Either<Failure, StateModel>> getState(
      {required String countryName,}) async {
    try {
      final result = await dio.get(EndPoints.states(countryName),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        StateModel state = StateModel.fromJson(json.decode(result.data));
        return Right(state);
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
