import 'package:flutter/material.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/add_post_page.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/comments_page.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/complete_add_post_page.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/likes_page.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/page/forget_password_page.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/page/otp_verification_page.dart';
import 'package:mpac_app/features/authentication_features/sign_in_feature/presentation/page/sign_in_page.dart';
import 'package:mpac_app/features/authentication_features/sign_up_feature/presentation/pages/sign_up_page.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/pages/edit_post_page.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/page/holder_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/followings_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/post_information_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/profile_page.dart';
import 'package:mpac_app/features/my_account_feature/presentation/pages/follow_and_invite_page.dart';
import 'package:mpac_app/features/my_account_feature/presentation/pages/my_account_page.dart';
import 'package:mpac_app/features/my_players_feature/presentation/pages/my_player_information_page.dart';
import 'package:mpac_app/features/my_players_feature/presentation/pages/my_players_page.dart';
import 'package:mpac_app/features/notifications_feature/presentation/pages/notifications_page.dart';
import 'package:mpac_app/features/onboarding_features/get_started_feature/presentation/page/get_started_page.dart';
import 'package:mpac_app/features/onboarding_features/onboarding_steps_feature/presentation/page/onboarding_steps_page.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/pages/splash_page.dart';
import 'package:mpac_app/features/search_feature/presentation/pages/search_page.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/page/select_your_profile_page.dart';
import 'package:mpac_app/features/sport_selection_feature/presentation/page/sport_selection_page.dart';

class ScreenGenerator {
  static Route<dynamic> onGenerate(RouteSettings value) {
    String? name = value.name;
    final args = value.arguments;
    switch (name) {
      case AppScreens.getStartedPage:
        return MaterialPageRoute(builder: (context) => const GetStartedPage());
      case AppScreens.onBoardingSteps:
        return MaterialPageRoute(
          builder: (context) => const OnBoardingStepsPage(),
        );
      case AppScreens.signInPage:
        return MaterialPageRoute(builder: (context) => const SignInPage());
      case AppScreens.signUpPage:
        return MaterialPageRoute(builder: (context) => const SignUpPage());
      case AppScreens.forgetPasswordPage:
        return MaterialPageRoute(
          builder: (context) => const ForgetPasswordPage(),
        );
      case AppScreens.otpVerificationPage:
        return MaterialPageRoute(
          builder: (context) => OTPVerificationPage((args as Map)['viewType']),
        );
      case AppScreens.createProfilePage:
        return MaterialPageRoute(
          builder: (context) => CreateProfilePage(
            viewType: (args as Map)['viewType'],
          ),
        );
      case AppScreens.sportSelectionPage:
        return MaterialPageRoute(
          builder: (context) => SportSelectionPage(
            viewType: (args as Map)['viewType'],
            profileType: (args)['profileType'],
          ),
        );
      case AppScreens.selectYourProfilePage:
        return MaterialPageRoute(
          builder: (context) => const SelectYourProfilePage(),
        );
      case AppScreens.holderPage:
        return MaterialPageRoute(builder: (context) => const HolderPage());
      case AppScreens.notificationsPage:
        return MaterialPageRoute(
          builder: (context) => const NotificationsPage(),
        );
      case AppScreens.searchPage:
        return MaterialPageRoute(builder: (context) => const SearchPage());
      case AppScreens.commentsPage:
        return MaterialPageRoute(
          builder: (context) => CommentsPage(
            postId: (args as Map)['postId'],
            commentsCount: (args)['commentsCount'],
          ),
        );
      case AppScreens.myAccountPage:
        return MaterialPageRoute(builder: (context) => const MyAccountPage());
      case AppScreens.followAndInvitePage:
        return MaterialPageRoute(
          builder: (context) => const FollowAndInvitePage(),
        );
      case AppScreens.editProfilePage:
        return MaterialPageRoute(builder: (context) => const EditProfilePage());
      case AppScreens.myPlayersPage:
        return MaterialPageRoute(builder: (context) => const MyPlayersPage());
      case AppScreens.myPlayerInformationPage:
        return MaterialPageRoute(
          builder: (context) => const MyPlayerInformationPage(),
        );
      case AppScreens.addNewPostPage:
        return MaterialPageRoute(builder: (context) => const AddPostPage());
      case AppScreens.completeAddPostPage:
        return MaterialPageRoute(
          builder: (context) => CompleteAddPostPage(
            bloc: (args as Map)['bloc'],
            controllers: (args)['controllers'],
          ),
        );
      case AppScreens.splashPage:
        return MaterialPageRoute(builder: (context) => const SplashPage());
      case AppScreens.followingsPage:
        return MaterialPageRoute(
          builder: (context) => FollowingsPage(
            userId: (args as Map)['userId'],
            type: (args)['type'],
          ),
        );
      case AppScreens.profilePage:
        return MaterialPageRoute(
          builder: (context) => ProfilePage(
            profileId: (args as Map)['profile_id'],
            withAppBar: (args)['withAppBar'],
            flowCalled: (args)['flowCalled'],
            holderBloc: getIt<HolderBloc>(),
          ),
        );
      case AppScreens.postInformationPage:
        return MaterialPageRoute(
          builder: (context) => PostInformationPage(
            postId: (args as Map)['postId'],
          ),
        );
      case AppScreens.likesPage:
        return MaterialPageRoute(
          builder: (context) => LikesPage(
            postModel: (args as Map)['post'],
          ),
        );
      case AppScreens.editPostPage:
        return MaterialPageRoute(
          builder: (context) => EditPostPage(
            post: (args as Map)['post'],
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: const Center(
            child: Text('ERROR'),
          ),
        );
      },
    );
  }
}

class AppScreens {
  static const String getStartedPage = "/get_started_page";
  static const String splashPage = "/splash_page";
  static const String onBoardingSteps = "/on_boarding_steps_page";
  static const String signInPage = "/sign_in_page";
  static const String signUpPage = "/sign_up_page";
  static const String otpVerificationPage = "/otp_verification_page";
  static const String forgetPasswordPage = "/forget_password_page";
  static const String createProfilePage = "/create_profile_page";
  static const String sportSelectionPage = "/sports_selection_page";
  static const String selectYourProfilePage = "/select_your_profile_page";
  static const String holderPage = "/holder_page";
  static const String notificationsPage = "/notifications_page";
  static const String searchPage = "/search_page";
  static const String commentsPage = "/comments_page";
  static const String myAccountPage = "/my_account_page";
  static const String followAndInvitePage = "/follow_and_invite_page";
  static const String editProfilePage = "/edit_profile_page";
  static const String myPlayersPage = "/my_players_page";
  static const String myPlayerInformationPage = "/my_players_information_page";
  static const String addNewPostPage = "/add_new_post_page";
  static const String completeAddPostPage = "/complete_add_post_page";
  static const String profilePage = "/profile_page";
  static const String followingsPage = "/followings_page";
  static const String postInformationPage = "/post_information_page";
  static const String likesPage = "/likes_page";
  static const String editPostPage = "/edit_post_page";
}
