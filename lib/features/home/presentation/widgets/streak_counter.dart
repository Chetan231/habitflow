import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class StreakCounter extends StatefulWidget {
  final int streakCount;
  final bool shouldAnimate;

  const StreakCounter({
    super.key,
    required this.streakCount,
    this.shouldAnimate = true,
  });

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _pulseController;
  late Animation<double> _countAnimation;
  late Animation<double> _pulseAnimation;
  
  int _previousCount = 0;
  bool _shouldPulse = false;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    _previousCount = widget.streakCount;
    _countController.forward();
    
    // Check if we should pulse for milestones
    _checkForMilestone(widget.streakCount);
  }

  void _checkForMilestone(int count) {
    final milestones = [7, 30, 100];
    if (milestones.contains(count) && count > _previousCount) {
      _shouldPulse = true;
      _pulseController.repeat(reverse: true);
      
      // Stop pulsing after 3 cycles
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          _pulseController.stop();
          _pulseController.reset();
          setState(() {
            _shouldPulse = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(StreakCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakCount != widget.streakCount) {
      _previousCount = oldWidget.streakCount;
      _countController.reset();
      _countController.forward();
      
      _checkForMilestone(widget.streakCount);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_countAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _shouldPulse ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fire emoji with glow effect
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _shouldPulse ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Animated count
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: _previousCount.toDouble(),
                    end: widget.streakCount.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedCount, child) {
                    return Text(
                      '${animatedCount.toInt()}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                
                // "days" text
                Text(
                  widget.streakCount == 1 ? 'day' : 'days',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}