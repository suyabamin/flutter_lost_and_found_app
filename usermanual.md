# Lost & Found Bangladesh (BD) — User Manual

**Version:** 1.0.0  
**Platform:** Android / iOS / Web  
**Technology:** Flutter, Firebase, Gemini AI, OpenStreetMap  

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Getting Started](#2-getting-started)
3. [Authentication](#3-authentication)
4. [Home Dashboard](#4-home-dashboard)
5. [Posting Lost & Found Items](#5-posting-lost--found-items)
6. [Viewing & Claiming Items](#6-viewing--claiming-items)
7. [AI-Powered Features](#7-ai-powered-features)
8. [Chat & Messaging](#8-chat--messaging)
9. [Recovery & Payment Flow](#9-recovery--payment-flow)
10. [Interactive Map](#10-interactive-map)
11. [Profile & Account](#11-profile--account)
12. [Leaderboard & Rewards](#12-leaderboard--rewards)
13. [Notifications](#13-notifications)
14. [NID Verification & Police GD](#14-nid-verification--police-gd)
15. [Settings](#15-settings)
16. [Role-Based Dashboards](#16-role-based-dashboards)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Introduction

**Lost & Found BD** is a comprehensive AI-powered mobile application designed for Bangladesh that connects people who have lost items with people who have found them. The platform enables users to:

- Report lost or found items with photos and location details
- Use AI image scanning to automatically match lost and found items
- Search for items using natural language and smart filters
- Communicate privately with other users via in-app chat
- Share live GPS location during item handoff for safety
- Claim items with proof of ownership and owner verification
- Pay and receive rewards through bKash, Rocket, or Nagad
- Earn trust scores and community reputation through ratings
- Generate official Police General Diary (GD) documents

The app supports a glassmorphism UI design with light and dark themes, and is built with Firebase backend for real-time data synchronization.

---

## 2. Getting Started

### 2.1 Installation

1. Download the app from the Google Play Store (Android) or Apple App Store (iOS)
2. Open the app after installation

### 2.2 First Launch

When you open the app for the first time:

1. **Splash Screen** — You will see an animated splash screen with the Lost & Found BD logo and the tagline "RELIABILITY — EFFICIENCY — CALM"
2. **Onboarding** — A 3-page onboarding carousel will guide you through key features:
   - **Page 1:** "Find What You Lost" — Learn about the search functionality
   - **Page 2:** "Help Others" — Learn about reporting found items
   - **Page 3:** "AI-Powered Matching" — Learn about automatic item matching
3. Swipe through the pages or tap **Skip** to proceed directly to authentication

### 2.3 System Requirements

- **Android:** Android 6.0 (API level 23) or higher
- **iOS:** iOS 12.0 or higher
- **Internet Connection:** Required for real-time features (Wi-Fi or mobile data)
- **GPS:** Required for location features (can be disabled for basic use)
- **Camera:** Required for photo uploads (optional)

---

## 3. Authentication

### 3.1 Welcome Screen

The welcome screen provides three authentication options:

#### Option A: Email Login
1. Tap **"Continue with Email"**
2. Enter your email address and password
3. Check **"Remember me"** to stay signed in on this device
4. Tap **"Sign In"**
5. If you forgot your password, tap **"Forgot Password?"** to receive a reset link

#### Option B: Phone Number Verification
1. Tap **"Continue with Phone Number"**
2. Enter your Bangladesh mobile number (e.g., 01XXXXXXXXX)
3. You will receive a 6-digit OTP code via SMS
4. Enter the code in the OTP fields — they auto-advance as you type
5. Tap **"Verify"** to complete sign-in

#### Option C: Google Sign-In
1. Tap **"Continue with Google"**
2. Select your Google account from the list
3. Confirm the sign-in — you will be redirected to the home screen

### 3.2 Registering a New Account

1. On the welcome screen, tap **"Don't have an account? Register"**
2. Fill in the registration form:
   - **Full Name** — Your display name
   - **Email Address** — Will be used for login
   - **Phone Number** — For OTP verification and chat
   - **Password** — Minimum security requirements apply
   - **Confirm Password** — Must match the password field
3. Accept the **Terms and Conditions** checkbox
4. Tap **"Create Account"**
5. After registration, you will be taken to the onboarding screen and then to the home dashboard

### 3.3 Forgot Password

1. On the login screen, tap **"Forgot Password?"**
2. Enter your registered email address
3. Tap **"Send Reset Link"**
4. Check your email inbox for the password reset link
5. Follow the link to set a new password
6. Return to the app and sign in with your new password

### 3.4 Signing Out

1. Go to **Profile** (bottom navigation bar)
2. Scroll down and tap **"Sign Out"**
3. Confirm the sign-out action
4. You will be returned to the welcome screen

---

## 4. Home Dashboard

The home dashboard is the main hub of the app, accessible after login.

### 4.1 Top Section

- **App Logo** — Lost & Found BD branding at the top
- **Gear Icon** (top-right) — Access admin dashboard (if you have admin role)
- **Hero Search Bar** — Tap to search for items by keyword; includes an **"AI Smart Search"** button for advanced search

### 4.2 Category Filter Chips

Horizontal scrolling chips to filter the post feed:
- **All** — Show all posts (default)
- **Electronics** — Phones, laptops, tablets, etc.
- **Wallets** — Purses, cardholders, money bags
- **Pets** — Lost or found animals
- **Documents** — IDs, certificates, passports
- **Clothing** — Jackets, bags, accessories
- **Keys** — House keys, car keys, keychains
- **Others** — Miscellaneous items

Tap a chip to filter the feed to that category only.

### 4.3 AI Match Banner

A live banner that shows the highest-scoring AI match between your lost posts and other users' found posts. Tap it to view the matching item details.

### 4.4 Live Stats Row

Two real-time statistics cards:
- **Items Recovered** — Total items successfully returned through the platform
- **Active Reports** — Number of currently active lost/found reports

### 4.5 Interactive Map Preview

A small map card showing nearby items. Tap to open the full interactive radius search map.

### 4.6 Post Feed

A horizontally scrolling feed of recent posts. Each post card shows:
- **Image** — Primary photo of the item
- **Badge** — LOST (red) or FOUND (green) indicator
- **Title** — Item name/description
- **Location** — Where the item was lost or found
- **Reward Amount** — BDT reward offered (if applicable)

Tap any post card to view full item details.

### 4.7 Floating Action Button (FAB)

Tap the **"+"** button in the bottom-right corner to report a new lost or found item.

### 4.8 Bottom Navigation Bar

Four main navigation tabs:
1. **Home** — Return to the home dashboard
2. **Search** — Open search results
3. **Chat** — View your chat conversations
4. **Profile** — Access your profile and settings

---

## 5. Posting Lost & Found Items

### 5.1 Step 1 — Create Report

Tap the **"+"** FAB on the home screen to begin creating a report.

#### 5.1.1 Choose Report Type

Select one of the two options:
- **"I Lost Something"** — Report an item you have lost
- **"I Found Something"** — Report an item you have found

#### 5.1.2 Fill In Item Details

| Field | Description | Required |
|---|---|---|
| **Title** | Brief name for the item (e.g., "Samsung Galaxy S24 Ultra") | Yes |
| **Category** | Select from dropdown: Electronics, Wallets, Pets, Documents, Clothing, Keys, Others | Yes |
| **Description** | Detailed description including color, brand, distinguishing marks | Yes |
| **Location** | Where the item was lost/found — tap to open map picker | Yes |
| **Reward Amount (BDT)** | Optional reward you are willing to pay or expect | No |

#### 5.1.3 Upload Photos

- Tap **"Upload Images"** to select photos from your gallery
- You can upload up to **4 images**
- Use clear, well-lit photos for best AI matching results
- Tap the **X** icon on a photo to remove it

#### 5.1.4 Select Location

Tap the **location picker** button to open the map:
- **Tap on the map** to place a pin at the desired location
- Use the **search bar** to find specific addresses or areas
- **Preset locations** are available for common areas in Bangladesh:
  - Dhaka: Dhanmondi, DU Campus, Gulshan, Banani, Uttara, Mirpur, Farmgate, Shahbagh, Motijheel, Bashundhara, Mohammadpur, Lalmatia
  - Chattogram: GEC Circle
  - Sylhet: Zindabazar
- Tap **"Use GPS"** to auto-detect your current location
- Confirm the address and coordinates, then tap **"Confirm Location"**

#### 5.1.5 Preview & Publish

After filling in all fields, tap **"Preview & Publish"** to proceed to Step 2.

### 5.2 Step 2 — Preview & Confirm

Review your report preview:
- Image thumbnail
- Title, category, and report type (LOST/FOUND)
- Description text
- Selected location
- Reward amount

If everything looks correct, tap **"Publish Report to Feed"** to submit.

**What happens on publish:**
1. Images are uploaded to Cloudinary (cloud image storage)
2. Your report is saved to the database (Firestore)
3. You are redirected to the home dashboard
4. Your post appears in the feed for others to see
5. AI matching begins automatically to find potential matches

---

## 6. Viewing & Claiming Items

### 6.1 Item Details Screen

Tap any post in the feed to view full details:

- **Image Gallery** — Scroll through all uploaded photos
- **Badge** — LOST or FOUND indicator
- **Title & Category** — Item identification
- **Location** — Where the item was reported
- **Reward Card** — Amount offered (if applicable)
- **Description** — Full item description
- **Reporter Info** — Name and NID verification badge of the person who posted

### 6.2 Actions on Item Details

Depending on the situation, you may see:

| Button | When It Appears | Action |
|---|---|---|
| **"Claim This Item"** | Item is not yours and no claim submitted yet | Opens the claim submission form |
| **"View on Map"** | Always available | Opens the item location on the interactive map |
| **"Chat & Contact"** | If your claim is approved, or if you are the post owner | Opens private chat with the other party |

### 6.3 Claiming a Found Item

If you lost an item and someone has posted it as found:

1. Tap **"Claim This Item"** on the item details screen
2. Fill in the claim form:
   - **Full Name** — Your name
   - **Phone Number** — Contact number
   - **Email** — Email address
   - **Address** — Your address (tap GPS button for auto-fill)
   - **Claim Description** — Explain why this is your item and how you lost it
   - **Proof of Ownership** — Identifying details (serial number, unique marks, etc.)
   - **Reward Expectation (BDT)** — The reward amount you expect
   - **Proof Images** — Upload photos proving ownership (receipts, photos of the item before loss)
3. Tap **"Submit Claim"**
4. The claim is sent to the item owner for review
5. You will receive a notification when the owner responds

### 6.4 Owner Reviewing Claims

If someone claims your lost item:

1. Open the notification or go to **My Posts** → tap your post → view claims
2. Review the claimer's information and proof
3. Choose one of:
   - **Approve** — Accept the claim and open a private chat
   - **Reject** — Decline the claim (you can add a reason)

---

## 7. AI-Powered Features

### 7.1 AI Smart Search

Access via the search bar's **"AI Smart Search"** button on the home screen.

**Features:**
- **Natural Language Input** — Type in plain language (e.g., "blue Samsung phone lost in Uttara last week")
- **Voice Search** — Tap the microphone icon to speak your search query (simulated)
- **Category Filter** — Narrow results to specific item categories
- **Time Window** — Filter by when the item was lost/found
- **Search Radius** — Set a 1–50 km radius from your location
- **Minimum Reward** — Filter by reward amount (0–10,000 BDT)

Tap **"Search"** to see ranked results.

### 7.2 AI Image Scan

Access via the home screen or search area.

**How to use:**
1. Tap **"Upload or Capture Photo"**
2. Select an image from your gallery, or take a new photo with your camera
3. Tap **"Run Gemini AI Match"**
4. The AI scans the image for:
   - Visual features (color, shape, brand logos)
   - OCR text recognition (serial numbers, labels, text on the item)
5. Results are displayed with similarity percentages

### 7.3 AI Match Results

After running an AI scan, results are displayed as a ranked list:
- **Similarity Score** — Percentage match (e.g., 96%, 84%, 72%)
- **Item Details** — Image, title, location, date
- **Action** — Tap **"Claim / Chat"** to proceed with the matched item

### 7.4 AI Match Banner on Home

The home dashboard automatically displays a live AI match banner showing the best match between your lost posts and others' found items. Tap the banner to view details.

---

## 8. Chat & Messaging

### 8.1 Chat List

Access via the **Chat** tab in the bottom navigation bar.

- Lists all your active chat conversations
- Each chat shows:
  - **Post Title** — The item being discussed
  - **Last Message** — Most recent message preview
  - **Timestamp** — When the last message was sent
  - **Unread Count** — Number of unread messages (red badge)
- Tap any chat to open the conversation

**Note:** Chat rooms are automatically created when an item owner approves a claim.

### 8.2 Chat Conversation

Inside a chat room:

- **Message Bubbles** — Sent messages on the right (blue), received messages on the left (gray)
- **System Messages** — Notifications about claim status changes
- **Image Attachments** — Tap the camera/gallery icon to send photos
- **Text Input** — Type your message and tap **Send**

**Common Chat Actions:**
- Coordinate item handoff location and time
- Share additional proof of ownership
- Discuss reward payment details
- Confirm meeting arrangements

---

## 9. Recovery & Payment Flow

### 9.1 Claim Details & Live Location

Once a claim is approved, both parties can access the claim details screen:

1. **Status Header** — Shows current status: PENDING / APPROVED / REJECTED
2. **Claimer Profile** — Name and information of the person claiming
3. **Claim Description** — Why they believe the item is theirs
4. **Proof Images** — Photos provided as evidence
5. **Live Location Sharing:**
   - Both owner and finder can toggle GPS sharing
   - Real-time positions are shown on an OpenStreetMap view
   - Useful for coordinating safe item handoff at a public location

### 9.2 Dual Recovery Confirmation

The recovery process requires **both parties** to confirm:

1. **Owner confirms:** "I Received My Item" — Tap this button when you physically receive the item
2. **Finder confirms:** "I Successfully Returned This Item" — Tap this button when you hand over the item
3. Once both confirm, the recovery is marked as **completed** and you proceed to the recovery summary

### 9.3 Recovery Completed Screen

After both confirmations:
- **Item Summary** — Title and image of the recovered item
- **Claimer Name** — Who recovered the item
- **Reward Amount** — The agreed reward in BDT
- **Payment Status** — UNPAID / PAID / COMPLETED

**Actions available:**
- **"Pay Reward"** (Owner) — Proceed to payment
- **"Confirm Reward Received"** (Finder) — Confirm you received the payment
- **"Rate & Review User"** — Leave a rating for the other party

### 9.4 Reward Payment

When the owner pays the reward:

1. **Select Payment Method:**
   - bKash
   - Rocket
   - Nagad
2. **Enter Payment Details:**
   - Receiver Name
   - Phone Number
   - Transaction ID (from your payment app)
3. Tap **"Submit Payment"**
4. You will see a confirmation screen with the transaction details
5. The finder will be notified to confirm receipt

### 9.5 Rating & Review

After recovery, both parties can rate each other:

- **Overall Rating** — 5-star rating
- **Detailed Ratings** (slider-based):
  - Behaviour
  - Communication
  - Trustworthiness
  - Response Time
- **Recommendation** — Would you recommend this person?
- **Written Review** — Optional text review

Ratings contribute to the user's trust score and leaderboard position.

---

## 10. Interactive Map

### 10.1 Radius Search Map

Access via the map preview card on the home screen.

**Features:**
- **Your Location** — Blue pulsing marker showing your current GPS position
- **Post Markers:**
  - 🔴 Red markers — Lost items
  - 🟢 Green markers — Found items
  - 🟠 Amber markers — Resolved items
- **Radius Circle** — Adjustable overlay showing your search area

**Controls:**
- **Radius Slider** — Adjust from 0.5 km to 100 km
- **Quick Distance Chips** — Tap 1km, 2km, 5km, etc. for instant radius changes
- **Item Count** — Shows the number of items within the current radius
- **"List View"** — Switch to a list view of nearby items

**Interacting with Markers:**
- Tap any marker to see a preview card with item details
- Tap **"View Full Details & Claim"** to open the complete item screen

### 10.2 Selecting Locations for Posts

When creating a post, the location picker provides:
- **Tap to Pin** — Drop a pin anywhere on the map
- **Search** — Type an address or place name (powered by Nominatim geocoding)
- **Preset Locations** — Quick-select from 16 common Bangladesh locations
- **GPS Auto-Locate** — Instantly set the pin to your current position
- **Confirm** — Save the selected coordinates and address

---

## 11. Profile & Account

### 11.1 Profile Screen

Access via the **Profile** tab in the bottom navigation bar.

**Profile Header:**
- **Avatar** — Your profile photo
- **Display Name** — Your name
- **Email** — Your registered email
- **NID Verified Badge** — Blue checkmark if your NID is verified

**Quick Stats:**
- **Recoveries** — Number of items you have recovered/returned
- **Total Earned** — Total reward money earned in BDT
- **Your Rating** — Average star rating from other users

**Menu Options:**

| Menu Item | Description |
|---|---|
| **Edit Profile** | Update your name, phone, avatar, and location |
| **Recovery History** | View all your completed item recoveries |
| **Earnings & Wallet** | View earnings dashboard and transaction history |
| **Community Leaderboard** | See top contributors ranked by reward points |
| **My Reported Posts** | View all posts you have created |
| **Favorites** | View your saved/bookmarked items |
| **NID Verification** | Verify your Bangladesh National ID |
| **Police GD Integration** | Generate official Police General Diary documents |

### 11.2 Edit Profile

1. Tap **"Edit Profile"** from the profile menu
2. Update any of the following:
   - **Avatar** — Tap the camera icon to change your profile photo
   - **Full Name** — Edit your display name
   - **Phone Number** — Update your contact number
   - **Location** — Update your city/area
3. Tap **"Save Changes"**

### 11.3 Favorites

View items you have saved/bookmarked for later reference. Tap any item to view its full details.

### 11.4 History

View a log of your past activities on the platform, such as items recovered and points earned.

---

## 12. Leaderboard & Rewards

### 12.1 Community Leaderboard

Access via **Profile → Community Leaderboard**.

- **Top 3 Podium** — Gold (1st), Silver (2nd), Bronze (3rd) displayed with avatars and points
- **Remaining Ranks** — Listed in descending order by reward points
- Rankings are based on total reward points earned from successful recoveries

### 12.2 Rewards Wallet

Access via **Profile → Earnings & Wallet**.

**Dashboard:**
- **Total Balance** — Your current earnings in BDT
- **Today's Earnings** — Amount earned today
- **Monthly Earnings** — Amount earned this month
- **Lifetime Earnings** — Total earned since account creation

**Transaction History:**
- Each transaction shows: description, amount (+ for received, − for paid), date, and status badge
- Status badges: PAID, PENDING, COMPLETED

**Withdrawals:**
- Cash out earnings via bKash or Nagad (available in the wallet screen)

---

## 13. Notifications

Access via the bell icon or the notifications screen.

**Notification Types:**

| Icon | Type | Description |
|---|---|---|
| 📋 | **Claim** | Someone claimed your item, or your claim was approved/rejected |
| 🤖 | **AI Match** | AI found a potential match for your lost item |
| 💬 | **Chat** | New message in a chat conversation |
| 💰 | **Reward** | Payment sent or received |

**Interacting with Notifications:**
- Tap a notification to navigate to the relevant screen (claim details, chat, AI matches)
- Unread notifications are highlighted
- The app sends real-time push notifications via Firebase Cloud Messaging

---

## 14. NID Verification & Police GD

### 14.1 NID Verification

Access via **Profile → NID Verification**.

**Benefits of NID Verification:**
- Blue trust badge on your profile
- Higher credibility when claiming items
- Eligibility for Police GD generation

**Steps:**
1. Enter your **NID Number** (10 or 17 digits, as printed on your Bangladesh National ID card)
2. Enter your **Date of Birth** (as on NID)
3. Upload a photo of the **NID card front**
4. Upload a photo of the **NID card back**
5. Tap **"Submit for NID Verification"**
6. Your verification will be processed

### 14.2 Police GD Integration

Access via **Profile → Police GD Integration**.

This feature auto-generates a Bangladesh Police General Diary (GD) document for your lost item report.

**Steps:**
1. Enter the **Nearest Police Thana** (police station) name
2. Enter **IMEI/Serial/Document Reference** number (if applicable)
3. Enter a **Detailed Statement of Occurrence** — describe when, where, and how you lost the item
4. Tap **"Generate Official GD Document (PDF)"**
5. The app generates a PDF in Bangladesh Police e-GD format
6. You can save or share the PDF for filing with local police

---

## 15. Settings

Access via **Profile → Settings**.

| Setting | Description |
|---|---|
| **Theme Mode** | Switch between System Default, Light Mode, or Dark Mode |
| **Push Notifications** | Toggle push notifications on or off |
| **Help Center & FAQs** | Open the help center with frequently asked questions |
| **Privacy & Terms** | View the privacy policy and terms of service |
| **Interactive Shader Demo** | View a visual shader animation demo |
| **Empty & Offline State** | View a demo of the offline/empty state screen |
| **About** | View app information, version, and mission statement |

### 15.1 Help Center

Contains expandable FAQ sections:
1. **How does AI Visual & Text Matching work?** — Explains the Gemini AI scanning and matching process
2. **How to claim a lost item safely** — Safety tips for item handoff
3. **How does Bangladesh Police E-GD integration work?** — Explains the Police GD generation feature

### 15.2 Privacy & Terms

Covers:
- **Data Privacy** — How your personal data is collected and used
- **Report Accuracy** — Your responsibility for truthful reporting
- **Location & GPS** — How location data is used for matching
- **Rewards & Payments** — Payment terms and conditions

---

## 16. Role-Based Dashboards

### 16.1 Admin Dashboard

**Access:** Tap the gear icon on the home screen (admin role required).

**Features:**
- **System Overview** — Total users, reports filed, AI matches, flagged/fraud accounts
- **Specialized Portals** — Links to university and office dashboards
- **User Management** — Monitor and manage platform users

### 16.2 University Dashboard

**Access:** Via admin dashboard → University Portal.

**Features:**
- **Campus Lost & Found Portal** — University-specific item management
- **Campus Logs** — Track items lost and found within the university
- Example: "Dhaka University Campus Desk" showing active campus items

### 16.3 Office Dashboard

**Access:** Via admin dashboard → Office Portal.

**Features:**
- **Corporate Office Portal** — Office/organization-specific item management
- **Visitor Items** — Track unclaimed items from office visitors
- Example: "Gulshan Hub Security Desk" showing unclaimed visitor items

---

## 17. Troubleshooting

### Common Issues

| Issue | Solution |
|---|---|
| **App won't load / offline** | Check your internet connection. The app requires Wi-Fi or mobile data. An offline screen will appear when connectivity is lost. |
| **Photos won't upload** | Ensure camera/gallery permissions are granted. Check your internet connection. Try selecting a smaller image. |
| **Location not detecting** | Ensure GPS is enabled in your device settings. Grant location permission to the app. Move to an area with clear sky view. |
| **Notifications not appearing** | Check that push notifications are enabled in app settings and your device notification settings. |
| **Login fails** | Verify your email and password. Use "Forgot Password" to reset if needed. Ensure you have internet connectivity. |
| **Chat messages not sending** | Check your internet connection. The chat requires an active connection to send and receive messages. |
| **Map not loading** | The map uses OpenStreetMap and requires an internet connection. Check connectivity and try zooming in/out. |
| **AI scan returns no results** | AI matching works best with clear, well-lit photos. Try uploading a different image with the item clearly visible. |
| **Payment verification pending** | Payment confirmations require the finder to verify receipt. Contact the other party via chat if needed. |

### Permissions Required

| Permission | Purpose | Required? |
|---|---|---|
| **Camera** | Taking photos for item reports | Optional (can use gallery only) |
| **Gallery/Storage** | Selecting photos from device | Optional (can use camera only) |
| **Location/GPS** | Location picking and live sharing | Optional (can enter manually) |
| **Notifications** | Push notifications for claims, chat, AI matches | Optional (can disable) |

### Contact Support

For additional help:
- Open **Settings → Help Center & FAQs** for common questions
- Open **Settings → Privacy & Terms** for policy information
- Visit the app's support page at the developer's website

---

## Appendix: Data Models Reference

| Model | Description |
|---|---|
| **PostModel** | Core lost/found item report with title, description, category, type, location, images, reward, and status |
| **UserModel** | User profile with name, email, phone, role, NID verification status, reward points, and trust score |
| **ClaimModel** | Item claim request with proof of ownership, status, recovery confirmation, and live location data |
| **ChatRoomModel** | Private 1-to-1 chat room created from approved claims |
| **ChatMessageModel** | Individual chat messages with text, images, and timestamps |
| **RatingModel** | Multi-criteria user rating (behavior, communication, trustworthiness, response time) |
| **PaymentModel** | Reward payment records with method, amount, transaction ID, and status |
| **HistoryModel** | Archived completed recoveries with poster/finder info and payment status |
| **WalletModel** | User earnings tracker (today, monthly, lifetime) |

---

*This user manual covers all features of Lost & Found BD version 1.0.0. For the latest updates, check the app's settings or the developer's release notes.*
