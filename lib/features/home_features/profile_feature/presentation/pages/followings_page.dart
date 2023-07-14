import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_bloc.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/widgets/following_tile_widget.dart';
import 'package:sizer/sizer.dart';

class FollowingsPage extends StatefulWidget {
  final String userId;
  final String type;

  const FollowingsPage({required this.userId, required this.type, Key? key})
      : super(key: key);

  @override
  State<FollowingsPage> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  final _bloc = getIt<ProfileBloc>();
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _bloc.onGetFollowings(widget.userId, widget.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, ProfileState state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            leading: CustomBackButton(
              onBackClicked: () {
                Navigator.pop(context);
              },
              localeName: localizations.localeName,
            ),
            title: Text(widget.type,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,),),
          ),
          body: getListFollowers(state),
        );
      },
    );
  }

  Widget getListFollowers(ProfileState state) {
    if (state.isLoadingFollowings) {
      return Center(
        child: SizedBox(
          height: context.w * 0.35,
          width: context.w * 0.35,
          child: CircularProgressIndicator(
            color: AppColors.logoColor,
            strokeWidth: 1.5,
          ),
        ),
      );
    } else if (state.errorLoadingFollowings) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            _bloc.onGetFollowings(widget.userId, widget.type);
          },
          message: widget.type == "followings"
              ? "No followings found!"
              : "No followers found!",
          btnContent: localizations.retry,
        ),
      );
    } else {
      if (widget.type == "followers" && state.followers.isEmpty) {
        return Center(
          child: Text("No followers found!",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),),
        );
      } else if (widget.type == "followings" && state.followings.isEmpty) {
        return Center(
          child: Text("No followings found!",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),),
        );
      } else {
        return ListView.builder(
            itemCount: widget.type == "followers"
                ? state.followers.length
                : state.followings.length,
            itemBuilder: (BuildContext context, int index) {
              return FollowingTileWidget(
                userModel: widget.type == "followers"
                    ? state.followers[index]
                    : state.followings[index],
              );
            },);
      }
    }
  }
}
