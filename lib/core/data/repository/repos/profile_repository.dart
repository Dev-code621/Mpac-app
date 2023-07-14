import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/follower_model.dart';
import 'package:mpac_app/core/data/models/media_model.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/classes/profile_params.dart';

import 'package:mpac_app/core/error/failures.dart';

abstract class ProfileRepository extends BaseRepository {
  Future<Either<Failure, bool>> updateUserInformation({
    ProfileParams? params,
    String? profileType,
    int? boardingStep,
    String? firebaseToken,
    Map<String, dynamic>? dataForEdit,
  });

  Future<Either<Failure, List<FollowerModel>>> getFollowers();

  Future<Either<Failure, List<FollowerModel>>> getFollowings();

  Future<Either<Failure, List<PostModelTest>>> getPosts();

  Future<Either<Failure, List<MediaModel>>> getMedias({
    required String type,
    required String sport,
    required String userId,
    int offset = 0,
    int limit = 15,
  });

  Future<Either<Failure, UserModel>> getCurrentUser();
}

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl extends BaseRepositoryImpl
    implements ProfileRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  ProfileRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, bool>> updateUserInformation({
    ProfileParams? params,
    String? profileType,
    int? boardingStep,
    String? firebaseToken,
    Map<String, dynamic>? dataForEdit,
  }) async {
    try {
      final result = await dio.put(
        EndPoints.profile,
        data: profileType == null
            ? boardingStep != null
                ? jsonEncode({'onboarding_step': boardingStep})
                : firebaseToken != null
                    ? jsonEncode({'fcm_token': firebaseToken})
                    : dataForEdit != null
                        ? dataForEdit.containsKey("interested_sports")
                            ? dataForEdit
                            : FormData.fromMap(dataForEdit)
                        : FormData.fromMap(await params!.toMap())
            : jsonEncode({'type': profileType}),
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
  Future<Either<Failure, List<FollowerModel>>> getFollowers() async {
    try {
      final result = await dio.get(
        EndPoints.profileFollowers,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<FollowerModel> followers = [];
        for (var item in json.decode(result.data)) {
          followers.add(FollowerModel.fromJson(item));
        }
        return Right(followers);
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
  Future<Either<Failure, List<FollowerModel>>> getFollowings() async {
    try {
      final result = await dio.get(
        EndPoints.profileFollowings,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<FollowerModel> followers = [];
        for (var item in json.decode(result.data)) {
          followers.add(FollowerModel.fromJson(item));
        }
        return Right(followers);
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
  Future<Either<Failure, List<PostModelTest>>> getPosts() async {
    try {
      final result = await dio.get(
        EndPoints.profilePosts,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<PostModelTest> posts = [];
        for (var item in json.decode(result.data)) {
          posts.add(PostModelTest.fromJson(item));
        }
        return Right(posts);
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
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final result = await dio.get(
        EndPoints.profile,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(UserModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, List<MediaModel>>> getMedias({
    required String type,
    required String sport,
    required String userId,
    int offset = 0,
    int limit = 15,
  }) async {
    try {
      String endPoint = EndPoints.profileMedias(
        userId: userId,
        sport: sport,
        type: type,
        offset: offset,
        limit: limit,
      );

      final result = await dio.get(
        endPoint,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<MediaModel> medias = [];
        for (var item in json.decode(result.data)) {
          medias.add(MediaModel.fromJson(item));
        }
        return Right(medias);
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
}
