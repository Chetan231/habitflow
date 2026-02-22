import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/colors.dart';
import 'package:habitflow/shared/providers/ai_provider.dart';
import 'package:habitflow/shared/widgets/glass_card.dart';
import 'package:habitflow/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:habitflow/features/ai_coach/presentation/widgets/weekly_summary_card.dart';
import 'package:habitflow/features/ai_coach/presentation/widgets/suggestion_card.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivation = ref.watch(dailyMotivationProvider);
    final summary = ref.watch(weeklySummaryProvider);
    final suggestions = ref.watch(aiSuggestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'AI Coach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              ref.invalidate(dailyMotivationProvider);
              ref.invalidate(weeklySummaryProvider);
              ref.invalidate(aiSuggestionsProvider);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(dailyMotivationProvider);
            ref.invalidate(weeklySummaryProvider);
            ref.invalidate(aiSuggestionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Daily Motivation
              const Text(
                "Today's Motivation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              motivation.when(
                data: (text) => AiMessageBubble(message: text),
                loading: () => _ShimmerBubble(),
                error: (e, _) => GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Could not load motivation. Pull to retry!',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Summary
              const Text(
                'Weekly Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              summary.when(
                data: (data) => WeeklySummaryCard(
                  score: data.score,
                  bestHabit: data.bestHabit,
                  worstHabit: data.worstHabit,
                  tip: data.tip,
                ),
                loading: () => _ShimmerCard(),
                error: (e, _) => GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Weekly summary unavailable.',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Suggestions
              const Text(
                'Suggestions for You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              suggestions.when(
                data: (list) => Column(
                  children: list.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + i * 200),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SuggestionCard(
                          title: s.title,
                          description: s.description,
                          icon: s.icon,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => Column(
                  children: List.generate(3, (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ShimmerCard(height: 70),
                  )),
                ),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBubble extends StatefulWidget {
  @override
  State<_ShimmerBubble> createState() => _ShimmerBubbleState();
}

class _ShimmerBubbleState extends State<_ShimmerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerLine(width: 200),
              const SizedBox(height: 8),
              _shimmerLine(width: 280),
              const SizedBox(height: 8),
              _shimmerLine(width: 160),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerLine({required double width}) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
          stops: [
            (_controller.value - 0.3).clamp(0.0, 1.0),
            _controller.value,
            (_controller.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  const _ShimmerCard({this.height = 120});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.03),
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.03),
            ],
          ),
        ),
      ),
    );
  }
}

// AnimatedBuilder is just an alias used here; use AnimatedBuilder from Flutter
// Actually Flutter has AnimatedBuilder — let's use it correctly
