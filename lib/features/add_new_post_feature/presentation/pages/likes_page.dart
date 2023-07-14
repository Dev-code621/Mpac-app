import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_bloc.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_state.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/widgets/like_widget.dart';
import 'package:sizer/sizer.dart';

class LikesPage extends StatefulWidget {
  final PostModel postModel;
  const LikesPage({required this.postModel, Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  final _bloc = getIt<AddPostBloc>();
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _bloc.onGetPostLikes(widget.postModel.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, AddPostState state) {
        return Scaffold(
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
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: const Color(0xffB7B7B7),
                                size: context.h * 0.025,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "${localizations.likes} - ${widget.postModel.reactionsCount}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: getLikesWidget(state)),
            ],
          ),
        );
      },
    );
  }

  Widget getLikesWidget(AddPostState state) {
    if (state.isLoadingLikes) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () {
          _bloc.onGetPostLikes(widget.postModel.id);
          return Future.value(true);
        },
        child: ListView.builder(
          itemCount: state.reactions.length,
          itemBuilder: (BuildContext context, int index) {
            (index == state.reactions.length - 1 &&
                    state.reactions.length > 14 &&
                    state.canLoadMore)
                ? _bloc.onGetMoreLikes(widget.postModel.id)
                : print('');
            return LikeWidget(
              reactionModel: state.reactions[index],
            );
          },
        ),
      );
    }
  }
}
