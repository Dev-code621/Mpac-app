import 'package:mpac_app/core/data/models/post_model.dart';

abstract class HomeEvent {}

class GetFeedPosts extends HomeEvent {
  final bool withLoading;

  GetFeedPosts(this.withLoading);
}

class ClearFailures extends HomeEvent {}
class GetMorePosts extends HomeEvent {}

class DeletePost extends HomeEvent {
  final String id;
  final int index;

  DeletePost(this.id, this.index);
}

class EditPost extends HomeEvent {
  final PostModel post;
  final int index;

  EditPost(this.post, this.index);
}

class ChangingPosition extends HomeEvent {
  final Duration duration;
  final int index;
  final int mediaIndex;

  ChangingPosition(
      {required this.duration, required this.index, required this.mediaIndex,});
}

class LoadingVideo extends HomeEvent {
  final bool status;
  final int index;
  final int mediaIndex;

  LoadingVideo(
      {required this.status, required this.index, required this.mediaIndex,});
}

class LikingPost extends HomeEvent {
  final String id;
  final String type;
  final int index;

  LikingPost(this.id, this.type, this.index);
}

class DisLikingPost extends HomeEvent {
  final String id;
  final String type;
  final int index;

  DisLikingPost(this.id, this.type, this.index);
}

class LoadVideo extends HomeEvent {
  final String url;

  LoadVideo(this.url);
}
