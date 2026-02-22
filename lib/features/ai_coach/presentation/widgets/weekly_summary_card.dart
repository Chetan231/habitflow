import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../home/presentation/widgets/progress_ring.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WeeklySummaryCard extends StatefulWidget {
  final int score;
  final String bestHabit;
  final String worstHabit;
  final String tip;
  final bool showAnimation;

  const WeeklySummaryCard({
    super.key,
    required this.score,
    required this.bestHabit,
    required this.worstHabit,
    required this.tip,
    this.showAnimation = true,
  });

  @override
  State<WeeklySummaryCard> createState() => _WeeklySummaryCardState();
}

class _WeeklySummaryCardState extends State<WeeklySummaryCard>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  
  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.showAnimation) {
      _staggerController.forward();
    } else {
      _staggerController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WeeklySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score ||
        oldWidget.bestHabit != widget.bestHabit ||
        oldWidget.worstHabit != widget.worstHabit) {
      _staggerController.reset();
      _staggerController.forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.secondary;
    return AppColors.error;
  }

  String _getScoreEmoji(int score) {
    if (score >= 90) return '🎉';
    if (score >= 80) return '🌟';
    if (score >= 70) return '👍';
    if (score >= 60) return '👌';
    if (score >= 50) return '💪';
    if (score >= 40) return '⚡';
    return '💭';
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Outstanding week!';
    if (score >= 80) return 'Great progress!';
    if (score >= 70) return 'Good job!';
    if (score >= 60) return 'Nice work!';
    if (score >= 50) return 'Keep pushing!';
    if (score >= 40) return 'Making progress!';
    return 'New week, new start!';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Summary',
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
                  color: _getScoreColor(widget.score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: ${widget.score}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(widget.score),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Score section with mini progress ring
          Row(
            children: [
              // Mini progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: ProgressRing(
                  progress: widget.score / 100,
                  label: 'Score',
                  size: 80,
                  strokeWidth: 6,
                ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  delay: 300.ms,
                  curve: Curves.elasticOut,
                ),
              ),
              const SizedBox(width: 20),
              
              // Score details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getScoreEmoji(widget.score),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getScoreMessage(widget.score),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You completed ${widget.score}% of your habits this week',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                duration: 400.ms,
                delay: 400.ms,
              ).slideX(
                begin: 0.3,
                end: 0,
                duration: 500.ms,
                delay: 400.ms,
                curve: Curves.easeOutCubic,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Best habit section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Best Habit',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.bestHabit.isEmpty ? 'Keep building those habits!' : widget.bestHabit,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: 600.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: 600.ms,
            curve: Curves.easeOutCubic,
          ),
          
          const SizedBox(height: 12),
          
          // Worst habit section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Needs Attention',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.worstHabit.isEmpty ? 'All habits are doing great!' : widget.worstHabit,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: 800.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: 800.ms,
            curve: Curves.easeOutCubic,
          ),
          
          const SizedBox(height: 16),
          
          // Tip section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'AI Tip',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.tip.isEmpty ? 'Keep up the great work!' : widget.tip,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: 1000.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: 1000.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}