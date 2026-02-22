import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class ColorPicker extends StatefulWidget {
  final String? selectedColor;
  final Function(String) onSelected;
  final bool showInDialog;
  final String title;

  const ColorPicker({
    super.key,
    this.selectedColor,
    required this.onSelected,
    this.showInDialog = true,
    this.title = 'Choose a Color',
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  static const List<Map<String, dynamic>> _colors = [
    {'hex': '6C63FF', 'color': Color(0xFF6C63FF), 'name': 'Primary Purple'},
    {'hex': 'FF6584', 'color': Color(0xFFFF6584), 'name': 'Coral Pink'},
    {'hex': '00C853', 'color': Color(0xFF00C853), 'name': 'Success Green'},
    {'hex': 'FFB74D', 'color': Color(0xFFFFB74D), 'name': 'Warm Orange'},
    {'hex': '2196F3', 'color': Color(0xFF2196F3), 'name': 'Ocean Blue'},
    {'hex': 'E91E63', 'color': Color(0xFFE91E63), 'name': 'Hot Pink'},
    {'hex': '9C27B0', 'color': Color(0xFF9C27B0), 'name': 'Royal Purple'},
    {'hex': '009688', 'color': Color(0xFF009688), 'name': 'Teal Green'},
    {'hex': 'FF5722', 'color': Color(0xFFFF5722), 'name': 'Fire Red'},
    {'hex': '795548', 'color': Color(0xFF795548), 'name': 'Earth Brown'},
    {'hex': '607D8B', 'color': Color(0xFF607D8B), 'name': 'Steel Blue'},
    {'hex': 'FFEB3B', 'color': Color(0xFFFFEB3B), 'name': 'Sunny Yellow'},
  ];

  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
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
          maxHeight: 400,
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
                      onPressed: _selectedColor != null
                          ? () {
                              widget.onSelected(_selectedColor!);
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
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final colorData = _colors[index];
          final isSelected = _selectedColor == colorData['hex'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = colorData['hex'];
              });
              
              if (!widget.showInDialog) {
                widget.onSelected(colorData['hex']!);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorData['color'],
                border: Border.all(
                  color: isSelected 
                      ? Colors.white
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorData['color'].withOpacity(0.3),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
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

  static void show(
    BuildContext context, {
    String? selectedColor,
    required Function(String) onSelected,
    String title = 'Choose a Color',
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ColorPicker(
        selectedColor: selectedColor,
        onSelected: onSelected,
        showInDialog: true,
        title: title,
      ),
    );
  }

  static void showBottomSheet(
    BuildContext context, {
    String? selectedColor,
    required Function(String) onSelected,
    String title = 'Choose a Color',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ColorPicker(
          selectedColor: selectedColor,
          onSelected: (color) {
            onSelected(color);
            Navigator.of(context).pop();
          },
          showInDialog: true,
          title: title,
        ),
      ),
    );
  }

  static Color getColorFromHex(String hex) {
    return Color(int.parse('0xFF$hex'));
  }

  static String getHexFromColor(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  static List<Color> getAllColors() {
    return _colors.map((c) => c['color'] as Color).toList();
  }

  static List<String> getAllHexColors() {
    return _colors.map((c) => c['hex'] as String).toList();
  }
}