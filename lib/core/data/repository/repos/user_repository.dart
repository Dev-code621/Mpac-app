import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';

import 'package:mpac_app/core/utils/constants/dio_options.dart';

abstract class UserRepository extends BaseRepository {
  Future<Either<Failure, UserModel>> getUser(String userId);

  Future<Either<Failure, List<UserModel>>> getFollowers(String userId);

  Future<Either<Failure, List<UserModel>>> getFollowings(String userId);

  Future<Either<Failure, List<PostModel>>> getPosts(String userId,
      {int limit = 15, int offset = 0, String sport = "general",});

  Future<Either<Failure, UserModel>> follow(String userId);

  Future<Either<Failure, int>> unfollow(String userId);
}

@Injectable(as: UserRepository)
class UserRepositoryImpl extends BaseRepositoryImpl implements UserRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  UserRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(prefsHelper: prefsHelper, dio: dio);

  @override
  Future<Either<Failure, UserModel>> getUser(String userId) async {
    try {
      final result = await dio.get(EndPoints.user(userId),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        UserModel user = UserModel.fromJson(json.decode(result.data));
        // prefsHelper.saveSelectedSports(user.sports ?? []);
        String selectedFilter = prefsHelper.getSelectedFilter;
        bool yesItsStill = false;
        if(selectedFilter.isNotEmpty) {
          for (int i = 0; i < user.sports!.length; i++) {
            if(user.sports![i].sport!.name == selectedFilter){
              yesItsStill = true;
            }
          }
        }

        if(!yesItsStill){
          prefsHelper.savePostFilter("");
        }
        return Right(user);
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
  Future<Either<Failure, List<UserModel>>> getFollowers(String userId) async {
    try {
      final result = await dio.get(EndPoints.usersFollowers(userId),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<UserModel> followers = [];
        for (var item in json.decode(result.data)) {
          followers.add(UserModel.fromJson(item));
        }
        return Right(followers);
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
  Future<Either<Failure, List<UserModel>>> getFollowings(String userId) async {
    try {
      final result = await dio.get(EndPoints.usersFollowings(userId),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<UserModel> followers = [];
        for (var item in json.decode(result.data)) {
          followers.add(UserModel.fromJson(item));
        }
        return Right(followers);
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
  Future<Either<Failure, List<PostModel>>> getPosts(String userId,
      {int limit = 15, int offset = 0, String sport = "general",}) async {
    try {
      final result = await dio.get(
          EndPoints.userPosts(userId) + (sport.toLowerCase() == "general"
              ? "?limit=$limit&offset=$offset"
              : "?limit=$limit&offset=$offset&sport=$sport"),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        List<PostModel> posts = [];
        for (var item in json.decode(result.data)) {
          posts.add(PostModel.fromJson(item));
        }
        return Right(posts);
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
  Future<Either<Failure, UserModel>> follow(String userId) async {
    try {
      final result = await dio.post(EndPoints.followUser(userId),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(UserModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, int>> unfollow(String userId) async {
    try {
      final result = await dio.post(EndPoints.unfollowUser(userId),
          options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),);
      if (result.data != "" && json.decode(result.data) != null) {
        return const Right(200);
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
