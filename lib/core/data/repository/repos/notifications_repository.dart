import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/notification_entity.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';

import 'package:mpac_app/core/error/failures.dart';

abstract class NotificationsRepository extends BaseRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications(
      {int? offset, int? limit,});

  Future<Either<Failure, bool>> markAsRead(String id);

  Future<Either<Failure, bool>> marAllAsRead();
}

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl extends BaseRepositoryImpl
    implements NotificationsRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  NotificationsRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications(
      {int? offset, int? limit,}) async {
    try {
      String endpoint = EndPoints.notifications;
      if (offset != null) {
        endpoint = "$endpoint?offset=$offset&limit=$limit";
      }
      final result = await dio.get(endpoint,
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<NotificationModel> notifications = [];
        for (var item in json.decode(result.data)) {
          notifications.add(NotificationModel.fromJson(item));
        }
        return Right(notifications);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
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
  Future<Either<Failure, bool>> marAllAsRead() async {
    try {
      final result = await dio.post(EndPoints.markAllAsReadNotifications,
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
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
  Future<Either<Failure, bool>> markAsRead(String id) async {
    try {
      final result = await dio.post(EndPoints.markAsReadNotification(id),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
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
