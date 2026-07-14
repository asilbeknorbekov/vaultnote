import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultnote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';

// Temporary provider for the AI Local Mode toggle
final localAiModeProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final localAiMode = ref.watch(localAiModeProvider);

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              // AI Settings
              _SectionHeader(title: 'Artificial Intelligence'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(
                  children: [
                    _SettingsSwitchTile(
                      icon: LucideIcons.cpu,
                      title: 'Local-Only Mode',
                      subtitle: 'Process AI securely on-device. Disables cloud features and reduces quality.',
                      value: localAiMode,
                      onChanged: (val) => ref.read(localAiModeProvider.notifier).state = val,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.zap),
                      title: const Text('Cloud Token Usage'),
                      subtitle: const Text('2,450 / 100,000 monthly limit'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Security Settings
              _SectionHeader(title: 'Security'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(LucideIcons.lock),
                      title: const Text('App Lock Timeout'),
                      subtitle: const Text('Immediately'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.fingerprint),
                      title: const Text('Biometric Authentication'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Settings
              _SectionHeader(title: 'Appearance & Accessibility'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(LucideIcons.moon),
                      title: const Text('Theme'),
                      subtitle: const Text('System Default'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsSwitchTile(
                      icon: LucideIcons.eyeOff,
                      title: 'Reduce Transparency',
                      subtitle: 'Replaces glassmorphism with solid colors for motion sensitivity or performance.',
                      value: reduceTransparency,
                      onChanged: (val) => ref.read(reduceTransparencyProvider.notifier).state = val,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Data Settings
              _SectionHeader(title: 'Data & Backup'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(LucideIcons.downloadCloud),
                      title: const Text('Encrypted Backup'),
                      subtitle: const Text('Last backed up yesterday'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.logOut),
                      title: const Text('Export Data'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.trash2, color: Colors.red),
                      title: const Text('Delete Vault', style: TextStyle(color: Colors.red)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
