import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/habits_provider.dart';
import '../../domain/models/habit.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final String habitId;

  const EditHabitScreen({
    super.key,
    required this.habitId,
  });

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedIcon = 'water';
  String _selectedColor = '#4ECDC4';
  HabitType _habitType = HabitType.yesNo;
  int _targetValue = 1;
  String _unit = '';
  Set<int> _frequencyDays = {1, 2, 3, 4, 5, 6, 7};
  TimeOfDay? _reminderTime;
  bool _isLoading = false;
  Habit? _originalHabit;

  late List<AnimationController> _sectionControllers;

  final List<String> _availableIcons = [
    'water', 'exercise', 'book', 'meditation', 'sleep', 'walk',
    'healthy_food', 'no_phone', 'journal', 'stretch', 'music', 'art',
    'work', 'study', 'code', 'gym', 'run', 'bike', 'swim', 'yoga'
  ];

  final List<String> _availableUnits = [
    'times', 'minutes', 'hours', 'glasses', 'pages', 'km', 'steps'
  ];

  @override
  void initState() {
    super.initState();
    _sectionControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _loadHabitData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    for (final controller in _sectionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadHabitData() {
    final habitsAsync = ref.read(habitsProvider);
    final habits = habitsAsync.value;
    
    if (habits != null) {
      final habit = habits.firstWhere(
        (h) => h.id == widget.habitId,
        orElse: () => Habit.empty(),
      );

      if (habit.id.isNotEmpty) {
        _originalHabit = habit;
        setState(() {
          _nameController.text = habit.name;
          _selectedIcon = habit.icon;
          _selectedColor = habit.color;
          _habitType = habit.habitType;
          _targetValue = habit.targetValue;
          _targetController.text = habit.targetValue.toString();
          _unit = habit.unit;
          _frequencyDays = habit.frequencyDays.toSet();
          if (habit.reminderTime != null) {
            final parts = habit.reminderTime!.split(':');
            _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        });
      }
    }

    // Animate sections in sequence
    for (int i = 0; i < _sectionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _sectionControllers[i].forward();
        }
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      if (_originalHabit == null) {
        throw Exception('Habit not found');
      }

      final updatedHabit = _originalHabit!.copyWith(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        habitType: _habitType,
        targetValue: _targetValue,
        unit: _unit,
        frequencyDays: _frequencyDays.toList(),
        reminderTime: _reminderTime != null ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}' : null,
        updatedAt: DateTime.now(),
      );

      await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);

      if (mounted) {
        context.showSuccessSnackBar(AppStrings.habitUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(habitsProvider.notifier).deleteHabit(widget.habitId);

      if (mounted) {
        context.showSuccessSnackBar(AppStrings.habitDeleted);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Habit',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${_nameController.text}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.editHabit,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Delete button
          IconButton(
            onPressed: _isLoading ? null : _deleteHabit,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error.withOpacity(_isLoading ? 0.5 : 1.0),
            ),
          ),
          // Save button
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    AppStrings.save,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Habit Name
                _buildAnimatedSection(
                  0,
                  _buildSection(
                    title: AppStrings.habitName,
                    icon: Icons.edit_rounded,
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: AppStrings.habitNameHint,
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.habitNameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Icon Selection
                _buildAnimatedSection(
                  1,
                  _buildSection(
                    title: AppStrings.chooseIcon,
                    icon: Icons.emoji_emotions_rounded,
                    child: _buildIconPicker(),
                  ),
                ),

                const SizedBox(height: 24),

                // Color Selection
                _buildAnimatedSection(
                  2,
                  _buildSection(
                    title: AppStrings.chooseColor,
                    icon: Icons.palette_rounded,
                    child: _buildColorPicker(),
                  ),
                ),

                const SizedBox(height: 24),

                // Habit Type
                _buildAnimatedSection(
                  3,
                  _buildSection(
                    title: AppStrings.habitType,
                    icon: Icons.category_rounded,
                    child: _buildHabitTypePicker(),
                  ),
                ),

                const SizedBox(height: 24),

                // Target Value (if not yes/no)
                if (_habitType != HabitType.yesNo) ...[
                  _buildAnimatedSection(
                    4,
                    _buildSection(
                      title: AppStrings.targetValue,
                      icon: Icons.flag_rounded,
                      child: _buildTargetValueInput(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Frequency
                _buildAnimatedSection(
                  4,
                  _buildSection(
                    title: AppStrings.frequency,
                    icon: Icons.calendar_today_rounded,
                    child: _buildFrequencyPicker(),
                  ),
                ),

                const SizedBox(height: 24),

                // Reminder Time
                _buildAnimatedSection(
                  5,
                  _buildSection(
                    title: AppStrings.reminderTime,
                    icon: Icons.schedule_rounded,
                    child: _buildReminderTimePicker(),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _sectionControllers[index],
      builder: (context, _) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _sectionControllers[index],
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _sectionControllers[index],
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.map((icon) {
        final isSelected = icon == _selectedIcon;
        final habit = Habit.empty().copyWith(icon: icon);
        
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                habit.iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppColors.habitColors.map((color) {
        final colorHex = color.toHex();
        final isSelected = colorHex == _selectedColor;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorHex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitTypePicker() {
    return Row(
      children: HabitType.values.map((type) {
        final isSelected = type == _habitType;
        String label;
        
        switch (type) {
          case HabitType.yesNo:
            label = AppStrings.yesNo;
            break;
          case HabitType.count:
            label = AppStrings.count;
            break;
          case HabitType.timer:
            label = AppStrings.time;
            break;
        }
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _habitType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTargetValueInput() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '1',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _targetValue = int.tryParse(value) ?? 1;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Must be > 0';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            value: _unit.isEmpty ? null : _unit,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.unit,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: AppColors.surface,
            items: _availableUnits.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _unit = value ?? '');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyPicker() {
    final days = [
      (1, AppStrings.monday),
      (2, AppStrings.tuesday),
      (3, AppStrings.wednesday),
      (4, AppStrings.thursday),
      (5, AppStrings.friday),
      (6, AppStrings.saturday),
      (7, AppStrings.sunday),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((dayData) {
        final dayNum = dayData.$1;
        final dayName = dayData.$2;
        final isSelected = _frequencyDays.contains(dayNum);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _frequencyDays.remove(dayNum);
              } else {
                _frequencyDays.add(dayNum);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              dayName,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderTimePicker() {
    return GestureDetector(
      onTap: _pickReminderTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: _reminderTime != null ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Text(
              _reminderTime != null ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}' : 'Set reminder time (optional)',
              style: TextStyle(
                color: _reminderTime != null ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            if (_reminderTime != null)
              GestureDetector(
                onTap: () => setState(() => _reminderTime = null),
                child: Icon(
                  Icons.clear_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }
}