import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
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
                    leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
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
                        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                      ],
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('AI matches & chat alerts'),
                    value: true,
                    onChanged: (val) {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: const Text('Help Center & FAQs'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/help'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: const Text('Privacy & Terms'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy-terms'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.gradient_outlined, color: Colors.purple),
                    title: const Text('Interactive Shader Demo'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/shader'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.wifi_off_outlined, color: Colors.orange),
                    title: const Text('Empty & Offline App State'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/empty-offline'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    title: const Text('About Lost & Found BD'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
