import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';

class Dimensions {
  static bool checkKIsWeb(BuildContext context){
    // return kIsWeb;
    return context.w > 550;
  }

  static bool checkKIsWebMobile(BuildContext context){
    // return kIsWeb;
    return context.w < 760;
  }
}