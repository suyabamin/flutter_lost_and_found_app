import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeletingAccount = false;

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.isBangla ? 'কোনো প্রমাণীকৃত ব্যবহারকারী পাওয়া যায়নি।' : 'No authenticated user found.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 1. Initial Confirmation Dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('delete_account_dialog_title')),
        content: Text(
          l10n.t('delete_account_dialog_content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('delete_account')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);

    try {
      await _executeAccountDeletion(currentUser.uid);
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        // Handle re-authentication requirement
        await _handleReauthenticationAndDelete(currentUser.uid);
      } else {
        if (mounted) {
          setState(() => _isDeletingAccount = false);
          final messenger = ScaffoldMessenger.maybeOf(this.context);
          messenger?.showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete account: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _executeAccountDeletion(String uid) async {
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    // 1. Delete user profile document from Firestore
    try {
      await firestoreService.deleteUserData(uid);
    } catch (e) {
      debugPrint('Firestore delete user data notice: $e');
    }

    // 2. Delete Firebase Authentication account
    await authService.deleteAuthAccount();

    // 3. Sign out and redirect
    await authService.signOut();

    if (mounted) {
      setState(() => _isDeletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted.'),
          backgroundColor: Colors.orange,
        ),
      );
      context.go('/welcome');
    }
  }

  Future<void> _handleReauthenticationAndDelete(String uid) async {
    final authService = ref.read(authServiceProvider);
    final isGoogleUser =
        authService.currentUser?.providerData.any(
          (p) => p.providerId == 'google.com',
        ) ??
        false;

    if (isGoogleUser) {
      // Re-authenticate with Google
      final bool? proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Re-authentication Required'),
          content: const Text(
            'For security, please sign in with Google again to confirm account deletion.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign In with Google'),
            ),
          ],
        ),
      );

      if (proceed == true && mounted) {
        try {
          await authService.reauthenticateGoogle();
          await _executeAccountDeletion(uid);
        } catch (e) {
          if (mounted) {
            setState(() => _isDeletingAccount = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Re-authentication failed: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    } else {
      // Re-authenticate with Password
      final passwordController = TextEditingController();
      final bool? proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Re-authentication Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to confirm deletion:'),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm & Delete'),
            ),
          ],
        ),
      );

      if (proceed == true && mounted) {
        try {
          await authService.reauthenticateEmailPassword(
            passwordController.text.trim(),
          );
          await _executeAccountDeletion(uid);
        } catch (e) {
          if (mounted) {
            setState(() => _isDeletingAccount = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Re-authentication failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('app_settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _isDeletingAccount ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('theme_mode')),
                    subtitle: Text(themeMode.name.toUpperCase()),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(val);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(l10n.t('theme_system')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(l10n.t('theme_light')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(l10n.t('theme_dark')),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // ── Language Selector ──────────────────────────────
                  ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('language')),
                    subtitle: Text(l10n.t('language_subtitle')),
                    trailing: DropdownButton<Locale>(
                      value: locale,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(localeProvider.notifier).setLocale(val);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇬🇧  '),
                              Text(l10n.t('lang_english')),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: const Locale('bn'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇧🇩  '),
                              Text(l10n.t('lang_bangla')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('push_notifications')),
                    subtitle: Text(l10n.t('notifications_subtitle')),
                    value: true,
                    onChanged: (val) {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('help_center')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/help'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('privacy_terms')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy-terms'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.gradient_outlined,
                      color: Colors.purple,
                    ),
                    title: Text(l10n.t('shader_demo')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/shader'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.wifi_off_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(l10n.t('empty_offline')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/empty-offline'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.t('about')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone Section
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      l10n.t('account_actions'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      l10n.t('delete_account'),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      l10n.t('delete_account_subtitle'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: _isDeletingAccount
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.error,
                          ),
                    onTap: _isDeletingAccount
                        ? null
                        : () => _confirmAndDeleteAccount(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
