# Project Structure & Implementation Details: Flutter Lost & Found BD

This document provides a comprehensive breakdown of the application architecture, directory layout, models, services, providers, widgets, screens, and routing system of the **Flutter Lost & Found BD** application.

---

## 1. Project Root Directory Structure

```text
d:\flutter_lost_and_found\
├── .env                              # Cloudinary & environment configuration
├── .gitignore                        # Git ignore patterns
├── README.md                         # Project overview
├── analysis_options.yaml             # Dart linter and analyzer rules
├── android/                          # Native Android platform project
├── firebase.json                     # Firebase tools configuration
├── firestore.indexes.json            # Firestore database composite index definitions
├── firestore.rules                   # Firestore database security rules
├── ios/                              # Native iOS platform project
├── lib/                              # Primary Flutter application code base
├── linux/                            # Native Linux platform project
├── macos/                            # Native macOS platform project
├── progress.md                       # Task progress and tracking log
├── pubspec.yaml                      # Dependencies, assets, and project metadata
├── storage.rules                     # Firebase Storage security rules
├── test/                             # Automated test suites
├── usermanual.md                     # Application user guide
├── web/                              # Native Web platform project
└── windows/                          # Native Windows platform project
```

---

## 2. Lib Directory Structure

```text
lib/
├── firebase_options.dart             # Auto-generated Firebase initialization options
├── main.dart                         # Main entry point of the Flutter application
├── core/                             # Shared utilities, configurations, and core logic
│   ├── config/
│   │   └── app_router.dart           # GoRouter route definitions and navigation system
│   ├── models/                       # Data transfer objects and entity models
│   │   ├── campus_models.dart        # CampusModel and CampusMemberModel
│   │   ├── chat_model.dart          # ChatRoomModel and ChatMessageModel
│   │   ├── claim_model.dart         # ClaimModel for item ownership claims
│   │   ├── post_model.dart          # PostModel for lost/found item listings
│   │   ├── recovery_models.dart     # RatingModel, PaymentModel, HistoryModel, WalletModel
│   │   └── user_model.dart          # UserModel for platform user profiles
│   ├── providers/                    # Riverpod state providers and StateNotifiers
│   │   ├── location_dashboard_provider.dart # Live location tracking & radius search state
│   │   └── providers.dart           # Global services, auth, posts, and campus providers
│   ├── services/                     # Application services (Firebase, Cloudinary)
│   │   ├── auth_service.dart        # Firebase Auth wrapper (Email, Google, Phone OTP)
│   │   ├── cloudinary_service.dart  # Cloudinary image upload service with Base64 fallback
│   │   └── firestore_service.dart   # Firestore CRUD, real-time streams & local cache
│   ├── theme/                        # Application color palette and theme configurations
│   │   ├── app_colors.dart          # Color constants, glassmorphism tints & gradients
│   │   └── app_theme.dart           # Light and dark ThemeData setups
│   ├── utils/                        # General utility functions
│   │   └── location_utils.dart      # Haversine distance calculation and formatting
│   └── widgets/                      # Shared reusable UI components
│       ├── app_image.dart           # Multi-source image rendering (Bytes/Base64/Network)
│       ├── category_chip.dart       # Animated category filter chip
│       ├── custom_text_field.dart   # Custom styled text form input field
│       ├── glass_container.dart     # Glassmorphism container with backdrop blur
│       ├── live_location_card.dart  # Real-time GPS location status & control card
│       ├── primary_button.dart      # Custom gradient action button
│       ├── radius_search_card.dart  # Map radius search slider and sorting control card
│       └── stat_card.dart           # Dashboard metric display card
└── features/                         # Modular feature screens and flows
    ├── ai/                           # AI image scan & visual match screens
    ├── chat/                         # Real-time 1-on-1 chat conversation & list
    ├── dashboards/                   # Role-based dashboards (Admin, Campus, Office)
    ├── forgot_password/             # Password reset flow
    ├── home/                         # General home sub-features (Leaderboard)
    ├── home_dashboard/               # Primary user feed and main home dashboard
    ├── home_dashboard_animated/      # Animated variation of home dashboard
    ├── login/                        # User sign-in screen
    ├── maps/                         # Map view and interactive location selection
    ├── notifications/                # User notifications list screen
    ├── onboarding_flow/              # First-time user onboarding carousel
    ├── otp_verification/             # Phone OTP verification screen
    ├── posts/                        # Create post, preview, item details, claims
    ├── profile/                      # User profile, edit profile, rewards, favorites
    ├── recovery/                     # Recovery completion, ratings, payments, history, wallet
    ├── register/                     # New user sign-up screen
    ├── search/                       # AI smart search, search results, radius search
    ├── settings/                     # Settings, Help center, Privacy terms, About
    ├── splash_screen/                # App initialization splash screen
    ├── splash_screen_animated/       # Animated variation of splash screen
    ├── verification/                 # NID verification & Police GD integration
    ├── welcome_auth/                 # Landing screen with login/register/guest options
    └── welcome_auth_animated/        # Animated variation of welcome auth screen
```

---

## 3. Screen Structure (`lib/features/`)

The user interface is organized into feature-based screen directories:

### 3.1 Authentication & Onboarding Screens
* `splash_screen/splash_screen.dart`: App startup logic checking authentication state to route to `/welcome` or `/home`.
* `splash_screen_animated/splash_screen_animated.dart`: Animated splash screen alternative (`/splash-animated`).
* `welcome_auth/welcome_auth_screen.dart`: Entry landing page offering Sign In, Sign Up, and Guest mode.
* `welcome_auth_animated/welcome_auth_animated_screen.dart`: Animated landing screen variation (`/welcome-animated`).
* `onboarding_flow/onboarding_flow_screen.dart`: Multi-step onboarding introduction carousel (`/onboarding`).
* `login/login_screen.dart`: User login with email/password and Google Sign-In button (`/login`).
* `register/register_screen.dart`: Account registration form capturing user details (`/register`).
* `forgot_password/forgot_password_screen.dart`: Password reset request via email (`/forgot-password`).
* `otp_verification/otp_verification_screen.dart`: SMS OTP code input and verification screen (`/otp-verify`).

### 3.2 Dashboard & Feed Screens
* `home_dashboard/home_dashboard_screen.dart`: Primary user interface showing lost/found posts feed, category filter chips, search bar, map toggle, and navigation drawer (`/home`).
* `home_dashboard_animated/home_dashboard_animated_screen.dart`: Animated variation of main dashboard (`/home-animated`).
* `home/leaderboard_screen.dart`: Public user leaderboard showcasing top contributors (`/leaderboard`).

### 3.3 Posts & Claim Workflow Screens
* `posts/create_lost_post_step_1_screen.dart`: Post creation form for lost/found items including category, title, description, location, reward, and images (`/create-post-step1`).
* `posts/preview_publish_report_screen.dart`: Final preview screen before publishing post to Firestore (`/preview-report`).
* `posts/item_details_screen.dart`: Comprehensive item details screen showing images, poster profile, status, map location, and "Claim Item" trigger (`/item-details/:id`).
* `posts/my_posts_screen.dart`: User's personal manage-posts screen to track active/resolved items (`/my-posts`).
* `posts/submit_claim_screen.dart`: Form for claimers to submit ownership proof, address, contact, and reward request (`/submit-claim/:postId`).
* `posts/claim_details_screen.dart`: Claim management screen for post owners to accept/reject claims and coordinate handover with live GPS sharing (`/claim-details/:claimId`).

### 3.4 Search & AI Match Screens
* `search/ai_smart_search_screen.dart`: AI-assisted search screen allowing natural language query input (`/ai-search`).
* `search/search_results_screen.dart`: Search results listing screen with category filtering (`/search-results`).
* `search/radius_search_screen.dart`: Map radius search screen for finding lost/found items nearby (`/radius-search`).
* `ai/ai_image_scan_screen.dart`: Camera/gallery image scanner utilizing Google ML Kit / Gemini AI to analyze item photos (`/ai-scan`).
* `ai/ai_match_results_screen.dart`: Displays posts matching the scanned item photo ranked by similarity score (`/ai-matches`).
* `ai/ai_match_results_animated_screen.dart`: Animated variation for AI match loading/results (`/ai-matches-animated`).

### 3.5 Messaging & Chat Screens
* `chat/chat_list_screen.dart`: List of active 1-on-1 chat conversations linked to approved claims (`/chats`).
* `chat/chat_conversation_screen.dart`: Real-time chat interface with messaging, photo sharing, read receipts, and live location sharing toggle (`/chat/:id`).

### 3.6 Profile & Account Screens
* `profile/profile_screen.dart`: User profile view showcasing stats, trust score, NID verification badge, and reviews (`/profile`).
* `profile/edit_profile_screen.dart`: Screen to edit user display name, phone, location, and avatar (`/edit-profile`).
* `profile/favorites_screen.dart`: Saved/bookmarked posts collection screen (`/favorites`).
* `profile/history_screen.dart`: User's activity history timeline (`/history`).
* `profile/rewards_wallet_screen.dart`: User reward points wallet and redemption view (`/rewards`).

### 3.7 Recovery, Rating & Payment Screens
* `recovery/recovery_completed_screen.dart`: Handover completion screen for dual confirmation from owner and finder (`/recovery-completed/:claimId`).
* `recovery/reward_payment_screen.dart`: Mobile wallet payment interface supporting bKash, Nagad, and Rocket (`/reward-payment/:claimId`).
* `recovery/reward_success_screen.dart`: Payment confirmation screen (`/reward-success/:paymentId`).
* `recovery/rating_screen.dart`: Post-recovery feedback form for rating user behavior, communication, trustworthiness, and response time (`/rating/:claimId`).
* `recovery/recovery_history_screen.dart`: Platform-wide list of successfully recovered items (`/recovery-history`).
* `recovery/wallet_screen.dart`: Financial wallet screen tracking today, monthly, and lifetime earnings (`/wallet`).
* `recovery/leaderboard_screen.dart`: Leaderboard highlighting community member rankings.

### 3.8 Maps & Location Selection Screens
* `maps/google_map_view_screen.dart`: Full-screen Google Maps display of lost and found post markers (`/map-view`).
* `maps/select_location_screen.dart`: Map location picker screen with pin dragging to select precise GPS coordinates (`/select-location`).

### 3.9 Notifications & Verification Screens
* `notifications/notifications_screen.dart`: In-app notifications feed for claims, status updates, and messages (`/notifications`).
* `verification/nid_verification_screen.dart`: Government National ID card submission and verification screen (`/nid-verification`).
* `verification/police_gd_integration_screen.dart`: Police General Diary (GD) filing guide and status tracker (`/police-gd`).

### 3.10 Role-Based Dashboard Screens
* `dashboards/admin_dashboard_screen.dart`: Super-admin control panel for user moderation, post management, and platform analytics (`/admin`).
* `dashboards/university_dashboard_screen.dart`: University/campus dashboard for managing campus specific lost & found posts and member approvals (`/university-dashboard`).
* `dashboards/office_dashboard_screen.dart`: Corporate office dashboard for managing internal workspace items (`/office-dashboard`).

### 3.11 System & Settings Screens
* `settings/settings_screen.dart`: App settings including theme mode (light/dark/system), notifications, and security (`/settings`).
* `settings/help_center_screen.dart`: Support center with FAQs and contact details (`/help`).
* `settings/privacy_terms_screen.dart`: Platform Privacy Policy and Terms of Service document view (`/privacy-terms`).
* `settings/about_screen.dart`: App version, development credits, and platform information (`/about`).
* `settings/app_states_empty_offline_screen.dart`: Fallback empty state and offline error display (`/empty-offline`).
* `settings/shader_screen.dart`: Custom visual shader demo screen (`/shader`).

---

## 4. Provider Structure (`lib/core/providers/`)

State management is powered by **Flutter Riverpod**.

### 4.1 Global Providers (`providers.dart`)
* `authServiceProvider`: Provider for singleton `AuthService`.
* `firestoreServiceProvider`: Provider for singleton `FirestoreService`.
* `cloudinaryServiceProvider`: Provider for singleton `CloudinaryService`.
* `authStateProvider`: `StreamProvider<User?>` listening to Firebase Auth state changes.
* `currentUserProvider`: `StreamProvider<UserModel?>` streaming the logged-in user's Firestore profile.
* `themeModeProvider`: `StateProvider<ThemeMode>` managing application light/dark/system theme settings.
* `selectedCategoryProvider`: `StateProvider<String>` holding the active category filter (default: `'All'`).
* `selectedPostTypeProvider`: `StateProvider<String?>` holding post type filter (`null`, `'lost'`, `'found'`).
* `postsStreamProvider`: `StreamProvider<List<PostModel>>` delivering active lost/found posts filtered by category and type.
* `allHistoryStreamProvider`: `StreamProvider<List<HistoryModel>>` streaming all completed item recovery records.
* `rawAllPostsStreamProvider`: `StreamProvider<List<PostModel>>` streaming raw unfiltered post records.
* `selectedCampusProvider`: `StateProvider<CampusModel?>` storing current campus context.
* `allCampusesStreamProvider`: `StreamProvider<List<CampusModel>>` streaming registered university campuses.
* `userCampusMembershipsProvider`: `StreamProvider<List<CampusMemberModel>>` streaming current user's campus affiliations.
* `campusPostsStreamProvider`: `StreamProvider.family<List<PostModel>, String>` streaming posts specific to a campus.
* `campusMembersStreamProvider`: `StreamProvider.family<List<CampusMemberModel>, String>` streaming members of a campus.

### 4.2 Location & Map Providers (`location_dashboard_provider.dart`)
* `liveLocationProvider`: `StateNotifierProvider<LiveLocationNotifier, LiveLocationState>` tracking GPS position, status, accuracy, and address.
* `radiusSearchProvider`: `StateNotifierProvider<RadiusSearchNotifier, RadiusSearchState>` managing radius distance slider (km), sort option (`Nearest`, `Newest`, `Reward`, `AI Match`), and type filter.
* `filteredRadiusPostsProvider`: Derived `Provider<List<PostWithDistance>>` filtering posts by GPS radius using the Haversine formula and applying selected sorting logic.

---

## 5. Service Structure (`lib/core/services/`)

### 5.1 Authentication Service (`auth_service.dart`)
The `AuthService` handles all user authentication workflows:
* **Email & Password Authentication**: `signUpWithEmail()` and `signInWithEmail()` with web persistence fallback (`Persistence.LOCAL` / `SESSION` / `NONE`).
* **Google Sign-In**: `signInWithGoogle()` using `google_sign_in` v7 authentication credentials.
* **Phone Number OTP**: `verifyPhoneNumber()` and `signInWithPhoneOtp()` for mobile number verification.
* **Password Reset**: `sendPasswordResetEmail()`.
* **Bangla Error Handling**: `_handleFirebaseError()` translates FirebaseAuth exception codes into user-friendly Bangla messages.

### 5.2 Cloudinary Image Upload Service (`cloudinary_service.dart`)
The `CloudinaryService` handles photo uploads for posts, claims, and profiles:
* **Cloudinary Upload**: `uploadXFile()` uploads `XFile` bytes to Cloudinary CDN if credentials exist in `.env`.
* **Multiple File Upload**: `uploadMultipleXFiles()` uploads image lists concurrently.
* **Base64 Fallback**: If Cloudinary is unconfigured or fails, converts images directly into Base64 Data URIs (`data:image/jpeg;base64,...`) to ensure user photo display without external dependencies.

### 5.3 Firestore Service (`firestore_service.dart`)
The `FirestoreService` manages database operations and real-time streams across Firestore collections:
* **Users Collection (`users`)**: `saveUser()`, `getUser()`, `streamUser()`.
* **Posts Collection (`posts`)**: `createPost()`, `getPost()`, `streamPosts()`, `streamUserPosts()`, `streamRawAllPosts()`, `streamCampusPosts()`. Includes in-memory `_localPosts` cache for instant UI rendering.
* **Claims Collection (`claims`)**: `createClaim()`, `getClaim()`, `streamClaim()`, `streamClaimsForPost()`, `updateClaimStatus()`, `updateLiveLocation()`. Auto-sends notifications and opens chat rooms upon claim approval.
* **Chat Collection (`chat_rooms`)**: `createOrGetChatRoom()`, `getChatRoom()`, `streamChatRooms()`, `streamMessages()`, `sendMessage()`.
* **Notifications Collection (`notifications`)**: `createNotification()`, `streamNotifications()`.
* **Ratings Collection (`ratings`)**: `createRating()`.
* **Payments Collection (`payments`)**: `createPayment()`.
* **History Collection (`history`)**: `createHistory()`, `streamAllHistory()`, `streamUserHistory()`.
* **Wallet Collection (`wallet`)**: `getOrCreateWallet()`, `updateWallet()`.
* **Campuses Collection (`campuses`, `campus_members`)**: `createCampus()`, `streamAllCampuses()`, `joinCampus()`, `streamUserCampusMemberships()`, `streamCampusMembers()`.

---

## 6. Model Structure (`lib/core/models/`)

### 6.1 `user_model.dart`
* **`UserModel`**: Represents a user document.
  * Fields: `uid`, `email`, `displayName`, `photoUrl`, `phoneNumber`, `role` (`user`, `admin`, `university`, `office`), `isNidVerified`, `rewardPoints`, `location`, `averageRating`, `totalReviews`, `completedRecoveries`, `completedReturns`, `trustScore`, `successfulRecoveryCount`, `createdAt`.
  * Methods: `toMap()`, `fromMap()`.

### 6.2 `post_model.dart`
* **`PostModel`**: Represents a lost or found item post.
  * Fields: `id`, `title`, `description`, `category` (`Electronics`, `Documents`, `Wallet`, `Keys`, `Clothing`, `Pets`, `Other`), `type` (`lost`, `found`), `location`, `latitude`, `longitude`, `date`, `images`, `userId`, `userName`, `userAvatar`, `status` (`active`, `resolved`, `closed`, `completed`, `archived`), `rewardAmount`, `similarityScore`, `campusId`, `createdAt`.
  * Methods: `toMap()`, `fromMap()`.

### 6.3 `chat_model.dart`
* **`ChatRoomModel`**: Represents a 1-on-1 private messaging room between post owner and claimer.
  * Fields: `id`, `participants`, `postId`, `postTitle`, `postImage`, `lastMessage`, `lastMessageTime`, `unreadCount`.
* **`ChatMessageModel`**: Represents a single chat message.
  * Fields: `id`, `senderId`, `text`, `imageUrl`, `timestamp`, `isRead`.

### 6.4 `claim_model.dart`
* **`ClaimModel`**: Represents an ownership claim filed on a found post.
  * Fields: `claimId`, `postId`, `postOwnerId`, `claimerId`, `claimerName`, `claimerPhone`, `claimerEmail`, `address`, `latitude`, `longitude`, `description`, `proofDescription`, `rewardRequested`, `claimImages`, `claimDocuments`, `status` (`pending`, `approved`, `rejected`, `completed`), `recoveryStatus` (`in_progress`, `both_confirmed`), `createdAt`, `approvedAt`, `rejectedAt`, `ownerConfirmedAt`, `finderConfirmedAt`, `isClaimerSharingLocation`, `isOwnerSharingLocation`, `claimerLat`, `claimerLng`, `ownerLat`, `ownerLng`.

### 6.5 `campus_models.dart`
* **`CampusModel`**: Represents an educational institution campus.
  * Fields: `id`, `code`, `name`, `institutionName`, `description`, `location`, `address`, `logoUrl`, `creatorId`, `creatorName`, `status`, `createdAt`.
* **`CampusMemberModel`**: Links a user to a campus membership.
  * Fields: `id`, `uid`, `campusId`, `studentId`, `role` (`student`, `author`, `campus_admin`), `status`, `joinedAt`.

### 6.6 `recovery_models.dart`
* **`RatingModel`**: Ratings submitted post-recovery.
  * Fields: `ratingId`, `postId`, `claimId`, `fromUser`, `toUser`, `fromUserId`, `toUserId`, `rating`, `review`, `behavior`, `communication`, `trustworthiness`, `responseTime`, `recommendation`, `createdAt`.
* **`PaymentModel`**: Financial reward transaction logs.
  * Fields: `paymentId`, `postId`, `claimId`, `posterId`, `finderId`, `method` (`bKash`, `Rocket`, `Nagad`), `amount`, `receiverName`, `receiverNumber`, `transactionId`, `status`, `paidAt`, `confirmedAt`.
* **`HistoryModel`**: Completed recovery archive entries.
  * Fields: `historyId`, `originalPostId`, `claimId`, `posterId`, `finderId`, `ownerName`, `finderName`, `ownerRating`, `finderRating`, `ownerReview`, `finderReview`, `status`, `title`, `category`, `location`, `rewardAmount`, `paymentStatus`, `averageRating`, `images`, `completedDate`.
* **`WalletModel`**: User reward balance state.
  * Fields: `userId`, `totalEarned`, `todayEarned`, `monthlyEarned`, `lifetimeEarned`, `lastUpdated`.

---

## 7. Widget Structure (`lib/core/widgets/`)

* `app_image.dart` (`AppImage`): Universal image renderer handling raw bytes (`Uint8List`), Base64 URIs, HTTP(S) network URLs, local files, and fallback placeholder graphics. Includes `AppImage.getImageProvider()` utility.
* `category_chip.dart` (`CategoryChip`): Animated selectable chip widget for filtering lost/found item categories.
* `custom_text_field.dart` (`CustomTextField`): Standard input field component with consistent labels, icons, and validation styling.
* `glass_container.dart` (`GlassContainer`): Custom container with glassmorphic backdrop blur, subtle borders, and dynamic dark/light theme background opacity.
* `live_location_card.dart` (`LiveLocationCard`): Status card displaying active GPS tracking, address, accuracy, and controls to start/pause/stop live position updates.
* `primary_button.dart` (`PrimaryButton`): Main rounded action button featuring primary gradient background, drop shadow, and loading spinner state.
* `radius_search_card.dart` (`RadiusSearchCard`): Interactive control panel containing search radius slider (km), sort dropdown, and type toggles.
* `stat_card.dart` (`StatCard`): Compact stat card showing numeric metrics alongside themed icon badges.

---

## 8. App Navigation & Routing Table (`lib/core/config/app_router.dart`)

The app uses `go_router` with initial route `/splash`:

| Route Path | Screen Component | Parameters / Extra |
|---|---|---|
| `/splash` | `SplashScreen` | — |
| `/splash-animated` | `SplashScreenAnimatedScreen` | — |
| `/welcome` | `WelcomeAuthScreen` | — |
| `/welcome-animated` | `WelcomeAuthAnimatedScreen` | — |
| `/login` | `LoginScreen` | — |
| `/register` | `RegisterScreen` | — |
| `/forgot-password` | `ForgotPasswordScreen` | — |
| `/otp-verify` | `OtpVerificationScreen` | — |
| `/onboarding` | `OnboardingFlowScreen` | — |
| `/home` | `HomeDashboardScreen` | — |
| `/home-animated` | `HomeDashboardAnimatedScreen` | — |
| `/ai-search` | `AiSmartSearchScreen` | — |
| `/search-results` | `SearchResultsScreen` | `query`, `category` |
| `/ai-scan` | `AiImageScanScreen` | — |
| `/ai-matches` | `AiMatchResultsScreen` | — |
| `/ai-matches-animated` | `AiMatchResultsAnimatedScreen` | — |
| `/create-post-step1` | `CreateLostPostStep1Screen` | — |
| `/preview-report` | `PreviewPublishReportScreen` | `state.extra` (Map) |
| `/item-details/:id` | `ItemDetailsScreen` | `id` |
| `/submit-claim/:postId` | `SubmitClaimScreen` | `postId` |
| `/claim-details/:claimId` | `ClaimDetailsScreen` | `claimId` |
| `/my-posts` | `MyPostsScreen` | — |
| `/map-view` | `GoogleMapViewScreen` | — |
| `/select-location` | `SelectLocationScreen` | `initial` |
| `/chats` | `ChatListScreen` | — |
| `/chat/:id` | `ChatConversationScreen` | `id` |
| `/notifications` | `NotificationsScreen` | — |
| `/profile` | `ProfileScreen` | — |
| `/edit-profile` | `EditProfileScreen` | — |
| `/favorites` | `FavoritesScreen` | — |
| `/history` | `HistoryScreen` | — |
| `/rewards` | `RewardsWalletScreen` | — |
| `/leaderboard` | `LeaderboardScreen` | — |
| `/recovery-completed/:claimId`| `RecoveryCompletedScreen` | `claimId` |
| `/reward-payment/:claimId` | `RewardPaymentScreen` | `claimId` |
| `/reward-success/:paymentId` | `RewardSuccessScreen` | `paymentId` |
| `/rating/:claimId` | `RatingScreen` | `claimId` |
| `/recovery-history` | `RecoveryHistoryScreen` | — |
| `/wallet` | `WalletScreen` | — |
| `/nid-verification` | `NidVerificationScreen` | — |
| `/police-gd` | `PoliceGdIntegrationScreen` | — |
| `/admin` | `AdminDashboardScreen` | — |
| `/university-dashboard` | `UniversityDashboardScreen` | — |
| `/office-dashboard` | `OfficeDashboardScreen` | — |
| `/settings` | `SettingsScreen` | — |
| `/help` | `HelpCenterScreen` | — |
| `/privacy-terms` | `PrivacyTermsScreen` | — |
| `/empty-offline` | `AppStatesEmptyOfflineScreen` | — |
| `/shader` | `ShaderScreen` | — |
| `/about` | `AboutScreen` | — |
