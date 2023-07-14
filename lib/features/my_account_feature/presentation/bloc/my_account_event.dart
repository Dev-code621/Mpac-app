import 'dart:io';

import 'package:flutter/services.dart';

abstract class MyAccountEvent {}

class ChangeProfilePicture extends MyAccountEvent {
  final File? file;
  final Uint8List? data;

  ChangeProfilePicture( {this.file,this.data});
}
class ClearFailures extends MyAccountEvent {}