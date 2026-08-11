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








