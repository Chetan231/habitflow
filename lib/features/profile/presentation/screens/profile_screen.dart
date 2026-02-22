import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitflow/core/constants/colors.dart';
import 'package:habitflow/shared/providers/auth_provider.dart';
import 'package:habitflow/shared/providers/habits_provider.dart';
import 'package:habitflow/shared/widgets/glass_card.dart';
import 'package:habitflow/features/profile/presentation/screens/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(authState),
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                authState.when(
                  data: (user) => user?.displayName ?? 'User',
                  loading: () => '...',
                  error: (_, __) => 'User',
                ),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authState.when(
                  data: (user) => user?.email ?? '',
                  loading: () => '',
                  error: (_, __) => '',
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),

              // Stats Row
              _StatsRow(),
              const SizedBox(height: 24),

              // Menu Items
              _MenuItem(
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.cloud_upload_rounded,
                title: 'Backup & Restore',
                onTap: () => _showSnackBar(context, 'Backup feature coming soon!'),
              ),
              _MenuItem(
                icon: Icons.download_rounded,
                title: 'Export Data (CSV)',
                onTap: () => _showSnackBar(context, 'Export feature coming soon!'),
              ),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                title: 'About HabitFlow',
                onTap: () => _showAbout(context),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                color: AppColors.secondary,
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitial(AsyncValue authState) {
    return authState.when(
      data: (user) {
        final name = user?.displayName ?? user?.email ?? 'U';
        return name.isNotEmpty ? name[0].toUpperCase() : 'U';
      },
      loading: () => '?',
      error: (_, __) => 'U',
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('HabitFlow', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Version 1.0.0\n\nA beautiful habit tracker built with Flutter.\nTrack your habits, build streaks, and let AI coach you to consistency.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            value: habits.when(
              data: (list) => list.length.toString(),
              loading: () => '-',
              error: (_, __) => '0',
            ),
            label: 'Habits',
            delay: 0,
          ),
        ),
        Expanded(
          child: _StatItem(
            value: '14',
            label: 'Best Streak',
            delay: 100,
          ),
        ),
        Expanded(
          child: _StatItem(
            value: '89',
            label: 'Completions',
            delay: 200,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final int delay;

  const _StatItem({
    required this.value,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - val)),
            child: child,
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.color = AppColors.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
