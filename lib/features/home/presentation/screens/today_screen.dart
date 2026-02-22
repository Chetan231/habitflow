import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/habits_provider.dart';
import '../../../../shared/providers/analytics_provider.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/widgets/streak_counter.dart';
import '../../../../shared/widgets/daily_quote.dart';
import '../../../../shared/widgets/habit_tile.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _confettiController;
  final ScrollController _scrollController = ScrollController();
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _refreshController.forward();
    
    await Future.wait([
      ref.read(habitsProvider.notifier).refresh(),
      ref.read(habitEntriesProvider.notifier).refresh(),
    ]);
    
    _refreshController.reset();
  }

  void _onHabitUpdate(habitEntry) {
    ref.read(habitEntriesProvider.notifier).updateEntry(habitEntry);
    
    // Check if all habits are completed for confetti
    final completion = ref.read(dailyCompletionProvider);
    if (completion >= 1.0 && !_showConfetti) {
      setState(() => _showConfetti = true);
      _confettiController.forward().then((_) {
        setState(() => _showConfetti = false);
        _confettiController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayHabits = ref.watch(todayHabitsProvider);
    final todayEntries = ref.watch(todayEntriesProvider);
    final dailyCompletion = ref.watch(dailyCompletionProvider);
    final streaks = ref.watch(currentStreaksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting and Date
                          _buildHeader()
                              .animate()
                              .fadeIn(
                                delay: const Duration(milliseconds: 100),
                                duration: const Duration(milliseconds: 600),
                              )
                              .slideY(
                                delay: const Duration(milliseconds: 100),
                                duration: const Duration(milliseconds: 600),
                                begin: -0.2,
                                curve: Curves.easeOutCubic,
                              ),
                          
                          const SizedBox(height: 32),
                          
                          // Progress Ring and Stats
                          Row(
                            children: [
                              // Daily Progress Ring
                              Expanded(
                                flex: 1,
                                child: _buildProgressSection(dailyCompletion)
                                    .animate()
                                    .fadeIn(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(milliseconds: 800),
                                    )
                                    .scale(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.elasticOut,
                                    ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Streak Counter
                              Expanded(
                                flex: 1,
                                child: streaks.when(
                                  data: (streakList) {
                                    final bestStreak = streakList.isNotEmpty 
                                        ? streakList.reduce((a, b) => 
                                            a.currentStreak > b.currentStreak ? a : b)
                                        : null;
                                    
                                    return StreakCounter(
                                      currentStreak: bestStreak?.currentStreak ?? 0,
                                      longestStreak: bestStreak?.longestStreak ?? 0,
                                    );
                                  },
                                  loading: () => const StreakCounter(
                                    currentStreak: 0,
                                    longestStreak: 0,
                                  ),
                                  error: (_, __) => const StreakCounter(
                                    currentStreak: 0,
                                    longestStreak: 0,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                      delay: const Duration(milliseconds: 500),
                                      duration: const Duration(milliseconds: 800),
                                    )
                                    .slideX(
                                      delay: const Duration(milliseconds: 500),
                                      duration: const Duration(milliseconds: 800),
                                      begin: 0.3,
                                      curve: Curves.easeOutCubic,
                                    ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Daily Quote
                          const DailyQuote()
                              .animate()
                              .fadeIn(
                                delay: const Duration(milliseconds: 700),
                                duration: const Duration(milliseconds: 800),
                              )
                              .slideY(
                                delay: const Duration(milliseconds: 700),
                                duration: const Duration(milliseconds: 800),
                                begin: 0.2,
                                curve: Curves.easeOutCubic,
                              ),
                          
                          const SizedBox(height: 32),
                          
                          // Section Title
                          Row(
                            children: [
                              Text(
                                AppStrings.todayHabits,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                todayHabits.when(
                                  data: (habits) => '${habits.length} habits',
                                  loading: () => '...',
                                  error: (_, __) => '0 habits',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(
                                delay: const Duration(milliseconds: 900),
                                duration: const Duration(milliseconds: 600),
                              ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  
                  // Habits List
                  todayHabits.when(
                    data: (habits) => todayEntries.when(
                      data: (entries) => _buildHabitsList(habits, entries),
                      loading: () => _buildHabitsLoading(),
                      error: (error, _) => _buildHabitsError(error.toString()),
                    ),
                    loading: () => _buildHabitsLoading(),
                    error: (error, _) => _buildHabitsError(error.toString()),
                  ),
                  
                  // Bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
          
          // Confetti overlay
          if (_showConfetti) _buildConfettiOverlay(),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToAddHabit(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Habit'),
      )
          .animate()
          .fadeIn(
            delay: const Duration(milliseconds: 1200),
            duration: const Duration(milliseconds: 600),
          )
          .slideY(
            delay: const Duration(milliseconds: 1200),
            duration: const Duration(milliseconds: 600),
            begin: 1.0,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppDateUtils.getGreeting(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double completion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          ProgressRing(
            progress: completion,
            size: 100,
            strokeWidth: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(completion * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daily Progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(habits, entries) {
    if (habits.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildEmptyState(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final habit = habits[index];
            final entry = entries.firstWhere(
              (e) => e.habitId == habit.id,
              orElse: () => null,
            );

            return HabitTile(
              habit: habit,
              entry: entry,
              onUpdate: _onHabitUpdate,
              onTap: () => context.goToHabitDetail(habit.id),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 1000 + (index * 100)),
                  duration: const Duration(milliseconds: 600),
                )
                .slideX(
                  delay: Duration(milliseconds: 1000 + (index * 100)),
                  duration: const Duration(milliseconds: 600),
                  begin: 0.3,
                  curve: Curves.easeOutCubic,
                );
          },
          childCount: habits.length,
        ),
      ),
    );
  }

  Widget _buildHabitsLoading() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            )
                .animate()
                .shimmer(
                  duration: const Duration(milliseconds: 1000),
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceVariant,
                    AppColors.surface,
                  ],
                );
          },
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildHabitsError(String error) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load habits',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.noHabitsToday,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addFirstHabit,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.goToAddHabit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(_confettiController.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint();
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 50; i++) {
      final x = (random + i * 123) % size.width.toInt();
      final y = size.height * (1 - progress) - (i % 20) * 10;
      
      paint.color = AppColors.habitColors[i % AppColors.habitColors.length];
      
      canvas.drawCircle(
        Offset(x.toDouble(), y),
        2 + (i % 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}