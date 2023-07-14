import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/data/models/settings_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_bloc.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_state.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/widgets/comment_widget.dart';
import 'package:sizer/sizer.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String commentsCount;

  const CommentsPage({
    required this.postId,
    required this.commentsCount,
    Key? key,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late AppLocalizations localizations;
  TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  final _bloc = getIt<AddPostBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _bloc.onGetPostComments(widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, AddPostState state) {
        if (state.commentPosted) {
          _commentController = TextEditingController(text: "");
          _bloc.onClearFailures();
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, AddPostState state) {
          return WillPopScope(
            onWillPop: () {
              Navigator.pop(
                context,
                {'comments_length': state.comments.length},
              );
              return Future.value(false);
            },
            child: Scaffold(
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
                                Navigator.pop(
                                  context,
                                  {'comments_length': state.comments.length},
                                );
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
                              "${localizations.comments} - ${state.comments.length}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimensions.checkKIsWeb(context)
                                    ? context.h * 0.032
                                    : 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: getCommentsWidget(state)),
                  getCommentFocusWidget(state),
                  checkTextFieldWidgetAvailable(state)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget checkTextFieldWidgetAvailable(state) {
    List<SettingsModel> commentPermissions = getIt<PrefsHelper>()
        .getUserSettings()
        .where(
          (element) =>
              (element.key == "comments_status" && element.value == "enabled"),
        )
        .toList();
    bool isSuperUser = getIt<PrefsHelper>().userInfo().isSuperUser == null
        ? false
        : getIt<PrefsHelper>().userInfo().isSuperUser!;

    return (commentPermissions.isNotEmpty ||
            (commentPermissions.isEmpty && isSuperUser))
        ? getTextFieldWidget(state)
        : Container();
  }

  Widget getCommentsWidget(AddPostState state) {
    if (state.isGettingComments) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    /*else if (state.errorSubmittingPost) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            _bloc.onGetPostComments(widget.postId);
          },
          message: "Error loading comments!",
          btnContent: localizations.retry,
        ),
      );
    } else if (state.comments.isEmpty) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            _bloc.onGetPostComments(widget.postId);
          },
          message: "No comments found!",
          btnContent: localizations.retry,
        ),
      );
    } */

    else {
      return RefreshIndicator(
        onRefresh: () {
          _bloc.onGetPostComments(widget.postId);
          return Future.value(true);
        },
        child: ListView.builder(
          itemCount: state.comments.length,
          itemBuilder: (BuildContext context, int index) {
            (index == state.comments.length - 1 &&
                    state.comments.length > 14 &&
                    state.canLoadMore)
                ? _bloc.onGetMoreComments(widget.postId)
                : print('');
            return CommentWidget(
              commentModel: state.comments[index],
              onLongPress: (CommentModel comment) {
                String uid = getIt<PrefsHelper>().getUserId;
                if (comment.owner.id == uid || uid == widget.postId) {
                  commentBottomSheet(
                    context,
                    context.h,
                    context.w,
                    comment,
                    uid != widget.postId,
                  );
                }
              },
            );
          },
        ),
      );
    }
  }

  commentBottomSheet(
    context,
    double height,
    double width,
    CommentModel comment,
    bool withDeleteComment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      builder: (BuildContext bc) {
        return SizedBox(
          height: height * 0.3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 12,
                  width: width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: Text(
                  'Edit this comment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.028
                        : 12.sp,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _bloc.onFocusOnComment(comment);
                  _commentFocusNode.requestFocus();
                  _commentController =
                      TextEditingController(text: comment.comment);
                },
              ),
              withDeleteComment
                  ? ListTile(
                      leading: const Icon(Icons.delete, color: Colors.white),
                      title: Text(
                        'Delete this comment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.checkKIsWeb(context)
                              ? context.h * 0.028
                              : 12.sp,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        deleteAccountDialog(context, () {
                          _bloc.onDeleteComment(
                            postId: widget.postId,
                            commentId: comment.id,
                          );
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  Widget getCommentFocusWidget(AddPostState state) {
    return state.focusedCommentForEdit == null
        ? Container()
        : Container(
            width: context.w,
            height: context.h * 0.05,
            color: AppColors.secondaryBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      _bloc.onCancelCommentFocus();
                      _commentController = TextEditingController(text: "");
                      _commentFocusNode.unfocus();
                    },
                    child: const Text(
                      "cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget getTextFieldWidget(AddPostState state) {
    return Container(
      width: context.w,
      height: context.h * 0.1,
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: [BoxShadow(offset: Offset(0, 0), blurRadius: 5)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Container(
              width: context.w * 0.1,
              height: Dimensions.checkKIsWeb(context)
                  ? context.h * 0.08
                  : context.w * 0.1,
              decoration: getIt<PrefsHelper>().userInfo().image == null
                  ? BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      shape: BoxShape.circle,
                    )
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          getIt<PrefsHelper>().userInfo().image!,
                        ),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
              child: getIt<PrefsHelper>().userInfo().image == null
                  ? Icon(
                      Icons.person,
                      color: Colors.grey.withOpacity(0.5),
                      size: Dimensions.checkKIsWeb(context)
                          ? context.h * 0.04
                          : 20,
                    )
                  : Container(),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                maxLines: 1,
                focusNode: _commentFocusNode,
                controller: _commentController,
                keyboardType: TextInputType.name,
                onChanged: (val) {
                  _bloc.onChangeCommentStr(val);
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: Dimensions.checkKIsWeb(context)
                      ? context.h * 0.028
                      : 13.sp, // 8
                  color: AppColors.textFieldColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: localizations.write_new_comment,
                  hintStyle: TextStyle(
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.028
                        : 13.sp,
                    color: AppColors.hintTextFieldColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                if (!state.isPostingComment) {
                  if (state.focusedCommentForEdit == null) {
                    _commentFocusNode.unfocus();
                    _bloc.onSubmitNewComment(
                      postId: widget.postId,
                      isEdit: false,
                    );
                  } else {
                    _commentFocusNode.unfocus();
                    _bloc.onSubmitNewComment(
                      postId: widget.postId,
                      isEdit: true,
                      commentId: state.focusedCommentForEdit!.id,
                    );
                  }
                }
              },
              child: state.isPostingComment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.5,
                      ),
                    )
                  : Text(
                      localizations.post,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.026
                            : 11.sp,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> deleteAccountDialog(
    BuildContext context,
    Function onSubmit, {
    Color? color,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackgroundColor,
          title: Text(
            "Delete Comment",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this comment?",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w200,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  color: AppColors.hintTextFieldColor,
                  fontSize: 13.sp,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 13.sp,
                ),
              ),
              onPressed: () {
                onSubmit();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
