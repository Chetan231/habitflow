import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/domain/models/habit_entry.dart';
import '../../widgets/animated_checkmark.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final HabitEntry? entry;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final Function(double)? onValueChanged;

  const HabitTile({
    super.key,
    required this.habit,
    this.entry,
    this.onToggle,
    this.onDelete,
    this.onValueChanged,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool get isCompleted => widget.entry?.completed ?? false;
  double get currentValue => widget.entry?.value ?? 0.0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.cardBackground,
      end: AppColors.success.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    if (isCompleted) {
      _scaleController.value = 1.0;
      _colorController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry?.completed != isCompleted) {
      if (isCompleted) {
        _scaleController.forward();
        _colorController.forward();
      } else {
        _scaleController.reverse();
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) => widget.onDelete?.call(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _colorController]),
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  // Leading emoji icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${widget.habit.color.substring(1)}')).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.habit.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Subtitle based on habit type
                        if (widget.habit.habitType == HabitType.count) ...[
                          Row(
                            children: [
                              Text(
                                '${currentValue.toInt()} / ${widget.habit.targetValue} ${widget.habit.unit}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              // +/- buttons for count type
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (currentValue > 0) {
                                        widget.onValueChanged?.call(currentValue - 1);
                                      }
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
                                    iconSize: 20,
                                    color: AppColors.textSecondary,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      widget.onValueChanged?.call(currentValue + 1);
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: 20,
                                    color: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ] else if (widget.habit.habitType == HabitType.timer) ...[
                          Text(
                            '${currentValue.toInt()} ${widget.habit.unit.isNotEmpty ? widget.habit.unit : 'minutes'}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Trailing animated checkmark
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? AppColors.success : AppColors.textTertiary,
                              width: 2,
                            ),
                            color: isCompleted ? AppColors.success : Colors.transparent,
                          ),
                        ),
                        // Animated checkmark
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: isCompleted
                              ? const AnimatedCheckmark(
                                  size: 16,
                                  color: Colors.white,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}