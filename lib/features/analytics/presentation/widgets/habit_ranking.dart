import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../habits/domain/models/habit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HabitRankingItem {
  final Habit habit;
  final double successRate;
  final int totalDays;
  final int completedDays;

  const HabitRankingItem({
    required this.habit,
    required this.successRate,
    required this.totalDays,
    required this.completedDays,
  });
}

class HabitRanking extends StatefulWidget {
  final List<HabitRankingItem> rankings;
  final bool showAnimation;

  const HabitRanking({
    super.key,
    required this.rankings,
    this.showAnimation = true,
  });

  @override
  State<HabitRanking> createState() => _HabitRankingState();
}

class _HabitRankingState extends State<HabitRanking>
    with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(HabitRanking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rankings != widget.rankings) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getSuccessRateColor(double successRate) {
    if (successRate >= 80) return AppColors.success;
    if (successRate >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _getRankingEmoji(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$position';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rankings.isEmpty) {
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
              Icons.analytics_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No habit data yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking habits to see your rankings',
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
                  Icons.leaderboard,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Habit Rankings',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.rankings.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.glassBorder.withOpacity(0.1),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final ranking = widget.rankings[index];
              final position = index + 1;
              
              return _HabitRankingTile(
                ranking: ranking,
                position: position,
                animationController: _animationController,
                delay: Duration(milliseconds: index * 100),
              );
            },
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HabitRankingTile extends StatefulWidget {
  final HabitRankingItem ranking;
  final int position;
  final AnimationController animationController;
  final Duration delay;

  const _HabitRankingTile({
    required this.ranking,
    required this.position,
    required this.animationController,
    required this.delay,
  });

  @override
  State<_HabitRankingTile> createState() => _HabitRankingTileState();
}

class _HabitRankingTileState extends State<_HabitRankingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    // Start progress animation after the main animation delay
    Future.delayed(widget.delay + const Duration(milliseconds: 300), () {
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

  Color _getSuccessRateColor(double successRate) {
    if (successRate >= 80) return AppColors.success;
    if (successRate >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _getRankingDisplay(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$position';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Position indicator
          SizedBox(
            width: 32,
            child: Text(
              _getRankingDisplay(widget.position),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.position <= 3 ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          
          // Habit icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF${widget.ranking.habit.color.substring(1)}')).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                widget.ranking.habit.iconEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Habit info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ranking.habit.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.ranking.completedDays}/${widget.ranking.totalDays} days completed',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Progress bar and percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.ranking.successRate.toInt()}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getSuccessRateColor(widget.ranking.successRate),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                height: 4,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: _getSuccessRateColor(widget.ranking.successRate),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      builder: (context, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          width: 80 * (widget.ranking.successRate / 100) * _progressAnimation.value,
                          child: child,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: widget.delay,
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: 500.ms,
      delay: widget.delay,
      curve: Curves.easeOutCubic,
    );
  }
}