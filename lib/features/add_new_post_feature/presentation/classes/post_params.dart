import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

class PostParams {
  String description = "";
  List<MediaSource>? medias;
  List<Uint8List>? mediasWeb;

  List<XFile>? webVideos;

  Map<String, dynamic>? croppedFiles;

  String sport = "General";

  PostParams(
    this.description, {
    this.medias,
    this.mediasWeb,
    this.croppedFiles,
    this.webVideos,
    this.sport = "General",
  });

  Future<Map<String, dynamic>> toMap() async {
    return {
      'description': description,
      'media': await getMedias(),
      'sport': sport
    };
  }

  Future<List> getMedias() async {
    List result = [];

    /// Mobile Media
    if (medias != null && medias!.isNotEmpty) {
      for (int i = 0; i < medias!.length; i++) {
        if (croppedFiles!.containsKey(medias![i].assetEntity.id)) {
          String path = croppedFiles![medias![i].assetEntity.id]['file'].path;
          String? contentType = lookupMimeType(path);
          result.add(
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
          String path = await medias![i].assetEntity.file.then((value) {
            return value!.path;
          });
          MediaInfo? compressedVideo;
          if (medias![i].assetEntity.type == AssetType.video) {
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
          result.add(
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
      return result;
    }

    /// Web Images
    else if (mediasWeb != null && mediasWeb!.isNotEmpty) {
      for (int i = 0; i < mediasWeb!.length; i++) {
        if (croppedFiles!.containsKey(i.toString())) {
          result.add(
            MultipartFile.fromBytes(
              await croppedFiles![i.toString()]['file'].readAsBytes(),
              filename: "${DateTime.now()}$i",
              contentType: MediaType(
                'image',
                'jpeg',
                {'Content-Type': 'image/jpeg'},
              ),
            ),
          );
        } else {
          result.add(
            MultipartFile.fromBytes(
              mediasWeb![i],
              filename: "${DateTime.now()}$i",
              contentType: MediaType(
                'image',
                'jpeg',
                {'Content-Type': 'image/jpeg'},
              ),
            ),
          );
        }
      }
      return result;
    }

    /// Web Videos
    else if (webVideos != null && webVideos!.isNotEmpty) {
      for (int i = 0; i < webVideos!.length; i++) {
        dynamic bytes = await webVideos![i].readAsBytes();

        result.add(
          MultipartFile.fromBytes(
            bytes,
            filename: "${DateTime.now()}$i",
            contentType: MediaType(
              'video',
              'mp4',
              {'Content-Type': 'video/mp4'},
            ),
          ),
        );
      }
      return result;
    }

    /// Else
    else {
      return [];
    }
  }
}
