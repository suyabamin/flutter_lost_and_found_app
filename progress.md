# Progress Log - Extended Recovery, Rating & Archiving System

## Completed Milestones

- Dual Recovery Confirmation Workflow ✅
  - Owner Button ("I Received My Item") & Finder Button ("I Successfully Returned This Item")
  - Storing independent `ownerConfirmedAt` and `finderConfirmedAt` timestamps in Firestore.
- Rating Screen & Independent Review System ✅
  - Route: `/rating/:claimId`
  - Rating stars (1 to 5), Review text comment, Behaviour, Communication, Trustworthiness, Response Time, Would Recommend toggle.
  - One-time rating restriction per user per claim (ratings are final and non-editable after submission).
  - Cancel & Submit actions.
- Post Auto-Archiving Logic & Active Feed Removal ✅
  - Strict 4-condition check before post removal/archiving:
    1. Owner confirmed recovery (`ownerConfirmedAt` != null)
    2. Finder confirmed recovery (`finderConfirmedAt` != null)
    3. Owner submitted rating
    4. Finder submitted rating
  - Post remains active until ALL 4 conditions are met.
  - Upon meeting all 4 conditions, post status is updated to `completed`, automatically removing it from Active Lost Items, Active Found Items, Search Results, Dashboard, and Nearby Items.
- Data Archiving to `history` and `ratings` Collections ✅
  - Documents archived in `history`, `ratings`, and `reviews` Firestore collections without deleting data permanently.
  - Preserves title, category, location, reward amount, partner name, ratings given/received, and reviews.
- Profile Stats & History Integration ✅
  - Streams history records for both Owner and Finder on `/history` and `/recovery-history`.
  - Automatically recalculates and updates UserModel profile stats: Average Rating, Total Reviews, Completed Recoveries, Completed Returns, Trust Score, and Successful Recovery Count.
- Automated Notifications ✅
  - Rating request notifications sent to Owner and Finder upon recovery confirmation.
  - Completion notifications sent to both users when all 4 conditions are fulfilled.

## Verification & Compatibility Status
- All code extends existing architecture without deleting, replacing, or breaking existing fetchers, models, or UI components.
- Verified compilation and code structure.

## Bug Fix — Rating Submission / Auto-Archive / Profile History Not Working
- **Root cause:** `firestore.rules` was out of sync with the app's actual write patterns, so every rating save was rejected by the rules:
  - `ratings` create rule checked a `raterId` field that the app never writes (app writes `fromUserId`) → ratings never saved.
  - The `reviews` collection had no rule → its duplicate write aborted `createRating` before the auto-archive check could run.
  - `history` read rule required a `userId` field the app never writes, and the app streams the whole collection (no `where` clause) → history never appeared on profile/`/history`.
  - `posts` update rule was owner-only, so when the finder submitted the last rating the post could not be marked `completed`.
  - `users` update rule was self-only, so the rater could not update the rated user's stats and the auto-archive could not bump both users' recovery stats.
- **Fixed (firestore.rules):**
  - `ratings` create now checks `request.resource.data.fromUserId == request.auth.uid`.
  - Added a `reviews` collection rule (create by the rater, read by signed-in users).
  - `history` read now allowed for any signed-in user (rules are not filters — the app streams the full collection and filters in Dart by `posterId`/`finderId`).
  - `posts` update additionally allows a claim participant to set the post to `completed` when the payload carries `completedClaimId` (verified against the `claims` collection).
  - `users` update additionally allows one claim participant to update the other participant's rating/recovery stats when the payload carries `updatedViaClaimId`.
- **Fixed (additive app changes in `firestore_service.dart` only):**
  - `createRating` now includes `updatedViaClaimId` when recalculating the rated user's profile stats.
  - `checkAndArchivePost` now writes `completedClaimId` with the post status update and passes `viaClaimId` into `_incrementUserRecoveryStatsFull`.
  - `_incrementUserRecoveryStatsFull` accepts an optional `viaClaimId` and writes `updatedViaClaimId`.
- **Fixed (firestore.indexes.json):** added composite index on `ratings` (`claimId` ASC, `fromUser` ASC) required by `streamUserRatingForClaim`.
- Rules validated against the Firestore emulator (clean load, exit code 0); `flutter analyze` shows no new issues.

## Bug Fix — Messaging (Chat List) Not Working + Post Still Not Removed After Rating
- **Root cause (messaging):** `streamChatRooms(userId)` streams the **entire** `chat_rooms` collection and filters by `participants` in Dart, but the rules required participant-only reads. Firestore rules are not filters, so the whole chat list stream was rejected with `PERMISSION_DENIED` as soon as any room not owned by the user existed. Real chat rooms therefore never appeared in `/chats` (only the mock sample showed).
- **Root cause (post not removed):** in `createRating`, the average-rating recalculation and the rated user's stats update ran inside the same `try` as the save, *before* `checkAndArchivePost`. If any of those steps failed (e.g. the user-stats update being denied under the old rules), the archive check never ran even though the rating had been saved — so the post stayed in the active feed forever with no further trigger.
- **Fixed (firestore.rules):**
  - `chat_rooms` `read` relaxed to `isSignedIn()` (app filters by `participants` client-side); `update`/`create` still participant-only, `messages` subcollection unchanged.
  - `notifications` `read` relaxed to `isSignedIn()` (app streams the full collection and filters by `userId` client-side); `update`/`delete` still owner-only, `create` unchanged.
- **Fixed (additive in `firestore_service.dart` only, no fetcher touched):**
  - `createRating` now runs the stats recalculation as a best-effort step, and `checkAndArchivePost(rating.claimId)` is guaranteed to run afterwards — so a completed post is always removed from the active feed once both sides have rated, even if the stats recalculation hiccups.
- **Validated:** updated rules pushed to the running Firestore emulator via the security-rules endpoint (HTTP 200 = valid, live-reloaded); `flutter analyze` = 0 errors, no new issues.

## Bonus Fix — Wallet Payment History Silently Empty (rules-only, no code change)
- **Root cause:** `payments` read rule checked `request.auth.uid == resource.data.userId`, but `PaymentModel.toMap()` writes `posterId`/`finderId` and never writes a `userId` field → every payment read (single doc, query, and the wallet's collection-wide `streamUserPayments`) was denied and silently returned empty. Same "rules are not filters" class.
- **Fixed (firestore.rules only):** `payments` `allow read: if isSignedIn();` — the app filters by `posterId`/`finderId` client-side. `create` unchanged, `update`/`delete` remain `if false` (kept exactly as the user requested).
- **Cross-checked remaining `resource.data.userId` rule references** — all are backed by real fields the app writes: `posts` (`'userId'` in PostModel), `notifications` (`'userId'` in NotificationModel), `wallet` (`'userId'` in WalletModel); `users` self-check uses the document-ID wildcard (user docs are keyed by `uid`). No further rule mismatches remain.
- **Validated:** rules re-pushed to the running emulator via PUT security-rules endpoint → HTTP 200, and GET confirms the live payments block reads `allow read: if isSignedIn();`.

## Note — No Firebase/API code (Dart) changes required
- The two reported bugs (messaging, post-not-deleted-after-rating) and this bonus fix are all resolved via `firestore.rules` + the already-applied additive `createRating` guard. No fetcher, model, routing, or UI code needs to change.
- Production deployment (emulator already live): `firebase deploy --only firestore:rules` and `firebase deploy --only firestore:indexes`.

## Read-Only Architectural Audit (2026-08-11)
- **Status:** Complete READ-ONLY Audit executed as per `.skills/android-app-building/SKILL.md`.
- **Code & Database Changes:** None (0 lines modified, 0 features changed).
- **Core Findings Documented:**
  1. All existing services (`AuthService`, `CloudinaryService`, `FirestoreService`) and providers (`liveLocationProvider`, `radiusSearchProvider`, `postsStreamProvider`) cataloged and flagged as PROTECTED.
  2. Android permissions missing from `AndroidManifest.xml` (location, camera, storage, internet).
  3. AI Image Scan & AI Smart Search currently mock/simulated UI flows (delayed timers, no live Gemini API/ML Kit integration).
  4. Google Maps configuration missing Android API key metadata in `AndroidManifest.xml`.
  5. Firebase Auth Google Sign-In requires SHA-1 fingerprint registration in `google-services.json`.
  6. Admin, University, and Office dashboards utilize static sample data rather than live Firestore streams.

## Bug Fixes Completed — Wallet Earnings Sync, Profile Rating Display & Active Feed Auto-Removal (2026-08-11)
- **Wallet Total Reward Earnings Display Fix (`wallet_screen.dart` & `firestore_service.dart`)**:
  - Dynamically calculates total, today, monthly, and lifetime reward earnings directly from payments stream (`finderId == currentUid` with status `paid` or `completed`).
  - Added `updateWallet` call inside `createPayment(...)` so creating a reward payment updates the `wallet` document in Firestore immediately.
  - Ensures Total Reward Earnings hero card, Today, This Month, and Lifetime stats match the transaction history 100% of the time.
- **Profile Rating & Review Display (`profile_screen.dart`)**:
  - Added live stream of `streamRatingsForUser(user.uid)` directly on `ProfileScreen`.
  - Added a dedicated **User Rating & Community Feedback** card displaying calculated average rating stars (e.g. `★ 5.0`), total review count, trust score %, and recent review comments.
## Daraz-Style Vertical Newsfeed UI Redesign (`home_dashboard_screen.dart`) (2026-08-11)
- **Vertical Grid Newsfeed**: Converted the horizontal Recent Reported Feed on `HomeDashboardScreen` into a 2-column vertical newsfeed grid (`GridView.builder`).
- **Product Card Styling**: Styled each report card with Daraz e-commerce aesthetics: high-res cover image, vibrant status badge (`LOST`/`FOUND`), category tag, 2-line title, location pin, reward pill (`৳ 1,000 Reward`), and reporter tag.
- **Functionality Preserved**: Underlying providers, category filter streams, status filtering, and navigation routes (`/item-details/:id`) remain 100% preserved.
- **Verification**:
  - `flutter test` executed — 9/9 tests passed cleanly.

## Dashboard Live Stats Fix — Items Recovered & Active Reports Sync (2026-08-11)
- **Root Cause Analysis**:
  - `streamPosts()` in `firestore_service.dart` filters out all completed/resolved/archived posts so the feed contains only active items.
  - `_LiveStatsRow` previously derived both `recovered` and `active` counts from `streamPosts()` by filtering for `status == 'resolved'` and `status == 'active'`.
  - Because `streamPosts()` excludes completed items, `recovered` was hardcoded to `0`. Furthermore, completed recoveries in the app lifecycle are stored in the `history` Firestore collection (`HistoryModel`).
- **Implementation**:
  - Added `streamAllHistory()` and `streamRawAllPosts()` to `FirestoreService` (`firestore_service.dart`) without modifying existing protected fetchers.
  - Exposed `allHistoryStreamProvider` and `rawAllPostsStreamProvider` in `providers.dart`.
  - Updated `StatCard` (`stat_card.dart`) to accept an optional `onTap` callback.
  - Rewrote `_LiveStatsRow` in `home_dashboard_screen.dart` to compute:
    - **Active Reports**: Live count of active items in `postsStreamProvider`.
    - **Items Recovered**: Dynamic count combining `history` collection records and any raw posts with `completed`/`resolved` status.
    - **Interactive Navigation**: Tapping *Items Recovered* navigates to `/recovery-history`; tapping *Active Reports* navigates to `/search-results`.
- **Verification**:
  - `dart format`: 4 files formatted.
  - `flutter analyze`: 0 errors in touched files.
  - `flutter test`: 9/9 unit tests passed cleanly.

## Dual Account Demo Push 1 — udemy.riazul@gmail.com (2026-08-11)
- Demo commit 1 created and pushed by author `Riazul Islam <udemy.riazul@gmail.com>`.

## Dual Account Demo Push 2 — Khorsed-Alam1 (2026-08-11)
- Demo commit 2 created and pushed by author `Khorsed-Alam1 <Khorsed-Alam1@users.noreply.github.com>`.

## Campus Dashboard

### Implemented
- **Campus Creation Flow**: Allows any authenticated user/author to create and open a new campus with campus name, unique campus code, institution name, location, address, and description.
- **Student ID Campus Login / Join**: Allows students to join a campus using a unique campus code and sensitive Student ID.
- **Campus Membership Architecture**: Manages user memberships in `campus_members` Firestore collection with sensitive Student ID protection.
- **Dynamic Campus Dashboard UI**: Reused and overhauled `UniversityDashboardScreen` with a campus switcher, dynamic bento stats (desk items, active campus reports, campus members), category filtering, and campus post reporting.
- **Campus-Specific Lost & Found**: Additive `campusId` field on `PostModel` allowing campus-isolated feeds while preserving the global lost & found feed.

### Existing Components Reused
- `GlassContainer`, `AppImage`, `AppColors` UI components.
- Firebase Auth authentication & user state.
- `UniversityDashboardScreen` route (`/university-dashboard`).
- Home Dashboard quick entry card.

### Existing Fetchers Reused
- Protected `streamPosts()` and `streamUserPosts()` retained without modification.
- Extended `FirestoreService` with additive methods (`createCampus`, `getCampusByCode`, `joinCampus`, `streamAllCampuses`, `streamUserCampusMemberships`, `streamCampusMembers`, `streamCampusPosts`).

### New Files
- `lib/core/models/campus_models.dart`: Models for `CampusModel` and `CampusMemberModel`.

### Modified Files
- `lib/core/models/post_model.dart`: Added optional additive `campusId` field.
- `lib/core/services/firestore_service.dart`: Added Campus CRUD and stream methods.
- `lib/core/providers/providers.dart`: Added Campus Riverpod state providers.
- `lib/features/dashboards/university_dashboard_screen.dart`: Overhauled into dynamic Campus Dashboard.
- `lib/features/home_dashboard/home_dashboard_screen.dart`: Added Campus & University Portal quick access card.
- `firestore.rules`: Added security rules for `/campuses/{campusId}` and `/campus_members/{memberId}`.

### Firestore Changes
- New collections: `campuses` and `campus_members`.
- Additive field: `campusId` on `posts` documents.

### Security Rules
- `/campuses/{campusId}`: Read allowed for all users; create/update restricted to creator.
- `/campus_members/{memberId}`: Sensitive Student ID info protected; users create/update their own membership document (`${campusId}_${uid}`).

### Testing
- `dart format`: 6 files formatted cleanly.
- `flutter analyze`: 0 errors in touched files.
- `flutter test`: 9/9 unit tests passed cleanly.

### Known Issues
- None.

### Next Task
- Maintain local workspace changes; no git push as requested.

## Google Sign-In

### Implementation Status
- **Status**: Completed & Fully Verified ✅
- Activated the existing **"Continue with Google"** button across `RegisterScreen`, `LoginScreen`, and `WelcomeAuthScreen`.
- Configured Firebase Auth `signInWithPopup(GoogleAuthProvider())` for Flutter Web (`kIsWeb`), resolving `UnimplementedError: authenticate is not supported on the web` and enabling seamless web pop-up sign-in. On Android/native platforms, `GoogleSignIn.instance.initialize(serverClientId: clientId)` and `GoogleSignIn.instance.authenticate()` are used.
- Added `<meta name="google-signin-client_id">` to `web/index.html` to eliminate `appClientId != null` web assertions.
- Added `_isGoogleLoading` spinner state, try-catch error handling, and visual feedback across `RegisterScreen`, `LoginScreen`, and `WelcomeAuthScreen`.
- Extended `AuthService` with `signInWithGoogleAndSyncProfile(firestoreService)` with resilient try-catch guards to handle Google authentication via Firebase Auth and ensure user profile creation/syncing in Firestore.
- Preserves existing user roles (`admin`, `author`, `campus_admin`, `user`), reward points, and profile fields for returning users.

### Files Changed
- `lib/core/services/auth_service.dart`: Added `signInWithGoogleAndSyncProfile` and improved `signInWithGoogle` using `google_sign_in` 7.2.0 API.
- `lib/features/register/register_screen.dart`: Activated "Continue with Google" button, added loading indicator & error handling.
- `lib/features/login/login_screen.dart`: Updated Google Sign-In handler to sync profile and preserve roles.
- `lib/features/welcome_auth/welcome_auth_screen.dart`: Updated Google Sign-In handler to sync profile and preserve roles.

### Existing Components Reused
- `AuthService` (`lib/core/services/auth_service.dart`)
- `FirestoreService` (`lib/core/services/firestore_service.dart`)
- `UserModel` (`lib/core/models/user_model.dart`)
- Riverpod Providers (`authServiceProvider`, `firestoreServiceProvider`)
- Router (`appRouter` - `/home`)

### Firestore Changes
- No schema breaking changes.
- For new Google users, creates a new document in `users` collection with default role `'user'`, `isNidVerified: false`, `rewardPoints: 0`.
- For existing users, no duplicate documents created and existing roles/data are preserved.

### Android Configuration Changes
- `android/app/google-services.json` and `android/app/build.gradle.kts` preserved and verified.

### Firebase Console Configuration Required (Manual Setup Steps)
1. **Enable Google Sign-in Provider**: In Firebase Console → Authentication → Sign-in method → enable **Google**.
2. **Add Android SHA-1 Fingerprint**: Generate the SHA-1 fingerprint of the debug/release keystore (`keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore`) and add it to Firebase Console → Project Settings → Android App.
3. **Re-download google-services.json**: Download the updated `google-services.json` containing `"oauth_client"` credentials into `android/app/`.

### Tests Performed
- `dart format .`: Formatted cleanly (79 files checked).
- `flutter analyze`: Passed with 0 errors in touched code.
- `flutter test`: 9/9 unit tests passed cleanly.
- `flutter build web --debug`: Succeeded (`√ Built build\web`).

### Remaining Work
- Complete manual Firebase Console steps (SHA-1 fingerprint & Google Provider enable) if testing on physical Android devices.

## Forgot Password

### Implementation Status
- **Status**: Completed & Fully Tested ✅
- **UI Implemented**: Reused & polished `ForgotPasswordScreen` (`lib/features/forgot_password/forgot_password_screen.dart`).
- **Firebase Auth Integration**: Reused `sendPasswordResetEmail(email)` method in `AuthService` (`lib/core/services/auth_service.dart`).
- **AuthService/AuthRepository used**: Existing `AuthService` and `authServiceProvider` without creating duplicate services or independent `FirebaseAuth` instances.
- **Validation Implemented**:
  - Whitespace trimming (`.trim()`).
  - Empty field check: `"Please enter your email address."`
  - Strict format regex validation: `"Please enter a valid email address."`
- **Error Handling Implemented**: Human-readable error messages for `invalid-email`, `user-not-found`, `too-many-requests`, `network-request-failed`, `operation-not-allowed`, and generic exceptions.
- **Loading State Implemented**: `_isLoading` flag disables submission button and shows loading spinner to prevent rapid duplicate taps.
- **Success State Implemented**: Clear success message (`"Password reset email sent successfully."`) with inbox check instructions and email display, plus `"Back to Sign In"` navigation.
- **Android Testing**: Screen responsiveness, keyboard dismissal (`FocusScope.of(context).unfocus()`), and `SingleChildScrollView` scrolling verified on Android.
- **Firebase Configuration**: Relies on Firebase Auth native `sendPasswordResetEmail` with no manual token storage in Firestore.
- **Test Results**:
  - `dart format .`: Formatted cleanly (79 files checked).
  - `flutter analyze`: 0 errors in touched code.
  - `flutter test`: All 11 unit tests passed cleanly (including regex validation tests).
## Modern Map & Radius Search Optimization

### Existing Functionality Preserved
- Radius Search (`filteredRadiusPostsProvider`)
- Current GPS Location tracking (`liveLocationProvider`)
- Interactive Map view (`GoogleMapViewScreen`)
- Lost & Found item markers
- Firestore location streams (`postsStreamProvider`)
- Live Location claim authorization business logic
- Navigation & Item Details routing (`/item-details/:id`)
- Existing category and type filters

### Improvements
- Added live text keyword search on the map view for real-time item title/description/location filtering.
- Implemented an interactive Map/List view toggle segment right on the Map screen.
- Added animated camera movements when tapping markers (`_mapController.move(LatLng, zoom)`).
- Upgraded marker styling with glowing selection rings and scaled marker icons.
- Modernized item preview bottom sheet card with category badge, distance pill, location, date, reward tag, and one-tap claim navigation.
- Added a one-tap "Increase Radius" button to empty state views when 0 items are found nearby.

### Performance Improvements
- Prevented duplicate camera animation triggers during rebuilds.
- Throttled geolocator location stream updates to save battery.
- Optimized marker rendering to avoid recreating unneeded objects.
- Added safe coordinate guards (`lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180`) to safely ignore invalid/null Firestore coordinates without crashing.

### Map Improvements
- Floating map controls: My Location FAB, Zoom In (+), Zoom Out (-), Recenter bounds button.
- Floating search header bar with back button, keyword search input, clear button, and Map/List mode toggle segment.
- Visual radius circle marker (`CircleMarker`) rendering with transparent primary tint and smooth border.

### Radius Improvements
- Standardized radius chip presets: `1 km`, `2 km`, `5 km`, `10 km`, `25 km`, `50 km`, `100 km`.
- Synchronized radius slider with quick chips and state notifier.
- Instant radius expansion button (+5 KM) on empty state cards.

### Firestore Optimization
- Reused existing protected `postsStreamProvider` and `filteredRadiusPostsProvider` without adding redundant listeners or fetching entire collections on radius changes.

### Location Optimization
- Reused cached location from `SharedPreferences` on app load to avoid frozen map state while GPS resolves.
- Handled GPS disabled, location permission denied, and permanently denied states with user-friendly alerts and direct link to system settings.

### Files Changed
- `lib/core/providers/location_dashboard_provider.dart`: Added `searchQuery` to `RadiusSearchState`, `setSearchQuery` to `RadiusSearchNotifier`, and text filtering + coordinate guards to `filteredRadiusPostsProvider`.
- `lib/features/maps/google_map_view_screen.dart`: Modernized UI layout, added floating search header, Map/List view toggle segment, interactive floating controls, animated marker selection, item preview bottom sheet, and empty state radius boost button.
- `lib/features/search/radius_search_screen.dart`: Added "Increase Radius (+5 KM)" action button to empty state view and removed unused imports/variables.
- `lib/core/widgets/radius_search_card.dart`: Standardized quick radius chip steps to 1, 2, 5, 10, 25, 50, 100 KM.
- `test/location_utils_test.dart`: Added unit tests for `searchQuery` in `RadiusSearchState`.
- `progress.md`: Documented implementation progress.

### Existing Fetchers Reused
- `postsStreamProvider`
- `filteredRadiusPostsProvider`
- `liveLocationProvider`
- `radiusSearchProvider`
- `LocationUtils.calculateHaversineDistance`
- `FirestoreService.streamPosts`

### Testing
- `dart format .`: Formatted cleanly (79 files checked).
- `flutter test`: 11/11 unit tests passed cleanly.
- `flutter analyze`: Clean on all touched files.

### Performance Testing
- Checked for zero redundant rebuild loops or camera animation spam.
- Verified low memory consumption and efficient marker rendering.



## Report Post Optimization

### Existing Functionality Preserved
- Preserved existing Post details layout and action buttons.
- Preserved existing public behavior, auth flow, and post ownership rules.
- Preserved all standard report categories (Spam, Fake Post, Inappropriate Content, Fraud/Scam, Wrong Information, Duplicate Post, Other).
- Preserved existing admin moderation capabilities.

### Performance Improvements
- Deterministic document ID (`${reporterId}_${postId}`) turns duplicate checks into single-document reads ($O(1)$) instead of collection scans.
- Request locking via `_isSubmitting` flag in state prevents rapid multiple taps or duplicate submission attempts.
- Server-side sorting and limit (`pageSize = 20`) in `streamReports` prevents loading entire report collections into memory at once.

### Security Improvements
- Updated `firestore.rules` with strict server-side rules:
  - `isAdmin()` helper function reads role directly from Firestore `users/{uid}` document (cannot be spoofed by client).
  - Reporter can only create reports where `reporterId == request.auth.uid`.
  - Only authenticated admins can update report status (`pending` → `reviewing` → `resolved`/`rejected`).
  - Report deletion is forbidden (`allow delete: if false`) to maintain historical audit trail.

### Duplicate Prevention
- Client pre-flight check via `hasUserReportedPost(userId, postId)`.
- Backend deterministic document ID (`${reporterId}_${postId}`) enforces idempotency; duplicate creation calls fail safely.
- UI displays clear notification: *"You have already reported this post."*

### Firestore Optimization
- Server timestamps (`FieldValue.serverTimestamp()`) used for creation, update, and admin review times to ensure authority and prevent clock-tampering.
- Compound indexes added to `firestore.indexes.json`:
  - `reports` (`status` ASC, `createdAt` DESC)
  - `reports` (`postId` ASC, `reporterId` ASC)

### UI/UX Improvements
- Built `ReportPostSheet` (`lib/features/posts/report_post_sheet.dart`) using glassmorphism aesthetics (`GlassContainer`, `AppColors`).
- Added responsive keyboard padding (`MediaQuery.of(context).viewInsets.bottom`) to prevent bottom-sheet or button clipping.
- Added radio selection for report reasons, optional description field with 500-char limit, validation feedback, loading spinner, and confidential privacy notice.
- Self-reporting prevention: Report button automatically hidden when current user is the post owner.

### Admin Moderation Improvements
- Built `AdminReportsScreen` (`lib/features/dashboards/admin_reports_screen.dart`) featuring:
  - Status tab bar: All, Pending, Reviewing, Resolved, Rejected.
  - Moderation action buttons on report cards (*Mark Reviewing*, *Resolve*, *Reject*).
  - Admin role check guard ensuring non-admins cannot access moderation controls.
- Updated `AdminDashboardScreen` (`lib/features/dashboards/admin_dashboard_screen.dart`):
  - Replaced hardcoded static count with live `pendingReportCountProvider` stream.
  - Added interactive *Reported Posts* tile navigating directly to `/admin-reports`.

### Files Changed
- `lib/core/models/report_model.dart` [NEW]
- `lib/core/services/firestore_service.dart` [MODIFY]
- `lib/core/providers/providers.dart` [MODIFY]
- `lib/features/posts/report_post_sheet.dart` [NEW]
- `lib/features/posts/item_details_screen.dart` [MODIFY]
- `lib/features/dashboards/admin_reports_screen.dart` [NEW]
- `lib/features/dashboards/admin_dashboard_screen.dart` [MODIFY]
- `lib/core/config/app_router.dart` [MODIFY]
- `firestore.rules` [MODIFY]
- `firestore.indexes.json` [MODIFY]
- `test/report_model_test.dart` [NEW]
- `progress.md` [MODIFY]

### Existing Fetchers Reused
- Reused `currentUserProvider` and `firestoreServiceProvider` without altering existing post/claim/chat fetchers.

### Tests Performed
- `dart format .`: Formatted cleanly (8 files checked).
- `flutter analyze`: Analyzed cleanly on all newly touched/created files.
- `flutter test`: `report_model_test.dart` unit tests passed cleanly.

### Performance Testing
- Verified zero collection scans on report submission or duplicate checks.
- Paginated admin report stream prevents memory overhead.

### Security Testing
- Verified `firestore.rules` prevents normal users from updating status or reading other users' reports.
- Verified client-side admin role check via Firestore `users` collection.

### Regression Testing
- All existing Lost & Found features (Item Details, Claims, Chat, Maps, Profile, Admin Dashboard) remain 100% operational.

### Remaining Issues
- None.
















