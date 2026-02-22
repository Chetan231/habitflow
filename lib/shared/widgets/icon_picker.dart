import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class IconPicker extends StatefulWidget {
  final String? selectedIcon;
  final Function(String) onSelected;
  final bool showInDialog;
  final String title;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onSelected,
    this.showInDialog = true,
    this.title = 'Choose an Icon',
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  static const List<Map<String, String>> _habitIcons = [
    {'key': 'fitness', 'emoji': '💪', 'name': 'Fitness'},
    {'key': 'gym', 'emoji': '🏋️', 'name': 'Gym'},
    {'key': 'reading', 'emoji': '📚', 'name': 'Reading'},
    {'key': 'meditation', 'emoji': '🧘', 'name': 'Meditation'},
    {'key': 'water', 'emoji': '💧', 'name': 'Water'},
    {'key': 'book', 'emoji': '📖', 'name': 'Book'},
    {'key': 'target', 'emoji': '🎯', 'name': 'Target'},
    {'key': 'running', 'emoji': '🏃', 'name': 'Running'},
    {'key': 'sleep', 'emoji': '💤', 'name': 'Sleep'},
    {'key': 'apple', 'emoji': '🍎', 'name': 'Healthy Food'},
    {'key': 'music', 'emoji': '🎵', 'name': 'Music'},
    {'key': 'writing', 'emoji': '✍️', 'name': 'Writing'},
    {'key': 'brain', 'emoji': '🧠', 'name': 'Learning'},
    {'key': 'pills', 'emoji': '💊', 'name': 'Medicine'},
    {'key': 'walking', 'emoji': '🚶', 'name': 'Walking'},
    {'key': 'art', 'emoji': '🎨', 'name': 'Art'},
    {'key': 'swimming', 'emoji': '🏊', 'name': 'Swimming'},
    {'key': 'cycling', 'emoji': '🚴', 'name': 'Cycling'},
    {'key': 'cleaning', 'emoji': '🧹', 'name': 'Cleaning'},
    {'key': 'plant', 'emoji': '🌿', 'name': 'Plants'},
    {'key': 'prayer', 'emoji': '🙏', 'name': 'Prayer'},
    {'key': 'journal', 'emoji': '📝', 'name': 'Journal'},
    {'key': 'computer', 'emoji': '💻', 'name': 'Work'},
    {'key': 'guitar', 'emoji': '🎸', 'name': 'Guitar'},
    {'key': 'cooking', 'emoji': '🍳', 'name': 'Cooking'},
    {'key': 'home', 'emoji': '🏠', 'name': 'Home'},
    {'key': 'phone', 'emoji': '📞', 'name': 'Calls'},
    {'key': 'mindfulness', 'emoji': '🧘‍♂️', 'name': 'Mindfulness'},
    {'key': 'money', 'emoji': '💰', 'name': 'Finances'},
    {'key': 'gaming', 'emoji': '🎮', 'name': 'Gaming'},
    {'key': 'coffee', 'emoji': '☕', 'name': 'Coffee'},
    {'key': 'stretching', 'emoji': '🤸', 'name': 'Stretching'},
    {'key': 'yoga', 'emoji': '🧘‍♀️', 'name': 'Yoga'},
    {'key': 'dancing', 'emoji': '💃', 'name': 'Dancing'},
    {'key': 'photography', 'emoji': '📸', 'name': 'Photography'},
    {'key': 'travel', 'emoji': '✈️', 'name': 'Travel'},
    {'key': 'nature', 'emoji': '🌳', 'name': 'Nature'},
    {'key': 'star', 'emoji': '⭐', 'name': 'Goals'},
    {'key': 'heart', 'emoji': '❤️', 'name': 'Health'},
    {'key': 'fire', 'emoji': '🔥', 'name': 'Motivation'},
  ];

  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showInDialog) {
      return _buildDialogContent();
    } else {
      return _buildGrid();
    }
  }

  Widget _buildDialogContent() {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.glassBorder.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid
            Expanded(
              child: _buildGrid(),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.glassBorder.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.glassBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedIcon != null
                          ? () {
                              widget.onSelected(_selectedIcon!);
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Select',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: widget.showInDialog,
        physics: widget.showInDialog ? const ClampingScrollPhysics() : null,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _habitIcons.length,
        itemBuilder: (context, index) {
          final icon = _habitIcons[index];
          final isSelected = _selectedIcon == icon['key'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = icon['key'];
              });
              
              if (!widget.showInDialog) {
                widget.onSelected(icon['key']!);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.glassBorder.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    icon['name']!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void show(
    BuildContext context, {
    String? selectedIcon,
    required Function(String) onSelected,
    String title = 'Choose an Icon',
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => IconPicker(
        selectedIcon: selectedIcon,
        onSelected: onSelected,
        showInDialog: true,
        title: title,
      ),
    );
  }

  static void showBottomSheet(
    BuildContext context, {
    String? selectedIcon,
    required Function(String) onSelected,
    String title = 'Choose an Icon',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: IconPicker(
          selectedIcon: selectedIcon,
          onSelected: (icon) {
            onSelected(icon);
            Navigator.of(context).pop();
          },
          showInDialog: true,
          title: title,
        ),
      ),
    );
  }
}