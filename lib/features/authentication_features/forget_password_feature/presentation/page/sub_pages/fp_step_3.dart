import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';


class FpStep3 extends StatefulWidget {
  final AppLocalizations localizations;

  const FpStep3({required this.localizations, Key? key}) : super(key: key);

  @override
  State<FpStep3> createState() => _FpStep3State();
}

class _FpStep3State extends State<FpStep3> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            widget.localizations.password_reset_successfully,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.green,
            size: context.w * 0.5,
          ),
        )
      ],
    );
  }
}
