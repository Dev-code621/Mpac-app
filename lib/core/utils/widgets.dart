// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';

class Widgets {
  static Text pageTitle(
    String title, {
    int? maxLines,
  }) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16.0),
      maxLines: maxLines ?? 1,
    );
  }

  static Widget imageNetwork(
    String? imageUrl,
    double height,
    IconData errorIcon, {
    bool? isProfile = false,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isProfile! ? 100 : 0),
        child: Image.network(
          imageUrl,
          width: height,
          height: height,
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            return Icon(errorIcon, size: height);
          },
        ),
      );
    } else {
      return Icon(
        errorIcon,
        size: height,
        color: Colors.white,
      );
    }
  }

  static Widget textField(
    TextEditingController controller,
    String labelText, {
    int? maxLines,
    bool? enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        hintText: labelText,
      ),
      maxLines: maxLines ?? 1,
    );
  }
}
