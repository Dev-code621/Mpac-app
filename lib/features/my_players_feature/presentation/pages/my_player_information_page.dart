import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';


class MyPlayerInformationPage extends StatefulWidget {
  const MyPlayerInformationPage({Key? key}) : super(key: key);

  @override
  State<MyPlayerInformationPage> createState() =>
      _MyPlayerInformationPageState();
}

class _MyPlayerInformationPageState extends State<MyPlayerInformationPage> {
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                          height: context.h * 0.05,
                          width: context.w * 0.15,
                          child: Center(
                            child: Icon(Icons.arrow_back_ios,
                                color: const Color(0xffB7B7B7),
                                size: context.h * 0.025,),
                          ),),
                    ),
                    Text("John Ahraham Account",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: context.h * 0.04,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                //   child: CustomProfileInformation(),
                // ),
                SizedBox(
                  height: context.h * 0.04,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text(
                    localizations.personal_info,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      informationTile(
                          title: localizations.date_of_birth,
                          subTitle: '12/12/2000',),
                      const SizedBox(width: 5),
                      informationTile(
                          title: localizations.gender, subTitle: 'Male',),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      informationTile(
                          title: localizations.height, subTitle: '186 cm',),
                      const SizedBox(width: 5),
                      informationTile(
                          title: localizations.weight, subTitle: '75 Kg',),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      informationTile(
                          withDivider: false,
                          title: localizations.town,
                          subTitle: 'Dubai',),
                      const SizedBox(width: 5),
                      informationTile(
                          withDivider: false,
                          title: localizations.country,
                          subTitle: 'UAE',),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 16.0,),
                  child: Text(
                    localizations.current_location,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      informationTile(
                          withDivider: true,
                          title: localizations.country,
                          subTitle: 'UAE',),
                      const SizedBox(width: 5),
                      informationTile(
                          withDivider: true,
                          title: localizations.state,
                          subTitle: 'Dubai',),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      informationTile(
                          withDivider: false,
                          title: localizations.city_town,
                          subTitle: 'Dubai',),
                      const SizedBox(width: 5),
                      informationTile(
                          withDivider: false,
                          title: localizations.home_address,
                          subTitle: 'DIP, Schon Business Park',),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 16.0,),
                  child: Text(
                    localizations.sports,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,),
                  ),
                ),
                // SkillWidget(
                //     skillModel: Sport.all[0],
                //     localizations: localizations,
                //     localeName: localizations.localeName),
                // SkillWidget(
                //   skillModel: Sport.all[0],
                //   localizations: localizations,
                //     localeName: localizations.localeName),

                SizedBox(
                  height: context.h * 0.02,
                ),
              ],
            ),
          ),)
        ],
      ),
    );
  }

  Expanded informationTile(
      {required String title,
      required String subTitle,
      bool withDivider = true,}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(color: AppColors.secondaryFontColor, fontSize: 10.sp),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            subTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 11.sp),
          ),
          const SizedBox(
            height: 6,
          ),
          withDivider
              ? Container(
                  color: AppColors.unSelectedWidgetColor,
                  height: 0.7,
                )
              : Container(),
        ],
      ),
    );
  }
}
