import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String baseURL = dotenv.get('BASE_URL');

  static String signIn = "$baseURL/auth/login";
  static String sendBirdId = "$baseURL/settings/send-bird-id";
  static String firebaseSignIn = "$baseURL/auth/google-token-login";
  static String jwtCheck = "$baseURL/auth/check-token";
  static String signUp = "$baseURL/auth/register";

  static String generateSendbirdToken = "$baseURL/profile/chat-token";

  static String sports = "$baseURL/sports";
  static String profileSports = "$baseURL/profile/sports";

  static String users = "$baseURL/users";

  static String user(String id) => "$baseURL/users/$id";

  static String userPosts(String userId) => "$baseURL/users/$userId/posts";

  static String followUser(String userId) => "$baseURL/users/$userId/follow";

  static String unfollowUser(String userId) =>
      "$baseURL/users/$userId/un-follow";

  static String usersFollowers(String userId) =>
      "$baseURL/users/$userId/followers";

  static String usersFollowings(String userId) =>
      "$baseURL/users/$userId/followings";

  static String countries = "$baseURL/countries";

  static String states(String name) => "$baseURL/countries/$name";

  static String profile = "$baseURL/profile";
  static String profileFollowers = "$baseURL/profile/followers";
  static String profileFollowings = "$baseURL/profile/followings";
  static String profilePosts = "$baseURL/profile/posts";
  static String profileVerifyEmail = "$baseURL/profile/verify-email";
  static String profileVerifyMobile = "$baseURL/profile/verify-mobile";

  static String posts = "$baseURL/posts";

  static String postReactions(String postId) =>
      "$baseURL/posts/$postId/reactions";

  static String postComments(String postId) =>
      "$baseURL/posts/$postId/comments";

  static String editPostComment({
    required String postId,
    required String commentId,
  }) =>
      "$baseURL/posts/$postId/comments/$commentId";

  static String deletePostComment({
    required String postId,
    required String commentId,
  }) =>
      "$baseURL/posts/$postId/comments/$commentId";

  static String notifications = '$baseURL/profile/notifications';
  static String markAllAsReadNotifications =
      '$baseURL/profile/notifications/read-all';

  static String markAsReadNotification(String id) =>
      '$baseURL/profile/notifications/$id';

  static String resetPassword = "$baseURL/auth/reset-password";
  static String requestResetPassword = "$baseURL/auth/request-reset-password";

  static String resendOTPCode = "$baseURL/profile/resend-email-verification";

  static String profileMedias({
    required String userId,
    required String type,
    required String sport,
    required int offset,
    required int limit,
  }) =>
      sport.toLowerCase() == "general"
          ? "$baseURL/users/$userId/media?type=$type&offset=$offset&limit=$limit"
          : "$baseURL/users/$userId/media?type=$type&sport=$sport&offset=$offset&limit=$limit";

  static String settings = "$baseURL/settings";

  static String deleteMedia(String postId, String mediaId) =>
      "$baseURL/posts/$postId/media/$mediaId";

  static String orderMedia(String postId, String mediaId) =>
      " /posts/$postId/media/$mediaId/order";
}
