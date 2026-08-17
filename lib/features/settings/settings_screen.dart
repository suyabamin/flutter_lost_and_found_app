import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeletingAccount = false;

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authenticated user found.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 1. Initial Confirmation Dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. Your profile data and account will be permanently deleted.',
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
            child: const Text('Delete Account'),
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
          ScaffoldMessenger.of(context).showSnackBar(
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
      print('Firestore delete user data notice: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
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
                    title: const Text('Theme Mode'),
                    subtitle: Text(themeMode.name.toUpperCase()),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(themeModeProvider.notifier).state = val;
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
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
                    title: const Text('Push Notifications'),
                    subtitle: const Text('AI matches & chat alerts'),
                    value: true,
                    onChanged: (val) {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Help Center & FAQs'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/help'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Privacy & Terms'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy-terms'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.gradient_outlined,
                      color: Colors.purple,
                    ),
                    title: const Text('Interactive Shader Demo'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/shader'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.wifi_off_outlined,
                      color: Colors.orange,
                    ),
                    title: const Text('Empty & Offline App State'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/empty-offline'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('About Lost & Found BD'),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Account Actions',
                      style: TextStyle(
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
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently remove your account and user profile',
                      style: TextStyle(fontSize: 12),
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
