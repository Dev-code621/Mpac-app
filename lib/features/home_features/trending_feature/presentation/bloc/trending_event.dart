
abstract class TrendingEvent {}

class GetTrendingPosts extends TrendingEvent {
  final bool? withLoading;

  GetTrendingPosts(this.withLoading);
}

class ClearFailures extends TrendingEvent {}

class DeletePost extends TrendingEvent {
  final String id;

  DeletePost(this.id);
}

class LikingPost extends TrendingEvent {
  final String id;
  final String type;
  final int index;

  LikingPost(this.id, this.type, this.index);
}
class DisLikingPost extends TrendingEvent {
  final String id;
  final String type;
  final int index;


  DisLikingPost(this.id, this.type, this.index);
}

class UpdatePostCommentsNum extends TrendingEvent {
  final int index;
  final int commentsCount;

  UpdatePostCommentsNum(this.index, this.commentsCount);
}

class GetMorePosts extends TrendingEvent {
}