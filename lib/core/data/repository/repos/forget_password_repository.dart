import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/core/error/failures.dart';

abstract class ForgetPasswordRepository extends BaseRepository {
  Future<Either<Failure, bool>> requestResetPassword({required String email});

  Future<Either<Failure, bool>> resetPassword(
      String code, String password, String email,);
}

@LazySingleton(as: ForgetPasswordRepository)
class ForgetPasswordRepositoryImpl extends BaseRepositoryImpl
    implements ForgetPasswordRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  ForgetPasswordRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, bool>> requestResetPassword(
      {required String email,}) async {
    try {
      final result = await dio.post(EndPoints.requestResetPassword,
          data: jsonEncode({
            'email': email,
          }),);
      if (json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (json.decode(result.data) != null) {
          return Left(ServerFailure(ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",),);
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
  Future<Either<Failure, bool>> resetPassword(
      String code, String password, String email,) async {
    try {
      final result = await dio.post(EndPoints.resetPassword,
          data:
              jsonEncode({'email': email, 'code': code, 'password': password}),);
      if (json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (json.decode(result.data) != null) {
          return Left(ServerFailure(ErrorCodes.unAuth,
              errorMessage: "UnAuthenticated!",),);
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
