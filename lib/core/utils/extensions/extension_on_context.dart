import 'package:flutter/cupertino.dart';

extension ExtensionOnContext on BuildContext {
  Size get size => MediaQuery.of(this).size;

  double get w => size.width;

  double get h => size.height;
}
