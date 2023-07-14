import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/reation_model.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:sizer/sizer.dart';

class LikeWidget extends StatelessWidget {
  final ReactionModel reactionModel;

  const LikeWidget({required this.reactionModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppScreens.profilePage,
            arguments: {
              'profile_id': reactionModel.userId,
              'withAppBar': true,
              'flowCalled': 'likes'
            },);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: context.w * 0.1,
                  height: context.w * 0.1,
                  decoration: reactionModel.user!.image == null
                      ? BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          shape: BoxShape.circle,
                        )
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(reactionModel.user!.image!),
                              fit: BoxFit.fitHeight,),),
                  child: reactionModel.user!.image == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.withOpacity(0.5),
                        )
                      : Container(),
                ),
                const SizedBox(
                  width: 4,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${reactionModel.user!.firstName!} ${reactionModel.user!.lastName!}",
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
