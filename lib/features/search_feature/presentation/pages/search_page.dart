import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late AppLocalizations localizations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          getSearchBarWidget(),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Container(); /*Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PostWidget(postModel: Post.all[0]),
                );*/
              },),),
        ],
      ),
    );
  }

  Widget getSearchBarWidget() {
    return Row(
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
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 4.0),
            height: context.h * 0.055,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                color: AppColors.unSelectedWidgetColor.withOpacity(0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.unSelectedWidgetColor, size: context.h * 0.04),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: context.h * 0.009),
                      child: TextField(
                        maxLines: 1,
                        controller: _searchController,
                        keyboardType: TextInputType.name,

                        onChanged: (val){},
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 10.sp, // 8
                          color: AppColors.textFieldColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: localizations.player_name,
                          hintStyle: TextStyle(
                            fontSize: 10.sp, // 10
                            color: AppColors.hintTextFieldColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        cursorColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16,),
      ],
    );
  }
}
