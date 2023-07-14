import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';

class CustomImagePicker with FlushBarMixin {
  ImagePicker imagePicker = ImagePicker();

  pickImage(
      {required ImageSource source,
      required BuildContext context,
      required Function(XFile?) onWebPicked,
      required Function(XFile?) onMobilePicked,}) async {
    // bool hasAccess = false;
    //
    // if (source == ImageSource.gallery) {
    //   await Permission.photos.request().then((vv) async {
    //     if (vv.isDenied) {
    //       await Permission.photos.request().then((vv1) {
    //         hasAccess = vv1.isGranted;
    //       });
    //     } else if (vv.isPermanentlyDenied) {
    //       exceptionFlushBar(
    //           onChangeStatus: (s) {},
    //           onHidden: () {
    //             openAppSettings();
    //           },
    //           duration: const Duration(milliseconds: 1500),
    //           message:
    //               "Go to the settings and enable the photos permission for the application!",
    //           context: context);
    //     } else if (vv.isGranted) {
    //       hasAccess = true;
    //     }
    //   });
    // } else {
    //   await Permission.camera.request().then((vv) async {
    //     if (vv.isDenied) {
    //       await Permission.photos.request().then((vv1) {
    //         hasAccess = vv1.isGranted;
    //       });
    //     } else if (vv.isPermanentlyDenied) {
    //       exceptionFlushBar(
    //           onChangeStatus: (s) {},
    //           onHidden: () {
    //             openAppSettings();
    //           },
    //           duration: const Duration(milliseconds: 1500),
    //           message:
    //               "Go to the settings and enable the camera permission for the application!",
    //           context: context);
    //     } else if (vv.isGranted) {
    //       hasAccess = true;
    //     }
    //   });
    // }

    // if (hasAccess) {
      imagePicker.pickImage(source: source).then((value) async {
        if (!kIsWeb) {
          onMobilePicked(value);
        } else {
          onWebPicked(value);
        }
      });
    // }
  }
}
