import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';
import 'package:universal_io/io.dart';
import 'package:http_parser/http_parser.dart';

abstract class AccountRepository extends BaseRepository {
  Future<Either<Failure, UserModel>> updateProfilePicture({
    required File? file,
    Uint8List? imageData,
  });
}

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl extends BaseRepositoryImpl
    implements AccountRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  AccountRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(dio: dio, prefsHelper: prefsHelper);

  @override
  Future<Either<Failure, UserModel>> updateProfilePicture({
    required File? file,
    Uint8List? imageData,
  }) async {
    try {
      // String filePath = createFileFromBytes(imageData!).path;
      // File f = await File('${DateTime.now().toString()}.jpg').writeAsBytes(imageData);
      String? contentType;
      if (file != null) {
        contentType = lookupMimeType(file.path);
      } else {
        contentType = lookupMimeType("", headerBytes: imageData); // jpeg
      }

      FormData data = FormData.fromMap({
        'profile_image': imageData == null
            ? await MultipartFile.fromFile(
                file!.path,
                contentType: contentType == null
                    ? null
                    : MediaType(
                        contentType.split("/").first,
                        contentType.split("/")[1],
                        {'Content-Type': contentType},
                      ),
              )
            : MultipartFile.fromBytes(
                imageData,
                filename: DateTime.now().toString(),
                contentType: contentType == null
                    ? null
                    : MediaType(
                        contentType.split("/").first,
                        contentType.split("/")[1],
                        {'Content-Type': contentType},
                      ),
              )
      });
      final result = await dio.put(
        EndPoints.profile,
        data: data,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        final userResponse = UserModel.fromJson(json.decode(result.data));
        await prefsHelper.prefs.setString(
          SharedPreferencesKeys.userProfilePicture,
          userResponse.image!,
        );
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

  File createFileFromBytes(Uint8List bytes) => File.fromRawPath(bytes);
}
