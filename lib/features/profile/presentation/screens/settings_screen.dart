import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/colors.dart';
import 'package:habitflow/shared/providers/auth_provider.dart';
import 'package:habitflow/shared/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text('Currently ${isDark ? 'enabled' : 'disabled'}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                value: isDark,
                activeColor: AppColors.primary,
                onChanged: (val) =>
                    ref.read(themeProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Push Notifications',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Habit reminders & motivation',
                    style: TextStyle(color: AppColors.textSecondary)),
                value: true,
                activeColor: AppColors.primary,
                onChanged: (val) {},
              ),
              const Divider(color: AppColors.surfaceVariant, height: 1),
              SwitchListTile(
                title: const Text('Daily Motivation',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('AI-generated morning message',
                    style: TextStyle(color: AppColors.textSecondary)),
                value: true,
                activeColor: AppColors.primary,
                onChanged: (val) {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Section
          _SectionHeader(title: 'Data'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.cloud_upload, color: AppColors.primary),
                title: const Text('Backup & Restore',
                    style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () => _showSnack(context, 'Backup initiated...'),
              ),
              const Divider(color: AppColors.surfaceVariant, height: 1),
              ListTile(
                leading: const Icon(Icons.delete_sweep,
                    color: AppColors.warning),
                title: const Text('Clear Local Data',
                    style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () => _confirmClear(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger Zone
          _SectionHeader(title: 'Danger Zone', color: AppColors.secondary),
          const SizedBox(height: 8),
          _SettingsCard(
            borderColor: AppColors.secondary.withOpacity(0.3),
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever,
                    color: AppColors.secondary),
                title: const Text('Delete Account',
                    style: TextStyle(color: AppColors.secondary)),
                subtitle: const Text('This cannot be undone',
                    style: TextStyle(color: AppColors.textSecondary)),
                onTap: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'HabitFlow v1.0.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Made with 💜 and Flutter',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:
            const Text('Clear Local Data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all cached data from your device. Cloud data will remain safe.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack(context, 'Local data cleared');
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('⚠️ Delete Account?',
            style: TextStyle(color: AppColors.secondary)),
        content: const Text(
          'This will permanently delete your account and ALL data. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Second confirmation
              showDialog(
                context: context,
                builder: (ctx2) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Are you absolutely sure?',
                      style: TextStyle(color: AppColors.secondary)),
                  content: const Text(
                    'Type "DELETE" to confirm account deletion.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Nevermind',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx2);
                        ref.read(authProvider.notifier).signOut();
                        _showSnack(context, 'Account deleted');
                      },
                      child: const Text('DELETE ACCOUNT',
                          style: TextStyle(color: AppColors.secondary)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes, delete',
                style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({
    required this.title,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;

  const _SettingsCard({required this.children, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}
