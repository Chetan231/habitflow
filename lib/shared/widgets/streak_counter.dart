import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';

class StreakCounter extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final String title;
  final IconData icon;
  final Color? color;

  const StreakCounter({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.title = 'Current Streak',
    this.icon = Icons.local_fire_department_rounded,
    this.color,
  });

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter>
    with TickerProviderStateMixin {
  late AnimationController _countAnimationController;
  late AnimationController _flameAnimationController;
  late Animation<int> _countAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _countAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _flameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _countAnimation = IntTween(
      begin: 0,
      end: widget.currentStreak,
    ).animate(CurvedAnimation(
      parent: _countAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countAnimationController,
      curve: Curves.elasticOut,
    ));

    _countAnimationController.forward();
    if (widget.currentStreak > 0) {
      _flameAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(StreakCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStreak != widget.currentStreak) {
      _countAnimation = IntTween(
        begin: oldWidget.currentStreak,
        end: widget.currentStreak,
      ).animate(CurvedAnimation(
        parent: _countAnimationController,
        curve: Curves.easeOutCubic,
      ));
      _countAnimationController.reset();
      _countAnimationController.forward();

      if (widget.currentStreak > 0 && oldWidget.currentStreak == 0) {
        _flameAnimationController.repeat();
      } else if (widget.currentStreak == 0) {
        _flameAnimationController.stop();
        _flameAnimationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _countAnimationController.dispose();
    _flameAnimationController.dispose();
    super.dispose();
  }

  Color get streakColor => widget.color ?? 
    (widget.currentStreak > 0 ? AppColors.success : AppColors.textTertiary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.currentStreak > 0 
            ? LinearGradient(
                colors: [
                  streakColor.withOpacity(0.1),
                  streakColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.currentStreak == 0 ? AppColors.surface : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.currentStreak > 0 
              ? streakColor.withOpacity(0.3)
              : AppColors.glassBorder,
          width: widget.currentStreak > 0 ? 2 : 1,
        ),
        boxShadow: widget.currentStreak > 0 ? [
          BoxShadow(
            color: streakColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with animation
          AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _flameAnimationController,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value * 
                    (1.0 + (_flameAnimationController.value * 0.1)),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: streakColor.withOpacity(0.2),
                  ),
                  child: Icon(
                    widget.icon,
                    color: streakColor,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Current streak count
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return Text(
                '${_countAnimation.value}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: streakColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (widget.longestStreak > 0) ...[
            const SizedBox(height: 12),
            
            // Best streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Best: ${widget.longestStreak}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        )
        .slideY(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
          begin: 0.3,
          curve: Curves.easeOutCubic,
        );
  }
}