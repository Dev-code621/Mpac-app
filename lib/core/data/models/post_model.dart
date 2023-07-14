import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/data/models/media_model.dart';
import 'package:mpac_app/core/data/models/reation_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'dart:async';

class PostModelTest {
  final int id;
  final String image;
  final String name;
  final String username;
  final String sport;
  final String commentsNum;
  final String likesNum;
  final String reaction;
  final String desc;

  PostModelTest(
      {required this.id,
      required this.image,
      required this.username,
      required this.sport,
      required this.name,
      required this.commentsNum,
      required this.likesNum,
      required this.reaction,
      required this.desc,});

  factory PostModelTest.fromJson(Map<String, dynamic> json) {
    return PostModelTest(
      id: json['id'],
      image: json['image'],
      desc: json['description'],
      username: json['username'],
      sport: json['sport'],
      name: json['name'],
      commentsNum: json['comments'],
      likesNum: json['likes'],
      reaction: json['reaction'],
    );
  }
}

class PostModel {
  final String id;
  final String description;
  final bool isPublished;
  final String ownerId;
  final String createdAt;
  final String? sport;
  final List<MediaModel> medias;
  final UserModel owner;
  int reactionsCount;
  int commentsCount;
  ReactionModel? userReaction;
  final List<CommentModel> recentComments;

  int currentFocusedIndex = 0;

  bool showReactions = false;
  bool isDeleting = false;

  PostModel(
      {required this.id,
      required this.description,
      required this.sport,
      required this.isPublished,
      required this.ownerId,
      required this.medias,
      required this.owner,
      required this.createdAt,
      required this.reactionsCount,
      required this.recentComments,
      required this.commentsCount,
      required this.userReaction,});

  StreamController<Map<String, dynamic>> streamer = StreamController<Map<String, dynamic>>.broadcast();


  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      description: json['description'],
      sport: json['sport'],
      commentsCount: json['comments_count'],
      reactionsCount: json['reactions_count'],
      isPublished: json['is_published'],
      medias: getMedias(json['media']),
      owner: UserModel.fromJson(json['user']),
      recentComments: json['recent_comments'] == null
          ? []
          : getRecentComments(json['recent_comments']),
      ownerId: json['user_id'],
      userReaction: json['current_user_reaction'] == null
          ? null
          : ReactionModel.fromJson(json['current_user_reaction']),
      createdAt: json['created_at'],
    );
  }

  static List<CommentModel> getRecentComments(json) {
    List<CommentModel> comments = [];
    for (var item in json) {
      comments.add(CommentModel.fromJson(item));
    }

    return comments;
  }

  static List<MediaModel> getMedias(json) {
    List<MediaModel> medias = [];
    for (var item in json) {
      medias.add(MediaModel.fromJson(item));
    }
    return medias;
  }
}
