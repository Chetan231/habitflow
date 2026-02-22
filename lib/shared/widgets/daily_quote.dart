import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';

class DailyQuote extends StatefulWidget {
  final String quote;
  final String author;
  final VoidCallback? onRefresh;

  const DailyQuote({
    super.key,
    this.quote = "The secret of getting ahead is getting started.",
    this.author = "Mark Twain",
    this.onRefresh,
  });

  @override
  State<DailyQuote> createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isRefreshing = false;

  final List<_Quote> _quotes = [
    _Quote("The secret of getting ahead is getting started.", "Mark Twain"),
    _Quote("Success is not final, failure is not fatal: it is the courage to continue that counts.", "Winston Churchill"),
    _Quote("The only way to do great work is to love what you do.", "Steve Jobs"),
    _Quote("Innovation distinguishes between a leader and a follower.", "Steve Jobs"),
    _Quote("The future belongs to those who believe in the beauty of their dreams.", "Eleanor Roosevelt"),
    _Quote("It is during our darkest moments that we must focus to see the light.", "Aristotle"),
    _Quote("The only impossible journey is the one you never begin.", "Tony Robbins"),
    _Quote("Life is what happens to you while you're busy making other plans.", "John Lennon"),
    _Quote("The way to get started is to quit talking and begin doing.", "Walt Disney"),
    _Quote("Don't let yesterday take up too much of today.", "Will Rogers"),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshQuote() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    
    // Animate out
    await _animationController.reverse();
    
    // Wait a bit for effect
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Trigger refresh callback or select random quote
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
    
    // Animate in
    await _animationController.forward();
    
    setState(() => _isRefreshing = false);
  }

  _Quote get _currentQuote {
    // For now, return a random quote from the list
    final index = DateTime.now().day % _quotes.length;
    return _quotes[index];
  }

  @override
  Widget build(BuildContext context) {
    final currentQuote = _currentQuote;
    
    return GestureDetector(
      onTap: _refreshQuote,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.3 + (0.7 * _animationController.value),
              child: Transform.scale(
                scale: 0.9 + (0.1 * _animationController.value),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote icon and refresh
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _isRefreshing ? 1 : 0,
                          duration: const Duration(milliseconds: 600),
                          child: IconButton(
                            onPressed: _isRefreshing ? null : _refreshQuote,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primary.withOpacity(0.7),
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quote text
                    Text(
                      '"${currentQuote.text}"',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Author
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentQuote.author,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 800),
        )
        .slideX(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 800),
          begin: 0.2,
          curve: Curves.easeOutCubic,
        );
  }
}

class _Quote {
  final String text;
  final String author;

  const _Quote(this.text, this.author);
}