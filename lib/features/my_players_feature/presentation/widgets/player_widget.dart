import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, AppScreens.myPlayerInformationPage);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0, bottom: 1),
        child: Container(
          color: AppColors.backgroundColor,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12, bottom: 12),
                child: Container(
                  height: context.w * 0.18,
                  width: context.w * 0.18,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      image: DecorationImage(
                          image: AssetImage('assets/images/general/post.png'),
                          fit: BoxFit.cover,),),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "John Ahraham",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.white,),
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      "1998/02/02 - 185 Cm - 70 Kg",
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.secondaryFontColor,),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
