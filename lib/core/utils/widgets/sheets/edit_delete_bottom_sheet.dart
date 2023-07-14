import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';

class Sheet {
  static editDeleteSheet(BuildContext context, {required Function onEdit, required Function onDelete}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xff141313),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
        ),
        builder: (BuildContext bc) {
          return SizedBox(
            height: context.h * 0.28,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 12,
                    width: context.w * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.edit,
                      color: Colors.white,
                      size: Dimensions.checkKIsWeb(context) ? context.w * 0.03 : context.w * 0.06),
                  title: Text(
                    'Edit post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.028 : 12.sp,
                    ),
                  ),
                  onTap: () {
                    onEdit();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete,
                      color: Colors.red,
                      size: Dimensions.checkKIsWeb(context) ? context.w * 0.03 : context.w * 0.06,),
                  title: Text(
                    'Delete post',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.028 : 12.sp,
                    ),
                  ),
                  onTap: () async {
                    onDelete();
                  },
                )
              ],
            ),
          );
        },);
  }

}