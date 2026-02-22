import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/extensions.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final HabitEntry? entry;
  final VoidCallback? onTap;
  final Function(HabitEntry)? onUpdate;
  final bool isCompleted;

  const HabitTile({
    super.key,
    required this.habit,
    this.entry,
    this.onTap,
    this.onUpdate,
    this.isCompleted = false,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get habitColor => ColorExtension.fromHex(widget.habit.color);

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _toggleCompletion() {
    if (widget.onUpdate == null) return;

    final entry = widget.entry ?? HabitEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: widget.habit.id,
      date: DateTime.now().startOfDay,
    );

    late HabitEntry updatedEntry;

    switch (widget.habit.habitType) {
      case HabitType.yesNo:
        updatedEntry = entry.copyWith(
          completed: !entry.completed,
          completedAt: !entry.completed ? DateTime.now() : null,
        );
        break;
      case HabitType.count:
        final newValue = entry.value >= widget.habit.targetValue 
            ? 0.0 
            : widget.habit.targetValue.toDouble();
        updatedEntry = entry.copyWith(
          value: newValue,
          completed: newValue >= widget.habit.targetValue,
          completedAt: newValue >= widget.habit.targetValue ? DateTime.now() : null,
        );
        break;
      case HabitType.timer:
        final newValue = entry.value >= widget.habit.targetValue 
            ? 0.0 
            : widget.habit.targetValue.toDouble();
        updatedEntry = entry.copyWith(
          value: newValue,
          completed: newValue >= widget.habit.targetValue,
          completedAt: newValue >= widget.habit.targetValue ? DateTime.now() : null,
        );
        break;
    }

    widget.onUpdate!(updatedEntry);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final progress = _getProgress();
    final isCompleted = _getIsCompleted();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap ?? _toggleCompletion,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 1.0 - (_animationController.value * 0.02);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? habitColor.withOpacity(0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? habitColor.withOpacity(0.3)
                      : AppColors.glassBorder,
                  width: isCompleted ? 2 : 1,
                ),
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: habitColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Habit Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: habitColor.withOpacity(0.1),
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
                    
                    // Habit Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isCompleted 
                                  ? habitColor 
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted && widget.habit.habitType == HabitType.yesNo
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                widget.habit.targetDescription,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (widget.habit.reminderTime != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.habit.reminderTime!.format24Hour(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (widget.habit.habitType != HabitType.yesNo && progress > 0) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation(habitColor),
                              minHeight: 4,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Completion Status
                    _buildCompletionIndicator(isCompleted, progress),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate(
          target: isCompleted ? 1.0 : 0.0,
        )
        .shimmer(
          duration: const Duration(milliseconds: 600),
          colors: [
            Colors.transparent,
            habitColor.withOpacity(0.1),
            Colors.transparent,
          ],
        );
  }

  Widget _buildCompletionIndicator(bool isCompleted, double progress) {
    switch (widget.habit.habitType) {
      case HabitType.yesNo:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? habitColor : Colors.transparent,
            border: Border.all(
              color: isCompleted ? habitColor : AppColors.textTertiary,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        );
        
      case HabitType.count:
      case HabitType.timer:
        final entry = widget.entry;
        final current = entry?.value.toInt() ?? 0;
        final target = widget.habit.targetValue;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$current',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isCompleted ? habitColor : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/$target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        );
    }
  }

  double _getProgress() {
    if (widget.habit.habitType == HabitType.yesNo) return 0.0;
    
    final entry = widget.entry;
    if (entry == null || entry.value == 0) return 0.0;
    
    return (entry.value / widget.habit.targetValue).clamp(0.0, 1.0);
  }

  bool _getIsCompleted() {
    final entry = widget.entry;
    if (entry == null) return false;
    
    switch (widget.habit.habitType) {
      case HabitType.yesNo:
        return entry.completed;
      case HabitType.count:
      case HabitType.timer:
        return entry.value >= widget.habit.targetValue;
    }
  }
}