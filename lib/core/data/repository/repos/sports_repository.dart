import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';

abstract class SportsRepository extends BaseRepository {
  Future<Either<Failure, List<SportModel>>> getSports();

  Future<Either<Failure, List<SelectedSportModel>>> getProfileSports(
      bool withSport);

  Future<Either<Failure, bool>> removeSport(String id);

  Future<Either<Failure, SelectedSportModel>> addSport({
    required String sportPath,
    required String value,
  });

  Future<Either<Failure, SelectedSportModel>> updateSport({
    required String sportPath,
    required String value,
  });
}

@LazySingleton(as: SportsRepository)
class SportsRepositoryImpl extends BaseRepositoryImpl
    implements SportsRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  SportsRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, List<SportModel>>> getSports() async {
    try {
      final result = await dio.get(
        EndPoints.sports,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<SportModel> sports = [];
        int index = 0;
        for (var item in json.decode(result.data)) {
          var s = Sport.all.where(
            (element) =>
                element.title.toLowerCase() ==
                item['name'].toString().toLowerCase(),
          );
          sports.add(SportModel.fromJson(item));
          if (s.isNotEmpty) {
            sports[index].backgroundPath = s.first.backgroundPath;
            sports[index].subImagePath = s.first.subImagePath;
            sports[index].color = s.first.color;
          }
          index++;
        }
        return Right(sports);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "Unauthenticated",
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

      // List<SportModel> sports = await RR.readSportsTest();
      // return Right(sports);
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
  Future<Either<Failure, List<SelectedSportModel>>> getProfileSports(
      bool withSport) async {
    try {
      final result = await dio.get(
        EndPoints.profileSports,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<Map<String, dynamic>> sportsFiltered = [];
        for (int i = 0; i < json.decode(result.data).length; i++) {
          if (!sportsFiltered.contains(json.decode(result.data)[i])) {
            if (!sportsFiltered.any((element) => element['sport_path']
                .startsWith(
                    json.decode(result.data)[i]['sport_path'].split('/')[0]))) {
              sportsFiltered.add(json.decode(result.data)[i]);
            }
          }
        }

        List<SelectedSportModel> sports = [];
        int index = 0;
        for (var item in sportsFiltered) {
          sports.add(SelectedSportModel.fromJson(item, withSport));
          if (withSport) {
            var s = Sport.all.where(
              (element) =>
                  element.title.toLowerCase() ==
                  item['sport']['name'].toString().toLowerCase(),
            );
            if (s.isNotEmpty) {
              sports[index].sport!.backgroundPath = s.first.backgroundPath;
              sports[index].sport!.subImagePath = s.first.subImagePath;
              sports[index].sport!.color = s.first.color;
            }
            index++;
          }
        }
        return Right(sports);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "Unauthenticated",
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

      // List<SportModel> sports = await RR.readSportsTest();
      // return Right(sports);
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
  Future<Either<Failure, bool>> removeSport(String id) async {
    try {
      final result = await dio.delete(
        "${EndPoints.profileSports}/$id",
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return const Right(true);
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "Unauthenticated",
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
  Future<Either<Failure, SelectedSportModel>> addSport({
    required String sportPath,
    required String value,
  }) async {
    try {
      final result = await dio.post(
        EndPoints.profileSports,
        data: jsonEncode({'sport_path': sportPath, "value": value}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(
            SelectedSportModel.fromJson(json.decode(result.data), false));
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "Unauthenticated",
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
  Future<Either<Failure, SelectedSportModel>> updateSport({
    required String sportPath,
    required String value,
  }) async {
    try {
      final result = await dio.put(
        "${EndPoints.profileSports}/$sportPath",
        data: jsonEncode({"value": value}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(
            SelectedSportModel.fromJson(json.decode(result.data), false));
      } else {
        if (result.data != "" && json.decode(result.data) != null) {
          return Left(
            ServerFailure(
              ErrorCodes.unAuth,
              errorMessage: "Unauthenticated",
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

class RR {
  static Future<List<SportModel>> readSportsTest() async {
    final String response =
        await rootBundle.loadString('assets/jsons/sports.json');
    final data = await json.decode(response);
    List<SportModel> sports = [];
    int index = 0;
    for (var item in data) {
      var s = Sport.all.where(
        (element) =>
            element.title.toLowerCase() ==
            item['name'].toString().toLowerCase(),
      );
      sports.add(SportModel.fromJson(item));
      if (s.isNotEmpty) {
        sports[index].backgroundPath = s.first.backgroundPath;
        sports[index].subImagePath = s.first.subImagePath;
        sports[index].color = s.first.color;
      }
      index++;
    }
    return sports;
  }

  static String getBackgroundPath(String name) {
    switch (name) {
      case "Basketball":
        return 'assets/images/sports_new/basketball.png';
      case "Football":
        return 'assets/images/sports_new/football.png';
      case "Athletics":
        return 'assets/images/sports_new/athletics.png';
      case "Boxing":
        return 'assets/images/sports_new/boxing.png';
      case "Rugby":
        return 'assets/images/sports_new/rugby.png';
      case "Netball":
        return 'assets/images/sports_new/netball.png';
      case "Swimming":
        return 'assets/images/sports_new/swimming.png';
      case "Cricket":
        return 'assets/images/sports_new/cricket.png';
      case "American football":
        return 'assets/images/sports_new/american_football.png';
      case "Material arts":
        return 'assets/images/sports_new/material_arts.png';
      case "Golf":
        return 'assets/images/sports_new/golf.png';
      case "Tennis":
        return 'assets/images/sports_new/tennis.png';
      case "Gymnastic":
        return 'assets/images/sports_new/gymnastic.png';
      case "Cycling":
        return 'assets/images/sports_new/cycling.png';
      case "Road Racing":
        return 'assets/images/sports_new/road_running.png';
      default:
        return 'assets/images/sports_new/athletics.png';
    }
  }

  static String getSubImagePath(String name) {
    switch (name) {
      case "Basketball":
        return 'assets/images/sub_sports/basketball.png';
      case "Football":
        return 'assets/images/sub_sports/football.png';
      case "Athletics":
        return 'assets/images/sub_sports/athletics.png';
      case "Boxing":
        return 'assets/images/sub_sports/boxing.png';
      case "Rugby":
        return 'assets/images/sub_sports/rugby.png';
      case "Netball":
        return 'assets/images/sub_sports/netball.png';
      case "Swimming":
        return 'assets/images/sub_sports/swimming.png';
      case "Cricket":
        return 'assets/images/sub_sports/cricket.png';
      case "American football":
        return 'assets/images/sub_sports/american_football.png';
      case "Material arts":
        return 'assets/images/sub_sports/material_arts.png';
      case "Golf":
        return 'assets/images/sub_sports/golf.png';
      case "Tennis":
        return 'assets/images/sub_sports/tennis.png';
      case "Gymnastic":
        return 'assets/images/sub_sports/gymnastic.png';
      case "Cycling":
        return 'assets/images/sub_sports/cycling.png';
      case "Road Racing":
        return 'assets/images/sub_sports/road_running.png';
      default:
        return 'assets/images/sub_sports/athletics.png';
    }
  }

  static Color getColor(String name) {
    switch (name) {
      case "":
        return Colors.white;
      default:
        return Colors.white;
    }
  }
}
