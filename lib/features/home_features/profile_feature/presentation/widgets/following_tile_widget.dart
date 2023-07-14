import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:sizer/sizer.dart';

class FollowingTileWidget extends StatelessWidget {
  final UserModel userModel;

  const FollowingTileWidget({required this.userModel, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(
          context,
          AppScreens.profilePage,
          arguments: {
            'profile_id': userModel.id,
            'withAppBar': true,
            'flowCalled': "outside"
          },
        );
      },
      child: SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Row(
            children: [
              Container(
                width: context.w * 0.13,
                height: context.w * 0.13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
                  image: userModel.image == null
                      ? null
                      : DecorationImage(
                    image: NetworkImage(userModel.image!),
                    fit: BoxFit.cover,),),
                child: Stack(
                  children: [
                    userModel.image != null
                        ? Container()
                        : Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.person,
                        color: Colors.grey.withOpacity(0.5),
                        size: context.w * 0.055,),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${userModel.firstName ?? ""} ${userModel.lastName ?? ""}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // Text(
                    //   userModel.email == null
                    //       ? userModel.gender == null
                    //           ? "-"
                    //           : userModel.gender!
                    //       : userModel.email!,
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //       color: AppColors.secondaryFontColor, fontSize: 10.sp),
                    // ),
                  ],
                ),)
            ],
          ),
        ),
      ),
    );
  }
}
