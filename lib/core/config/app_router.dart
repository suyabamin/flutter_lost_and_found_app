import 'package:go_router/go_router.dart';

import '../../features/splash_screen/splash_screen.dart';
import '../../features/splash_screen_animated/splash_screen_animated.dart';
import '../../features/welcome_auth/welcome_auth_screen.dart';
import '../../features/welcome_auth_animated/welcome_auth_animated_screen.dart';
import '../../features/login/login_screen.dart';
import '../../features/register/register_screen.dart';
import '../../features/forgot_password/forgot_password_screen.dart';
import '../../features/otp_verification/otp_verification_screen.dart';
import '../../features/onboarding_flow/onboarding_flow_screen.dart';
import '../../features/home_dashboard/home_dashboard_screen.dart';
import '../../features/home_dashboard_animated/home_dashboard_animated_screen.dart';

import '../../features/search/ai_smart_search_screen.dart';
import '../../features/search/search_results_screen.dart';
import '../../features/ai/ai_image_scan_screen.dart';
import '../../features/ai/ai_match_results_screen.dart';
import '../../features/ai/ai_match_results_animated_screen.dart';

import '../../features/posts/create_lost_post_step_1_screen.dart';
import '../../features/posts/preview_publish_report_screen.dart';
import '../../features/posts/item_details_screen.dart';
import '../../features/posts/my_posts_screen.dart';
import '../../features/posts/edit_post_screen.dart';
import '../../features/posts/submit_claim_screen.dart';
import '../../features/posts/claim_details_screen.dart';

import '../../features/maps/google_map_view_screen.dart';
import '../../features/maps/select_location_screen.dart';

import '../../features/recovery/recovery_completed_screen.dart';
import '../../features/recovery/reward_payment_screen.dart';
import '../../features/recovery/reward_success_screen.dart';
import '../../features/recovery/rating_screen.dart';
import '../../features/recovery/recovery_history_screen.dart';
import '../../features/recovery/wallet_screen.dart';
import '../../features/recovery/leaderboard_screen.dart' as recovery_lb;

import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_conversation_screen.dart';

import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/favorites_screen.dart';
import '../../features/profile/history_screen.dart';
import '../../features/profile/rewards_wallet_screen.dart';

import '../../features/verification/nid_verification_screen.dart';
import '../../features/verification/police_gd_integration_screen.dart';

import '../../features/dashboards/admin_dashboard_screen.dart';
import '../../features/dashboards/university_dashboard_screen.dart';
import '../../features/dashboards/office_dashboard_screen.dart';
import '../../features/dashboards/admin_reports_screen.dart';

import '../../features/settings/settings_screen.dart';
import '../../features/settings/help_center_screen.dart';
import '../../features/settings/privacy_terms_screen.dart';
import '../../features/settings/app_states_empty_offline_screen.dart';
import '../../features/settings/shader_screen.dart';
import '../../features/settings/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/splash-animated',
      builder: (context, state) => const SplashScreenAnimatedScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeAuthScreen(),
    ),
    GoRoute(
      path: '/welcome-animated',
      builder: (context, state) => const WelcomeAuthAnimatedScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/home-animated',
      builder: (context, state) => const HomeDashboardAnimatedScreen(),
    ),

    GoRoute(
      path: '/ai-search',
      builder: (context, state) => const AiSmartSearchScreen(),
    ),
    GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'] ?? '';
        final category = state.uri.queryParameters['category'] ?? 'All';
        return SearchResultsScreen(query: query, category: category);
      },
    ),
    GoRoute(
      path: '/ai-scan',
      builder: (context, state) => const AiImageScanScreen(),
    ),
    GoRoute(
      path: '/ai-matches',
      builder: (context, state) => const AiMatchResultsScreen(),
    ),
    GoRoute(
      path: '/ai-matches-animated',
      builder: (context, state) => const AiMatchResultsAnimatedScreen(),
    ),

    GoRoute(
      path: '/create-post-step1',
      builder: (context, state) => const CreateLostPostStep1Screen(),
    ),
    GoRoute(
      path: '/preview-report',
      builder: (context, state) => PreviewPublishReportScreen(
        postData: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/item-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '1';
        return ItemDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '/submit-claim/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId'] ?? '1';
        return SubmitClaimScreen(postId: postId);
      },
    ),
    GoRoute(
      path: '/claim-details/:claimId',
      builder: (context, state) {
        final claimId = state.pathParameters['claimId'] ?? '1';
        return ClaimDetailsScreen(claimId: claimId);
      },
    ),
    GoRoute(
      path: '/my-posts',
      builder: (context, state) => const MyPostsScreen(),
    ),
    GoRoute(
      path: '/edit-post/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EditPostScreen(postId: id);
      },
    ),

    GoRoute(
      path: '/map-view',
      builder: (context, state) => const GoogleMapViewScreen(),
    ),
    GoRoute(
      path: '/select-location',
      builder: (context, state) => SelectLocationScreen(
        initialLocation: state.uri.queryParameters['initial'],
      ),
    ),

    GoRoute(
      path: '/chats',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '1';
        return ChatConversationScreen(id: id);
      },
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardsWalletScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const recovery_lb.LeaderboardScreen(),
    ),

    // Recovery & Payment Routes
    GoRoute(
      path: '/recovery-completed/:claimId',
      builder: (context, state) {
        final claimId = state.pathParameters['claimId'] ?? '';
        return RecoveryCompletedScreen(claimId: claimId);
      },
    ),
    GoRoute(
      path: '/reward-payment/:claimId',
      builder: (context, state) {
        final claimId = state.pathParameters['claimId'] ?? '';
        return RewardPaymentScreen(claimId: claimId);
      },
    ),
    GoRoute(
      path: '/reward-success/:paymentId',
      builder: (context, state) {
        final paymentId = state.pathParameters['paymentId'] ?? '';
        return RewardSuccessScreen(paymentId: paymentId);
      },
    ),
    GoRoute(
      path: '/rating/:claimId',
      builder: (context, state) {
        final claimId = state.pathParameters['claimId'] ?? '';
        return RatingScreen(claimId: claimId);
      },
    ),
    GoRoute(
      path: '/recovery-history',
      builder: (context, state) => const RecoveryHistoryScreen(),
    ),
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),

    GoRoute(
      path: '/nid-verification',
      builder: (context, state) => const NidVerificationScreen(),
    ),
    GoRoute(
      path: '/police-gd',
      builder: (context, state) => const PoliceGdIntegrationScreen(),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-reports',
      builder: (context, state) => const AdminReportsScreen(),
    ),
    GoRoute(
      path: '/university-dashboard',
      builder: (context, state) => const UniversityDashboardScreen(),
    ),
    GoRoute(
      path: '/office-dashboard',
      builder: (context, state) => const OfficeDashboardScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/privacy-terms',
      builder: (context, state) => const PrivacyTermsScreen(),
    ),
    GoRoute(
      path: '/empty-offline',
      builder: (context, state) => const AppStatesEmptyOfflineScreen(),
    ),
    GoRoute(path: '/shader', builder: (context, state) => const ShaderScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
