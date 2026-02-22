import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import 'package:intl/intl.dart';

class CalendarHeatmap extends StatefulWidget {
  final Map<DateTime, double> completionData;
  final DateTime? startDate;
  final DateTime? endDate;

  const CalendarHeatmap({
    super.key,
    required this.completionData,
    this.startDate,
    this.endDate,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  late ScrollController _scrollController;
  DateTime? _selectedDate;
  Offset? _tooltipPosition;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll to current week
      if (_scrollController.hasClients) {
        final now = DateTime.now();
        final startOfYear = DateTime(now.year, 1, 1);
        final daysDiff = now.difference(startOfYear).inDays;
        final weeks = (daysDiff / 7).floor();
        final scrollOffset = weeks * 16.0; // 14 width + 2 spacing
        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<List<DateTime?>> _generateWeeks() {
    final now = DateTime.now();
    final startDate = widget.startDate ?? DateTime(now.year, 1, 1);
    final endDate = widget.endDate ?? now;
    
    final weeks = <List<DateTime?>>[];
    DateTime currentDate = startDate;
    
    // Find the Monday of the first week
    while (currentDate.weekday != DateTime.monday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final week = <DateTime?>[];
      for (int i = 0; i < 7; i++) {
        if (currentDate.isAfter(endDate)) {
          week.add(null);
        } else {
          week.add(currentDate);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(week);
      
      // Break if we've gone too far into the future
      if (weeks.length > 53) break;
    }
    
    return weeks;
  }

  Color _getColorForCompletion(double completion) {
    if (completion == 0.0) {
      return AppColors.surface;
    } else if (completion <= 0.25) {
      return AppColors.primary.withOpacity(0.2);
    } else if (completion <= 0.5) {
      return AppColors.primary.withOpacity(0.4);
    } else if (completion <= 0.75) {
      return AppColors.primary.withOpacity(0.7);
    } else {
      return AppColors.primary;
    }
  }

  void _showTooltip(DateTime date, Offset position) {
    setState(() {
      _selectedDate = date;
      _tooltipPosition = position;
    });
  }

  void _hideTooltip() {
    setState(() {
      _selectedDate = null;
      _tooltipPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _generateWeeks();
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month labels
            Container(
              height: 20,
              margin: const EdgeInsets.only(left: 32),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++)
                      Container(
                        width: 16,
                        alignment: Alignment.centerLeft,
                        child: weeks[weekIndex][0] != null &&
                               weeks[weekIndex][0]!.day <= 7
                            ? Text(
                                DateFormat('MMM').format(weeks[weekIndex][0]!),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Heatmap grid
            SizedBox(
              height: 112, // 7 days * 14 height + spacing
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        for (int i = 0; i < 7; i++)
                          Container(
                            height: 14,
                            margin: const EdgeInsets.only(bottom: 2),
                            alignment: Alignment.centerRight,
                            child: Text(
                              dayLabels[i],
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Scrollable calendar grid
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++)
                            Container(
                              margin: const EdgeInsets.only(right: 2),
                              child: Column(
                                children: [
                                  for (int dayIndex = 0; dayIndex < 7; dayIndex++)
                                    GestureDetector(
                                      onTapDown: (details) {
                                        final date = weeks[weekIndex][dayIndex];
                                        if (date != null) {
                                          _showTooltip(date, details.globalPosition);
                                        }
                                      },
                                      onTap: () => _hideTooltip(),
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        margin: const EdgeInsets.only(bottom: 2),
                                        decoration: BoxDecoration(
                                          color: weeks[weekIndex][dayIndex] != null
                                              ? _getColorForCompletion(
                                                  widget.completionData[_normalizeDate(weeks[weekIndex][dayIndex]!)] ?? 0.0,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(2),
                                          border: weeks[weekIndex][dayIndex] != null &&
                                                 _isSameDay(weeks[weekIndex][dayIndex]!, now)
                                              ? Border.all(
                                                  color: AppColors.secondary,
                                                  width: 1.5,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Legend
            Row(
              children: [
                Text(
                  'Less',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                for (double intensity in [0.0, 0.25, 0.5, 0.75, 1.0])
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: _getColorForCompletion(intensity),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'More',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Tooltip
        if (_selectedDate != null && _tooltipPosition != null)
          Positioned(
            left: _tooltipPosition!.dx - 60,
            top: _tooltipPosition!.dy - 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate!),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${((widget.completionData[_normalizeDate(_selectedDate!)] ?? 0.0) * 100).toInt()}% complete',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}