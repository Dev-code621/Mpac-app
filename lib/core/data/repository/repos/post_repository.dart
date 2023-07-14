import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/reation_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/base_repository.dart';
import 'package:mpac_app/core/error/exceptions.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/dio_options.dart';
import 'package:mpac_app/core/utils/constants/endpoints.dart';
import 'package:mpac_app/core/utils/constants/error_codes.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/classes/post_params.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/main.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

abstract class PostRepository extends BaseRepository {
  Future<Either<Failure, List<PostModel>>> getPostsFeed(
    String type, {
    int limit = 15,
    int offset = 0,
  });

  Future<Either<Failure, bool>> deleteMedia({
    required String postId,
    required String id,
  });

  Future<Either<Failure, bool>> orderMedia({
    required String postId,
    required String id,
  });

  Future<Either<Failure, bool>> create({
    required PostParams params,
    required HomeBloc homeBloc,
    ProgressCallback? webOnSendProgress,
  });

  Future<Either<Failure, PostModel>> editPost({
    required String description,
    required String sport,
    required List<String> deletedMediaIds,
    required List<AssetEntity> newAssets,
    required Map<String, dynamic> croppedFiles,
    required String postId,
    required HomeBloc homeBloc,
    required List<XFile> newWebAssets,
  });

  Future<Either<Failure, PostModel>> getSpecificPost(String postId);

  Future<Either<Failure, int?>> deletePost(String postId);

  // Reactions

  Future<Either<Failure, List<ReactionModel>>> getPostReactions(
    String postId, {
    int? offset,
    int? limit,
  });

  Future<Either<Failure, ReactionModel>> addReaction(
    String postId,
    String type,
  );

  Future<Either<Failure, bool>> deleteReaction(String postId);

  // Comments

  Future<Either<Failure, List<CommentModel>>> getPostComments(
    String postId, {
    int? offset,
    int? limit,
  });

  Future<Either<Failure, CommentModel>> addNewComment({
    required String postId,
    required String comment,
  });

  Future<Either<Failure, CommentModel>> editComment({
    required String postId,
    required String commentId,
    required String comment,
  });

  Future<Either<Failure, bool>> deleteComment({
    required String postId,
    required String commentId,
  });
}

@LazySingleton(as: PostRepository)
class PostRepositoryImpl extends BaseRepositoryImpl implements PostRepository {
  @override
  final Dio dio;
  @override
  final PrefsHelper prefsHelper;

  PostRepositoryImpl({required this.prefsHelper, required this.dio})
      : super(prefsHelper: prefsHelper, dio: dio);

  @override
  Future<Either<Failure, List<PostModel>>> getPostsFeed(
    String type, {
    int limit = 15,
    int offset = 0,
  }) async {
    try {
      final result = await dio.get(
        "${EndPoints.posts}?type=$type&offset=$offset&limit=$limit",
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<PostModel> posts = [];
        for (var item in json.decode(result.data)) {
          posts.add(PostModel.fromJson(item));
        }
        return Right(posts);
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
  Future<Either<Failure, bool>> create({
    required PostParams params,
    required HomeBloc homeBloc,
    ProgressCallback? webOnSendProgress,
  }) async {
    late final int notificationId;

    if (!kIsWeb) {
      notificationId = await _showUploadStartedNotification();
    } else {
      notificationId = 0;
    }

    try {
      FormData formData = FormData.fromMap(await params.toMap());

      final result = await dio.post(
        EndPoints.posts,
        data: formData,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
        onSendProgress: kIsWeb
            ? webOnSendProgress
            : (count, total) {
                final percentage = ((count / total) * 100).toInt();

                _updateUploadProgressNotification(notificationId, percentage);
              },
      );

      if (result.data != "" && json.decode(result.data) != null) {
        if (!kIsWeb) {
          await _showUploadSuccessNotification(
            notificationId,
            homeBloc,
          );
        }

        return const Right(true);
      } else {
        if (!kIsWeb) {
          await _showUploadFailedNotification(notificationId);
        }

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
      if (!kIsWeb) {
        await _showUploadFailedNotification(notificationId);
      }

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

  Future<int> _showUploadStartedNotification() async {
    const channelId = 'uploads';
    const channelName = 'Uploads';
    const channelDescription = 'Notifications for ongoing uploads';
    const androidSettings = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      indeterminate: true,
      icon: 'ic_launcher_foreground',
    );
    const iOSSettings = DarwinNotificationDetails();
    const platformSettings =
        NotificationDetails(android: androidSettings, iOS: iOSSettings);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Uploading post',
      'Your post is being uploaded',
      platformSettings,
    );

    return notificationId;
  }

  Future<void> _showUploadFailedNotification(int notificationId) async {
    const channelId = 'uploads';
    const channelName = 'Uploads';
    const channelDescription = 'Notifications for ongoing uploads';
    const androidSettings = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      indeterminate: true,
      icon: 'ic_launcher_foreground',
    );
    const iOSSettings = DarwinNotificationDetails();
    const platformSettings =
        NotificationDetails(android: androidSettings, iOS: iOSSettings);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Failed to upload post',
      'Your post has not been uploaded',
      platformSettings,
    );
  }

  Future<void> _showUploadSuccessNotification(
    int notificationId,
    HomeBloc homeBloc,
  ) async {
    const channelId = 'uploads';
    const channelName = 'Uploads';
    const channelDescription = 'Notifications for ongoing uploads';
    const androidSettings = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_launcher_foreground',
    );
    const iOSSettings = DarwinNotificationDetails();
    const platformSettings =
        NotificationDetails(android: androidSettings, iOS: iOSSettings);

    homeBloc.onGetFeedPosts(withLoading: true);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Upload complete',
      'Your post has been successfully uploaded',
      platformSettings,
    );
  }

  void _updateUploadProgressNotification(int notificationId, int percentage) {
    const channelId = 'uploads';
    const channelName = 'Uploads';
    const channelDescription = 'Notifications for ongoing uploads';
    final androidSettings = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: percentage,
      indeterminate: false,
      enableVibration: false,
      playSound: false,
      ongoing: true,
      onlyAlertOnce: true,
      icon: 'ic_launcher_foreground',
    );
    const iOSSettings = DarwinNotificationDetails();

    final platformSettings = NotificationDetails(
      android: androidSettings,
      iOS: iOSSettings,
    );

    flutterLocalNotificationsPlugin.show(
      notificationId,
      'Uploading post',
      '$percentage% uploaded',
      platformSettings,
      payload: 'upload_progress',
    );
  }

  @override
  Future<Either<Failure, PostModel>> getSpecificPost(String postId) async {
    try {
      final result = await dio.get(
        "${EndPoints.posts}/$postId",
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(PostModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, PostModel>> editPost({
    required String postId,
    required String sport,
    required List<String> deletedMediaIds,
    required List<AssetEntity> newAssets,
    required Map<String, dynamic> croppedFiles,
    required String description,
    required HomeBloc homeBloc,
    required List<XFile> newWebAssets,
  }) async {
    final notificationId = await _showUploadStartedNotification();

    try {
      List resultMedias = [];

      for (int i = 0; i < newAssets.length; i++) {
        if (croppedFiles.containsKey(newAssets[i].id)) {
          String path = croppedFiles[newAssets[i].id]['file'].path;
          String? contentType = lookupMimeType(path);
          resultMedias.add(
            await MultipartFile.fromFile(
              path,
              filename: path.split(".")[1],
              contentType: MediaType(
                contentType!.split("/").first,
                contentType.split("/")[1],
                {'Content-Type': contentType},
              ),
            ),
          );
        } else {
          String path = await newAssets[i].file.then((value) {
            return value!.path;
          });
          MediaInfo? compressedVideo;
          if (newAssets[i].type == AssetType.video) {
            if (!path.endsWith('.mp4')) {
              await VideoCompress.setLogLevel(0);
              compressedVideo = await VideoCompress.compressVideo(
                path,
                quality: VideoQuality.DefaultQuality,
                deleteOrigin: false,
                includeAudio: true,
              );
            }
          }

          path = compressedVideo == null ? path : compressedVideo.path!;
          String? contentType = lookupMimeType(path);
          resultMedias.add(
            await MultipartFile.fromFile(
              path,
              filename: path.split(".")[1],
              contentType: MediaType(
                contentType!.split("/").first,
                contentType.split("/")[1],
                {'Content-Type': contentType},
              ),
            ),
          );
        }
      }
      if (newWebAssets.isNotEmpty) {
        for (int i = 0; i < newWebAssets.length; i++) {
          resultMedias.add(
            MultipartFile.fromBytes(
              await newWebAssets[i].readAsBytes(),
              filename: "newAsset$i",
              contentType: MediaType(
                newWebAssets[i].mimeType!.split("/").first,
                newWebAssets[i].mimeType!.split("/")[1],
                {'Content-Type': newWebAssets[i].mimeType!},
              ),
            ),
          );
        }
      }

      FormData formData = FormData.fromMap(
        {'description': description, 'media': resultMedias, 'sport': sport},
      );

      final result = await dio.put(
        "${EndPoints.posts}/$postId",
        data: formData,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
        onSendProgress: (count, total) {
          final percentage = ((count / total) * 100).toInt();

          _updateUploadProgressNotification(notificationId, percentage);
        },
      );

      if (result.data != "" && json.decode(result.data) != null) {
        for (int i = 0; i < deletedMediaIds.length; i++) {
          await deleteMedia(postId: postId, id: deletedMediaIds[i]);
        }

        // for (int i = 0; i < result.length; i++) {
        //   await orderMedia(postId: postId, id: deletedMediaIds[i]);
        // }
        await _showUploadSuccessNotification(
          notificationId,
          homeBloc,
        );

        return Right(PostModel.fromJson(json.decode(result.data)));
      } else {
        await _showUploadFailedNotification(notificationId);
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
      await _showUploadFailedNotification(notificationId);
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
  Future<Either<Failure, int?>> deletePost(String postId) async {
    try {
      final result = await dio.delete(
        "${EndPoints.posts}/$postId",
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(result.statusCode);
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
  Future<Either<Failure, CommentModel>> addNewComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final result = await dio.post(
        EndPoints.postComments(postId),
        data: jsonEncode({'comment': comment}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(CommentModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, ReactionModel>> addReaction(
    String postId,
    String type,
  ) async {
    try {
      final result = await dio.post(
        EndPoints.postReactions(postId),
        data: jsonEncode({'type': type}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(ReactionModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, bool>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final result = await dio.delete(
        EndPoints.deletePostComment(postId: postId, commentId: commentId),
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
  Future<Either<Failure, bool>> deleteReaction(String postId) async {
    try {
      final result = await dio.delete(
        EndPoints.postReactions(postId),
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
  Future<Either<Failure, CommentModel>> editComment({
    required String postId,
    required String commentId,
    required String comment,
  }) async {
    try {
      final result = await dio.put(
        EndPoints.editPostComment(postId: postId, commentId: commentId),
        data: jsonEncode({'comment': comment}),
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        return Right(CommentModel.fromJson(json.decode(result.data)));
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
  Future<Either<Failure, List<CommentModel>>> getPostComments(
    String postId, {
    int? offset,
    int? limit,
  }) async {
    try {
      String endPoint = EndPoints.postComments(postId);
      if (offset != null && limit != null) {
        endPoint = "$endPoint?offset=$offset&limit=$limit";
      }
      final result = await dio.get(
        endPoint,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<CommentModel> comments = [];
        for (var item in json.decode(result.data)) {
          comments.add(CommentModel.fromJson(item));
        }
        return Right(comments);
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
  Future<Either<Failure, List<ReactionModel>>> getPostReactions(
    String postId, {
    int? offset,
    int? limit,
  }) async {
    try {
      String endPoint = EndPoints.postReactions(postId);
      if (offset != null && limit != null) {
        endPoint = "$endPoint?offset=$offset&limit=$limit";
      }
      final result = await dio.get(
        endPoint,
        options: GetOptions.getOptionsWithToken(getBaseHeaders()['token']),
      );
      if (result.data != "" && json.decode(result.data) != null) {
        List<ReactionModel> reactions = [];
        for (var item in json.decode(result.data)) {
          reactions.add(ReactionModel.fromJson(item));
        }
        return Right(reactions);
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
  Future<Either<Failure, bool>> deleteMedia({
    required String postId,
    required String id,
  }) async {
    try {
      final result = await dio.delete(
        EndPoints.deleteMedia(postId, id),
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
  Future<Either<Failure, bool>> orderMedia({
    required String postId,
    required String id,
  }) async {
    try {
      final result = await dio.delete(
        EndPoints.orderMedia(postId, id),
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
}
