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

      // Auth / Welcome
      'welcome_tagline':
          'Reconnecting you with what matters most, anywhere in Bangladesh.',
      'continue_with_google': 'Continue with Google',
      'continue_with_phone': 'Continue with Phone',
      'login_with_email': 'Login with Email',
      'dont_have_account': "Don't have an account? ",
      'register': 'Register',
      'register_now': 'Register Now',
      'or': 'OR',
      'or_continue_with': 'OR CONTINUE WITH',
      'terms_notice':
          'By continuing, you agree to our Terms of Service & Privacy Policy.',

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

      // Register
      'create_account': 'Create Account',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'confirm_password': 'Confirm Password',
      'already_have_account': 'Already have an account? ',
      'sign_in_link': 'Sign In',

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

      // Home / Dashboard
      'home': 'Home',
      'search_items': 'Search items...',
      'all': 'All',
      'lost': 'Lost',
      'found': 'Found',
      'no_posts': 'No posts yet.',

      // Post types
      'post_lost': 'Lost',
      'post_found': 'Found',
      'report_lost': 'Report Lost',
      'report_found': 'Report Found',

      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'my_posts': 'My Posts',
      'sign_out': 'Sign Out',
      'reward_points': 'Reward Points',

      // Notifications
      'notifications': 'Notifications',
      'no_notifications': 'No notifications yet.',

      // Chat
      'chat': 'Chat',
      'send_message': 'Send a message...',
      'messages': 'Messages',

      // Favourites
      'favourites': 'Favourites',
      'no_favourites': 'No favourites yet.',

      // Misc
      'see_all': 'See All',
      'recent_posts': 'Recent Posts',
      'item_details': 'Item Details',
      'location': 'Location',
      'date': 'Date',
      'description': 'Description',
      'category': 'Category',
      'contact': 'Contact',
      'reward': 'Reward',
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

      // Auth / Welcome
      'welcome_tagline': 'বাংলাদেশের যেকোনো প্রান্তে আপনার হারানো জিনিস ফিরিয়ে দিতে প্রস্তুত।',
      'continue_with_google': 'গুগল দিয়ে চালিয়ে যান',
      'continue_with_phone': 'ফোন দিয়ে চালিয়ে যান',
      'login_with_email': 'ইমেইল দিয়ে লগইন করুন',
      'dont_have_account': 'একাউন্ট নেই? ',
      'register': 'নিবন্ধন করুন',
      'register_now': 'এখনই নিবন্ধন করুন',
      'or': 'অথবা',
      'or_continue_with': 'অথবা চালিয়ে যান',
      'terms_notice': 'চালিয়ে যাওয়ার মাধ্যমে আপনি আমাদের সেবার শর্ত ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।',

      // Login
      'welcome_back': 'স্বাগতম',
      'please_enter_details': 'সাইন ইন করতে আপনার তথ্য দিন।',
      'email_address': 'ইমেইল ঠিকানা',
      'email_hint': 'নাম@example.com',
      'password': 'পাসওয়ার্ড',
      'remember_me': 'মনে রাখুন',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'sign_in': 'সাইন ইন',
      'google_sign_in': 'গুগল সাইন-ইন',
      'email_invalid': 'সঠিক ইমেইল দিন',
      'password_too_short': 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',

      // Register
      'create_account': 'একাউন্ট তৈরি করুন',
      'full_name': 'পুরো নাম',
      'phone_number': 'ফোন নম্বর',
      'confirm_password': 'পাসওয়ার্ড নিশ্চিত করুন',
      'already_have_account': 'ইতিমধ্যে একাউন্ট আছে? ',
      'sign_in_link': 'সাইন ইন করুন',

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

      // Home / Dashboard
      'home': 'হোম',
      'search_items': 'আইটেম খুঁজুন...',
      'all': 'সব',
      'lost': 'হারানো',
      'found': 'পাওয়া',
      'no_posts': 'এখনো কোনো পোস্ট নেই।',

      // Post types
      'post_lost': 'হারানো',
      'post_found': 'পাওয়া',
      'report_lost': 'হারানো রিপোর্ট করুন',
      'report_found': 'পাওয়া রিপোর্ট করুন',

      // Profile
      'profile': 'প্রোফাইল',
      'edit_profile': 'প্রোফাইল সম্পাদনা',
      'my_posts': 'আমার পোস্ট',
      'sign_out': 'সাইন আউট',
      'reward_points': 'পুরস্কার পয়েন্ট',

      // Notifications
      'notifications': 'নোটিফিকেশন',
      'no_notifications': 'এখনো কোনো নোটিফিকেশন নেই।',

      // Chat
      'chat': 'চ্যাট',
      'send_message': 'একটি বার্তা পাঠান...',
      'messages': 'বার্তা',

      // Favourites
      'favourites': 'পছন্দের তালিকা',
      'no_favourites': 'এখনো কোনো পছন্দ নেই।',

      // Misc
      'see_all': 'সব দেখুন',
      'recent_posts': 'সাম্প্রতিক পোস্ট',
      'item_details': 'আইটেমের বিবরণ',
      'location': 'অবস্থান',
      'date': 'তারিখ',
      'description': 'বিবরণ',
      'category': 'বিভাগ',
      'contact': 'যোগাযোগ',
      'reward': 'পুরস্কার',
    },
  };

  /// Translate a key. Falls back to the key itself if not found.
  String t(String key) {
    final langCode = locale.languageCode;
    return _translations[langCode]?[key] ??
        _translations['en']?[key] ??
        key;
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
