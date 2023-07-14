import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:mpac_app/features/my_players_feature/presentation/widgets/player_widget.dart';

class MyPlayersPage extends StatefulWidget {
  const MyPlayersPage({Key? key}) : super(key: key);

  @override
  State<MyPlayersPage> createState() => _MyPlayersPageState();
}

class _MyPlayersPageState extends State<MyPlayersPage> {
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      Text(localizations.my_players,
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp),),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: context.h * 0.02,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return const PlayerWidget();
                  },),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 16.0, right: 16, left: 16, top: 16.0,),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppScreens.createProfilePage,
                        arguments: {'viewType': ViewType.coach},);
                  },
                  child: Container(
                    width: context.w * 0.35,
                    height: context.h * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: AppColors.primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Add Player",
                            maxLines: 1,
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.sp),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),);
  }
}
