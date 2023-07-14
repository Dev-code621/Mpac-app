import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:mpac_app/features/my_account_feature/presentation/widgets/account_tile.dart';

class FollowAndInvitePage extends StatefulWidget {
  const FollowAndInvitePage({Key? key}) : super(key: key);

  @override
  State<FollowAndInvitePage> createState() => _FollowAndInvitePageState();
}

class _FollowAndInvitePageState extends State<FollowAndInvitePage> {
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff373737),
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
                    Text(localizations.follow_and_invite,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: context.h * 0.05,
          ),
          AccountTile(
              title: localizations.invite_friends_by("WhatsApp"),
              onTap: () {},
              svgPath: 'assets/images/account_icons/whatsapp.svg',),
          AccountTile(
              title: localizations.invite_friends_by("Email"),
              onTap: () {},
              svgPath: 'assets/images/account_icons/mail.svg',),
          AccountTile(
              title: localizations.invite_friends_by("SMS"),
              onTap: () {},
              svgPath: 'assets/images/account_icons/sms.svg',),
          AccountTile(
              title: localizations.invite_friends_by(""),
              onTap: () {},
              svgPath: 'assets/images/account_icons/invite_friends_by.svg',),
        ],
      ),
    );
  }
}
