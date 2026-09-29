import 'package:flutter/material.dart';

/// Supported locales for the app.
enum AppLanguage { english, bangla }

/// Simple in-app localization helper.
/// Usage: AppLocalizations.of(context).t('key')
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // General
      'app_name': 'Lost & Found BD',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'yes': 'Yes',
      'no': 'No',
      'back': 'Back',
      'search': 'Search',
      'submit': 'Submit',
      'close': 'Close',
      'retry': 'Retry',
      'see_all': 'See All',
      'or': 'OR',
      'edit': 'Edit',
      'continue_btn': 'Continue',

      // Splash & Welcome
      'splash_tagline': 'Connecting you back to what matters...',
      'welcome_tagline':
          'Reconnecting you with what matters most, anywhere in Bangladesh.',
      'continue_with_google': 'Continue with Google',
      'continue_with_phone': 'Continue with Phone',
      'login_with_email': 'Login with Email',
      'dont_have_account': "Don't have an account? ",
      'register': 'Register',
      'register_now': 'Register Now',
      'or_continue_with': 'OR CONTINUE WITH',
      'terms_notice':
          'By continuing, you agree to our Terms of Service & Privacy Policy.',
      'phone_verification': 'Phone Number Verification',
      'get_started_email': 'Get Started with Email',
      'new_here': 'New here? ',

      // Login
      'welcome_back': 'Welcome Back',
      'please_enter_details': 'Please enter your details to sign in.',
      'email_address': 'Email Address',
      'email_hint': 'name@example.com',
      'password': 'Password',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'google_sign_in': 'Google Sign-In',
      'email_invalid': 'Enter a valid email',
      'password_too_short': 'Password must be at least 6 chars',
      'login_subtitle': 'Connecting lost belongings with their owners.',

      // Register
      'create_account': 'Create Account',
      'register_subtitle': 'Join Lost & Found BD community today.',
      'full_name': 'Full Name',
      'full_name_hint': 'e.g. Tanvir Ahmed',
      'phone_number': 'Phone Number',
      'confirm_password': 'Confirm Password',
      'already_have_account': 'Already have an account? ',
      'sign_in_link': 'Sign In',
      'agree_terms': 'I agree to the Terms of Service & Privacy Policy',
      'register_account': 'Register Account',
      'enter_full_name': 'Enter your full name',
      'passwords_dont_match': 'Passwords do not match',
      'min_6_chars': 'Minimum 6 characters',

      // Forgot Password
      'reset_password': 'Reset Password',
      'reset_instructions':
          'Enter your registered email address to receive password reset instructions.',
      'send_reset_link': 'Send Reset Link',
      'back_to_login': 'Back to Login',
      'check_email': 'Check your email for reset instructions',

      // Settings
      'app_settings': 'App Settings',
      'theme_mode': 'Theme Mode',
      'language': 'Language',
      'language_subtitle': 'App display language',
      'push_notifications': 'Push Notifications',
      'notifications_subtitle': 'AI matches & chat alerts',
      'help_center': 'Help Center & FAQs',
      'privacy_terms': 'Privacy & Terms',
      'shader_demo': 'Interactive Shader Demo',
      'empty_offline': 'Empty & Offline App State',
      'about': 'About Lost & Found BD',
      'account_actions': 'Account Actions',
      'delete_account': 'Delete Account',
      'delete_account_subtitle':
          'Permanently remove your account and user profile',
      'theme_system': 'System',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'lang_english': 'English',
      'lang_bangla': 'বাংলা',
      'delete_account_dialog_title': 'Delete Account?',
      'delete_account_dialog_content':
          'This action is permanent and cannot be undone. Your profile data and account will be permanently deleted.',

      // Home / Dashboard
      'home': 'Home',
      'search_items': 'Search items...',
      'search_items_hint': 'Search keys, pets, wallets, documents...',
      'all': 'All',
      'lost': 'Lost',
      'found': 'Found',
      'no_posts': 'No posts yet.',
      'electronics': 'Electronics',
      'wallets': 'Wallets',
      'pets': 'Pets',
      'documents': 'Documents',
      'clothing': 'Clothing',
      'keys': 'Keys',
      'others': 'Others',
      'items_recovered': 'Items Recovered',
      'active_reports': 'Active Reports',
      'report_item': 'Report Item',
      'explore_map': 'Explore Live Recovery Map',
      'tap_map': 'Tap to search items nearby on interactive map',
      'ai_smart_search': 'AI Smart Search',
      'recent_activity': 'Recent Activity',

      // Profile
      'profile': 'Profile',
      'my_profile': 'My Profile',
      'nid_verified_member': 'NID Verified Member',
      'recoveries': 'Recoveries',
      'returns': 'Returns',
      'trust_score': 'Trust Score',
      'user_rating': 'User Rating',
      'reviews': 'reviews',
      'recent_ratings': 'Recent Ratings & Reviews:',
      'edit_profile': 'Edit Profile',
      'recovery_history': 'Recovery History Archive',
      'recovery_history_sub': 'View completed & returned items',
      'earnings_wallet': 'Earnings & Wallet',
      'earnings_wallet_sub': 'Reward earnings & transaction history',
      'earned': 'Earned',
      'leaderboard': 'Community Leaderboard',
      'leaderboard_sub': 'Top recovery heroes & rankings',
      'my_reported_posts': 'My Reported Posts',
      'favorites': 'Favorites',
      'saved_favorites': 'Saved Favorites',
      'nid_verification': 'NID Verification',
      'police_gd': 'Police GD Integration',
      'sign_out': 'Sign Out',
      'reward_points': 'Reward Points',

      // Notifications
      'notifications': 'Notifications',
      'no_notifications': 'No notifications yet.',
      'notification': 'Notification',
      'claim': 'CLAIM',

      // Chat
      'chat': 'Chat',
      'messages': 'Messages',
      'messages_active_chats': 'Messages & Active Chats',
      'no_active_conversations': 'No active conversations yet.',
      'approved_claims_chat':
          'Approved claims will open private 1-to-1 chat rooms here.',
      'send_message': 'Send a message...',

      // Posts & Reports
      'create_report': 'Create Report',
      'report_lost': 'Report Lost',
      'report_found': 'Report Found',
      'report_lost_or_found': 'Report Lost or Found Item',
      'step_1_of_2': 'Step 1 of 2: Item Details & Photos',
      'i_lost_something': 'I Lost Something',
      'i_found_something': 'I Found Something',
      'title': 'Title',
      'title_hint': 'e.g. Silver iPhone 14 Pro with blue case',
      'enter_title': 'Enter a title',
      'category': 'Category',
      'location': 'Location',
      'reward_amount': 'Reward Amount (BDT)',
      'description': 'Description',
      'description_hint':
          'Provide identifying marks, serial numbers, exact location details...',
      'add_photos': 'Add Photos',
      'no_posts_yet': 'No Posts Yet',
      'your_posts_appear_here': 'Your lost and found posts will appear here.',
      'create_post': 'Create Post',
      'edit_post': 'Edit Post',
      'delete_post': 'Delete Post',
      'status': 'Status',
      'item_details': 'Item Details',
      'contact': 'Contact',
      'date': 'Date',
      'reward': 'Reward',
      'submit_claim': 'Submit Claim',
      'claim_details': 'Claim Details',

      // Search
      'search_results': 'Search Results',
      'no_matching_items': 'No matching items found',
      'adjust_filters': 'Try adjusting your search terms or filters',
    },

    'bn': {
      // General
      'app_name': 'হারানো ও পাওয়া BD',
      'ok': 'ঠিক আছে',
      'cancel': 'বাতিল',
      'save': 'সংরক্ষণ করুন',
      'delete': 'মুছুন',
      'confirm': 'নিশ্চিত করুন',
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'success': 'সফল',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'back': 'পেছনে',
      'search': 'খুঁজুন',
      'submit': 'জমা দিন',
      'close': 'বন্ধ করুন',
      'retry': 'আবার চেষ্টা করুন',
      'see_all': 'সব দেখুন',
      'or': 'অথবা',
      'edit': 'সম্পাদনা',
      'continue_btn': 'চালিয়ে যান',

      // Splash & Welcome
      'splash_tagline': 'আপনার প্রয়োজনীয় জিনিসের সাথে আপনাকে যুক্ত করা হচ্ছে...',
      'welcome_tagline':
          'বাংলাদেশের যেকোনো প্রান্তে আপনার হারানো জিনিস ফিরিয়ে দিতে প্রস্তুত।',
      'continue_with_google': 'গুগল দিয়ে চালিয়ে যান',
      'continue_with_phone': 'ফোন দিয়ে চালিয়ে যান',
      'login_with_email': 'ইমেইল দিয়ে লগইন করুন',
      'dont_have_account': 'একাউন্ট নেই? ',
      'register': 'নিবন্ধন করুন',
      'register_now': 'এখনই নিবন্ধন করুন',
      'or_continue_with': 'অথবা চালিয়ে যান',
      'terms_notice':
          'চালিয়ে যাওয়ার মাধ্যমে আপনি আমাদের সেবার শর্ত ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।',
      'phone_verification': 'ফোন নম্বর যাচাইকরণ',
      'get_started_email': 'ইমেইল দিয়ে শুরু করুন',
      'new_here': 'নতুন এসেছেন? ',

      // Login
      'welcome_back': 'স্বাগতম',
      'please_enter_details': 'সাইন ইন করতে আপনার তথ্য দিন।',
      'email_address': 'ইমেইল ঠিকানা',
      'email_hint': 'name@example.com',
      'password': 'পাসওয়ার্ড',
      'remember_me': 'মনে রাখুন',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'sign_in': 'সাইন ইন',
      'google_sign_in': 'গুগল সাইন-ইন',
      'email_invalid': 'সঠিক ইমেইল দিন',
      'password_too_short': 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
      'login_subtitle': 'হারানো জিনিসপত্র তাদের মালিকের সাথে যুক্ত করা হচ্ছে।',

      // Register
      'create_account': 'একাউন্ট তৈরি করুন',
      'register_subtitle': 'আজই Lost & Found BD কমিউনিটিতে যোগ দিন।',
      'full_name': 'পুরো নাম',
      'full_name_hint': 'উদা: তানভীর আহমেদ',
      'phone_number': 'ফোন নম্বর',
      'confirm_password': 'পাসওয়ার্ড নিশ্চিত করুন',
      'already_have_account': 'ইতিমধ্যে একাউন্ট আছে? ',
      'sign_in_link': 'সাইন ইন করুন',
      'agree_terms': 'আমি সেবার শর্তাবলী ও গোপনীয়তা নীতি মেনে নিচ্ছি',
      'register_account': 'নিবন্ধন সম্পন্ন করুন',
      'enter_full_name': 'আপনার পুরো নাম লিখুন',
      'passwords_dont_match': 'পাসওয়ার্ড দুটি মিলছে না',
      'min_6_chars': 'কমপক্ষে ৬ অক্ষর',

      // Forgot Password
      'reset_password': 'পাসওয়ার্ড রিসেট করুন',
      'reset_instructions':
          'পাসওয়ার্ড রিসেট লিংক পেতে আপনার নিবন্ধিত ইমেইল ঠিকানা দিন।',
      'send_reset_link': 'রিসেট লিংক পাঠান',
      'back_to_login': 'লগইনে ফিরে যান',
      'check_email': 'পাসওয়ার্ড রিসেট নির্দেশের জন্য আপনার ইমেইল চেক করুন',

      // Settings
      'app_settings': 'অ্যাপ সেটিংস',
      'theme_mode': 'থিম মোড',
      'language': 'ভাষা',
      'language_subtitle': 'অ্যাপের প্রদর্শন ভাষা',
      'push_notifications': 'পুশ নোটিফিকেশন',
      'notifications_subtitle': 'AI মিল এবং চ্যাট সতর্কতা',
      'help_center': 'সাহায্য কেন্দ্র ও FAQ',
      'privacy_terms': 'গোপনীয়তা ও শর্তাবলী',
      'shader_demo': 'ইন্টারেক্টিভ শেডার ডেমো',
      'empty_offline': 'খালি ও অফলাইন অ্যাপ অবস্থা',
      'about': 'Lost & Found BD সম্পর্কে',
      'account_actions': 'একাউন্ট কার্যক্রম',
      'delete_account': 'একাউন্ট মুছুন',
      'delete_account_subtitle': 'আপনার একাউন্ট এবং প্রোফাইল স্থায়ীভাবে মুছুন',
      'theme_system': 'সিস্টেম',
      'theme_light': 'লাইট',
      'theme_dark': 'ডার্ক',
      'lang_english': 'English',
      'lang_bangla': 'বাংলা',
      'delete_account_dialog_title': 'একাউন্ট মুছবেন?',
      'delete_account_dialog_content':
          'এই কাজটি স্থায়ী এবং পরিবর্তন করা যাবে না। আপনার প্রোফাইল ও একাউন্ট মুছে ফেলা হবে।',

      // Home / Dashboard
      'home': 'হোম',
      'search_items': 'আইটেম খুঁজুন...',
      'search_items_hint': 'চাবি, পোষা প্রাণী, মানিব্যাগ, দলিল খুঁজুন...',
      'all': 'সব',
      'lost': 'হারানো',
      'found': 'পাওয়া',
      'no_posts': 'এখনো কোনো পোস্ট নেই।',
      'electronics': 'ইলেকট্রনিক্স',
      'wallets': 'মানিব্যাগ',
      'pets': 'পোষা প্রাণী',
      'documents': 'নথিপত্র',
      'clothing': 'পোশাক',
      'keys': 'চাবি',
      'others': 'অন্যান্য',
      'items_recovered': 'উদ্ধারকৃত আইটেম',
      'active_reports': 'সক্রিয় রিপোর্ট',
      'report_item': 'রিপোর্ট করুন',
      'explore_map': 'লাইভ রিকভারি ম্যাপ দেখুন',
      'tap_map': 'কাছাকাছি আইটেম খুঁজতে ম্যাপে ট্যাপ করুন',
      'ai_smart_search': 'AI স্মার্ট অনুসন্ধান',
      'recent_activity': 'সাম্প্রতিক কার্যক্রম',

      // Profile
      'profile': 'প্রোফাইল',
      'my_profile': 'আমার প্রোফাইল',
      'nid_verified_member': 'জাতীয় পরিচয়পত্র যাচাইকৃত সদস্য',
      'recoveries': 'উদ্ধার',
      'returns': 'ফেরত',
      'trust_score': 'ট্রাস্ট স্কোর',
      'user_rating': 'ব্যবহারকারী রেটিং',
      'reviews': 'মতামত',
      'recent_ratings': 'সাম্প্রতিক রেটিং ও পর্যালোচনা:',
      'edit_profile': 'প্রোফাইল সম্পাদনা',
      'recovery_history': 'রিকভারি ইতিহাস আর্কাইভ',
      'recovery_history_sub': 'সম্পন্ন ও ফেরত আইটেম দেখুন',
      'earnings_wallet': 'উপার্জন ও ওয়ালেট',
      'earnings_wallet_sub': 'পুরস্কার আয় ও লেনদেনের ইতিহাস',
      'earned': 'উপার্জন',
      'leaderboard': 'কমিউনিটি লিডারবোর্ড',
      'leaderboard_sub': 'শীর্ষ উদ্ধারকারী ও র‍্যাংকিং',
      'my_reported_posts': 'আমার রিপোর্টকৃত পোস্ট',
      'favorites': 'পছন্দের তালিকা',
      'saved_favorites': 'সংরক্ষিত পছন্দের তালিকা',
      'nid_verification': 'জাতীয় পরিচয়পত্র যাচাই',
      'police_gd': 'পুলিশ জিডি সেবা',
      'sign_out': 'সাইন আউট',
      'reward_points': 'পুরস্কার পয়েন্ট',

      // Notifications
      'notifications': 'বিজ্ঞপ্তি',
      'no_notifications': 'এখনো কোনো বিজ্ঞপ্তি নেই।',
      'notification': 'বিজ্ঞপ্তি',
      'claim': 'দাবি',

      // Chat
      'chat': 'চ্যাট',
      'messages': 'বার্তা',
      'messages_active_chats': 'বার্তা ও সক্রিয় চ্যাট',
      'no_active_conversations': 'এখনো কোনো কথোপকথন নেই।',
      'approved_claims_chat':
          'অনুমোদিত দাবিগুলো এখানে ব্যক্তিগত ১-টু-১ চ্যাট খুলবে।',
      'send_message': 'একটি বার্তা পাঠান...',

      // Posts & Reports
      'create_report': 'রিপোর্ট তৈরি করুন',
      'report_lost': 'হারানো রিপোর্ট করুন',
      'report_found': 'পাওয়া রিপোর্ট করুন',
      'report_lost_or_found': 'হারানো বা পাওয়া আইটেম রিপোর্ট করুন',
      'step_1_of_2': 'ধাপ ১/২: আইটেমের বিবরণ ও ছবি',
      'i_lost_something': 'আমি কিছু হারিয়েছি',
      'i_found_something': 'আমি কিছু পেয়েছি',
      'title': 'শিরোনাম',
      'title_hint': 'উদা: সিলভার আইফোন ১৪ প্রো নীল কভার সহ',
      'enter_title': 'একটি শিরোনাম লিখুন',
      'category': 'বিভাগ',
      'location': 'অবস্থান',
      'reward_amount': 'পুরস্কারের পরিমাণ (টাকা)',
      'description': 'বিবরণ',
      'description_hint':
          'শনাক্তকরণ চিহ্ন, সিরিয়াল নম্বর, সঠিক অবস্থানের বিবরণ দিন...',
      'add_photos': 'ছবি যোগ করুন',
      'no_posts_yet': 'এখনো কোনো পোস্ট নেই',
      'your_posts_appear_here': 'আপনার হারানো ও পাওয়া পোস্টগুলো এখানে দেখা যাবে।',
      'create_post': 'পোস্ট তৈরি করুন',
      'edit_post': 'পোস্ট সম্পাদনা',
      'delete_post': 'পোস্ট মুছুন',
      'status': 'অবস্থা',
      'item_details': 'আইটেমের বিবরণ',
      'contact': 'যোগাযোগ',
      'date': 'তারিখ',
      'reward': 'পুরস্কার',
      'submit_claim': 'দাবি জমা দিন',
      'claim_details': 'দাবির বিবরণ',

      // Search
      'search_results': 'অনুসন্ধানের ফলাফল',
      'no_matching_items': 'মিল থাকা কোনো আইটেম পাওয়া যায়নি',
      'adjust_filters': 'অনুসন্ধানের শব্দ বা ফিল্টার পরিবর্তন করে দেখুন',
    },
  };

  bool get isBangla => locale.languageCode == 'bn';

  /// Translate a key. If a translated category exists, maps it; falls back to the key itself.
  String t(String key) {
    final langCode = locale.languageCode;
    return _translations[langCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  /// Helper to translate a category name (e.g., 'Electronics' -> 'ইলেকট্রনিক্স')
  String translateCategory(String cat) {
    final lower = cat.toLowerCase();
    return t(lower);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
