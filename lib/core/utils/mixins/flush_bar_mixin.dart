import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

mixin FlushBarMixin {
  void exceptionFlushBar(
      {String? message,
      Function? onHidden,
      BuildContext? context,
      Function(FlushbarStatus)? onChangeStatus,
      Duration? duration,
      FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,}) {
    if (kIsWeb) {
      final snackBar = SnackBar(content: Text(message ?? "-"));
      ScaffoldMessenger.of(context!).showSnackBar(snackBar);
      if (onHidden != null) {
        onHidden();
      }
    } else {
      Flushbar(
        textDirection: TextDirection.rtl,
        icon: const Icon(
          Icons.info,
          color: Colors.red,
        ),
        onStatusChanged: (status) {
          onChangeStatus!(status!);
        },
        flushbarPosition: flushbarPosition,
        margin: const EdgeInsets.all(12.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        message: message,
        duration: duration ?? const Duration(milliseconds: 2000),
      ).show(context!).then((value) {
        onHidden!();
      });
    }
  }

  void doneFlushBar(
      {String? title,
      String? message,
      Function? onHidden,
      BuildContext? context,
      required Color backgroundColor,
      Function(FlushbarStatus)? onChangeStatus,
      Duration? duration,
      FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,}) {
    if (kIsWeb) {
      final snackBar = SnackBar(
          duration: duration!,
          margin: const EdgeInsets.all(12.0),
          content: Text(message ?? "-"),
          backgroundColor: backgroundColor,);
      ScaffoldMessenger.of(context!).showSnackBar(snackBar);
      if (onHidden != null) {
        onHidden();
      }
    } else {
      Flushbar(
        backgroundColor: backgroundColor,
        icon: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onStatusChanged: (status) {
          onChangeStatus!(status!);
        },
        title: title,
        margin: const EdgeInsets.all(12.0),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        message: message,
        flushbarPosition: flushbarPosition,
        duration: duration ?? const Duration(milliseconds: 1000),
      ).show(context!).then((value) {
        onHidden!();
      });
    }
  }
}
