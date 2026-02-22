import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/domain/models/streak.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HabitStreakData {
  final Habit habit;
  final Streak streak;

  const HabitStreakData({
    required this.habit,
    required this.streak,
  });
}

class StreakTimeline extends StatefulWidget {
  final List<HabitStreakData> habits;
  final bool showAnimation;

  const StreakTimeline({
    super.key,
    required this.habits,
    this.showAnimation = true,
  });

  @override
  State<StreakTimeline> createState() => _StreakTimelineState();
}

class _StreakTimelineState extends State<StreakTimeline>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StreakTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habits != widget.habits) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timeline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No streak data yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build consistent habits to see your streaks',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort habits by current streak descending
    final sortedHabits = List<HabitStreakData>.from(widget.habits)
      ..sort((a, b) => b.streak.currentStreak.compareTo(a.streak.currentStreak));

    final maxStreak = sortedHabits.isNotEmpty 
        ? sortedHabits.map((h) => h.streak.longestStreak > h.streak.currentStreak 
              ? h.streak.longestStreak 
              : h.streak.currentStreak).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.timeline,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Streak Timeline',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Max: $maxStreak days',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedHabits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final habitStreak = sortedHabits[index];
              
              return _StreakTimelineItem(
                habitStreak: habitStreak,
                maxStreak: maxStreak,
                animationController: _animationController,
                delay: Duration(milliseconds: index * 150),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StreakTimelineItem extends StatefulWidget {
  final HabitStreakData habitStreak;
  final int maxStreak;
  final AnimationController animationController;
  final Duration delay;

  const _StreakTimelineItem({
    required this.habitStreak,
    required this.maxStreak,
    required this.animationController,
    required this.delay,
  });

  @override
  State<_StreakTimelineItem> createState() => _StreakTimelineItemState();
}

class _StreakTimelineItemState extends State<_StreakTimelineItem>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _currentStreakAnimation;
  late Animation<double> _longestStreakAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _currentStreakAnimation = CurvedAnimation(
      parent: _progressController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );
    
    _longestStreakAnimation = CurvedAnimation(
      parent: _progressController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    // Start progress animation after the main animation delay
    Future.delayed(widget.delay + const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.habitStreak.streak;
    final habit = widget.habitStreak.habit;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarWidth = screenWidth - 180; // Account for padding and text
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit info
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${habit.color.substring(1)}')).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    habit.iconEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (streak.isActive) ...[
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${streak.currentStreak} days',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: streak.isActive ? AppColors.secondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (streak.longestStreak > streak.currentStreak) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Best: ${streak.longestStreak} days',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Streak bars
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                // Longest streak bar (background)
                if (streak.longestStreak > 0)
                  AnimatedBuilder(
                    animation: _longestStreakAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 8,
                        width: (maxBarWidth * (streak.longestStreak / widget.maxStreak)) * 
                               _longestStreakAnimation.value,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                
                // Current streak bar (foreground)
                if (streak.currentStreak > 0)
                  AnimatedBuilder(
                    animation: _currentStreakAnimation,
                    builder: (context, child) {
                      final barColor = streak.isActive ? AppColors.secondary : AppColors.primary;
                      return Container(
                        height: 8,
                        width: (maxBarWidth * (streak.currentStreak / widget.maxStreak)) * 
                               _currentStreakAnimation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              barColor,
                              barColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                
                // Status indicator
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: streak.isActive ? AppColors.success : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: streak.isActive ? AppColors.success : AppColors.textTertiary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      streak.isActive ? 'Active' : 'Paused',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: streak.isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                
                // Milestone indicators
                if (streak.currentStreak >= 7)
                  Positioned(
                    left: (maxBarWidth * (7 / widget.maxStreak)) - 6,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '⭐',
                          style: TextStyle(fontSize: 6),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: widget.delay,
    ).slideY(
      begin: 0.5,
      end: 0,
      duration: 500.ms,
      delay: widget.delay,
      curve: Curves.easeOutCubic,
    );
  }
}