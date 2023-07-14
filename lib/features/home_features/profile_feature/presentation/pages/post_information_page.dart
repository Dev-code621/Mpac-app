import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/post_widget.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_bloc.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_state.dart';

class PostInformationPage extends StatefulWidget {
  final String postId;

  const PostInformationPage({required this.postId, Key? key}) : super(key: key);

  @override
  State<PostInformationPage> createState() => _PostInformationPageState();
}

class _PostInformationPageState extends State<PostInformationPage>
    with SingleTickerProviderStateMixin {
  late AppLocalizations localizations;
  final _bloc = getIt<ProfileBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _bloc.onGetSpecificPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, ProfileState state) {},
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ProfileState state) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: CustomBackButton(
                arrowColor: Colors.white,
                onBackClicked: () {
                  Navigator.pop(context);
                },
                localeName: localizations.localeName,
              ),
            ),
            body: getBodyWidget(state),
          );
        },
      ),
    );
  }

  Widget getBodyWidget(ProfileState state) {
    if (state.isLoadingSpecificPost || state.specificPostModel == null) {
      return Center(
        child: SizedBox(
          height: context.w * 0.5,
          width: context.w * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.primaryColor,
          ),
        ),
      );
    } else if (state.errorLoadingSpecificPost) {
      return RefreshIndicator(
        onRefresh: () {
          _bloc.onGetSpecificPost(widget.postId);
          return Future.value(true);
        },
        child: Stack(
          children: [
            ListView(),
            Center(
              child: ErrorView(
                color: AppColors.primaryColor.withOpacity(0.8),
                onReload: () {
                  _bloc.onGetSpecificPost(widget.postId);
                },
                message: "Error loading post",
                btnContent: localizations.retry,
                withRefreshBtn: false,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: PostWidget(
          holderBloc: getIt<HolderBloc>(),
          isInView: true,
          goToFullScreen: (initialMediaIndex) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         MediaFullScreenView(
            //           holderBloc: getIt<HolderBloc>(),
            //           initialPostIndex: index,
            //           posts: state.posts
            //               .map(
            //                 (e) => FullScreenPostParams(
            //               withClickOnProfile: true,
            //               initialMediaIndex: initialMediaIndex,
            //               heroId: state.posts[index].id,
            //               onDisposeHorizontalList: (Map map) {
            //                 disposeAll(state);
            //                 if (state.posts[index].medias.isNotEmpty &&
            //                     state.posts[index].medias[map['mediaIndex']]
            //                         .type ==
            //                         "video") {
            //                   state.posts[index].medias[map['mediaIndex']]
            //                       .isLoading = true;
            //
            //                   state.posts[index].medias[map['mediaIndex']]
            //                       .videoPlayerController =
            //                   VideoPlayerController.network(
            //                     state.posts[index].medias[map['mediaIndex']]
            //                         .url,
            //                   )
            //                     ..initialize().then((v) {
            //                       state.posts[index].streamer.add({
            //                         'ratio': state
            //                             .posts[index]
            //                             .medias[map['mediaIndex']]
            //                             .videoPlayerController!
            //                             .value
            //                             .aspectRatio,
            //                         'currentDurationInSeconds': 0
            //                       });
            //
            //                       state
            //                           .posts[index]
            //                           .medias[map['mediaIndex']]
            //                           .videoPlayerController!
            //                           .addListener(() {
            //                         state.posts[index].streamer.add({
            //                           'ratio': state
            //                               .posts[index]
            //                               .medias[map['mediaIndex']]
            //                               .videoPlayerController!
            //                               .value
            //                               .aspectRatio,
            //                           'currentDurationInSeconds': state
            //                               .posts[index]
            //                               .medias[map['mediaIndex']]
            //                               .videoPlayerController!
            //                               .value
            //                               .position
            //                               .inSeconds
            //                         });
            //                       });
            //                     })
            //                     ..setVolume(0.0)
            //                     ..play();
            //
            //                   state.posts[index].medias[map['mediaIndex']]
            //                       .isLoading = false;
            //                 }
            //
            //                 // if(state.posts[i].id == map['postId']){
            //                 //   if(state.posts[i].medias[j].id != map['mediaId']) {
            //                 //     if (state.posts[i].medias[j].videoPlayerController != null) {
            //                 //       state.posts[i].medias[j].videoPlayerController!.dispose();
            //                 //     }
            //                 //   }
            //                 // } else {
            //                 //   if(state.posts[i].medias[j].videoPlayerController != null){
            //                 //     state.posts[i].medias[j].videoPlayerController!.dispose();
            //                 //   }
            //                 // }
            //
            //                 // setState(() {});
            //               },
            //               onLikesClicked: () {
            //                 Navigator.pushNamed(
            //                   context,
            //                   AppScreens.likesPage,
            //                   arguments: {'post': state.posts[index]},
            //                 );
            //               },
            //               onBackFromComments: (val) {
            //                 BlocProvider.of<TrendingBloc>(context)
            //                     .onGetTrendingPosts(withLoading: false);
            //               },
            //               post: state.posts[index],
            //               onAddLike: (type) {
            //                 if (!state.liking) {
            //                   BlocProvider.of<TrendingBloc>(context)
            //                       .onLikingPost(
            //                     state.posts[index].id,
            //                     type,
            //                     index,
            //                   );
            //                 }
            //               },
            //               onDisLike: () {
            //                 if (!state.liking) {
            //                   BlocProvider.of<TrendingBloc>(context)
            //                       .onDisLikingPost(
            //                     state.posts[index].id,
            //                     "love",
            //                     index,
            //                   );
            //                 }
            //               },
            //               onEditPost: () {},
            //               onDeletePost: () {},
            //             ),
            //           )
            //               .toList(),
            //         ),
            //   ),
            // );
          },
          onBackFromComments: (v) {
            _bloc.onGetSpecificPost(widget.postId);
          },
          disableScrolling: () {},
          enableScrolling: () {},
          postModel: state.specificPostModel!,
          onAddLike: (type) {},
          onDisLike: () {},
          onDisposeHorizontalList: (map) {},
          onLikesClicked: () {
            Navigator.pushNamed(
              context,
              AppScreens.likesPage,
              arguments: {'post': state.specificPostModel},
            );
          },
          withClickOnProfile: false,
          onDeletePost: () {
            Navigator.pop(context, widget.postId);
          },
          onEditPost: () {
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              AppScreens.editPostPage,
              arguments: {'post': state.specificPostModel},
            ).then((value) {
              if (value != null && (value as Map)['updatedPost'] != null) {
                // state.specificPostModel = ;
                // BlocProvider.of<HomeBloc>(context).onEditPost(
                //   (value)['updatedPost'] as PostModel,
                //   index,
                // );
                setState(() {});
              }
            });
          },
          isDeleting: false,
        ),
      );
    }
  }
}
