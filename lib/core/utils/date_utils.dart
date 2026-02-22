import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Get today's date without time
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get yesterday's date
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// Get tomorrow's date
  static DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  /// Get the start of the current week (Monday)
  static DateTime get startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get the end of the current week (Sunday)
  static DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6));
  }

  /// Get the start of the current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get the end of the current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, today);
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    return isSameDay(date, yesterday);
  }

  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Format date as day name (e.g., "Monday")
  static String formatDayName(DateTime date) {
    return _dayFormat.format(date);
  }

  /// Format date as full date (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date as short date (e.g., "Jan 15")
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format time (e.g., "14:30")
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Format month and year (e.g., "January 2024")
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format date as ISO string (yyyy-MM-dd)
  static String formatIso(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Parse ISO date string
  static DateTime parseIso(String isoString) {
    return DateTime.parse(isoString);
  }

  /// Get relative date string (e.g., "Today", "Yesterday", "2 days ago")
  static String getRelativeDate(DateTime date) {
    final now = today;
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 0) {
      return '$difference days ago';
    } else {
      return 'In ${-difference} days';
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Get days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get list of dates for a month
  static List<DateTime> getMonthDates(int year, int month) {
    final daysInMonth = getDaysInMonth(year, month);
    return List.generate(
      daysInMonth,
      (index) => DateTime(year, month, index + 1),
    );
  }

  /// Get list of dates for current week
  static List<DateTime> getWeekDates([DateTime? startDate]) {
    final start = startDate ?? startOfWeek;
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  /// Calculate streak between consecutive dates
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order
    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = today;

    // Check if today is completed, if not, start from yesterday
    if (!completedDates.any((date) => isSameDay(date, today))) {
      currentDate = yesterday;
    }

    // Count consecutive days backwards from current date
    for (final completedDate in sortedDates) {
      if (isSameDay(completedDate, currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get completion rate for a date range
  static double getCompletionRate(
    List<DateTime> completedDates,
    List<DateTime> scheduledDates,
  ) {
    if (scheduledDates.isEmpty) return 0.0;

    int completedCount = 0;
    for (final scheduledDate in scheduledDates) {
      if (completedDates.any((date) => isSameDay(date, scheduledDate))) {
        completedCount++;
      }
    }

    return completedCount / scheduledDates.length;
  }

  /// Get week number of year
  static int getWeekOfYear(DateTime date) {
    final jan1 = DateTime(date.year, 1, 1);
    final days = date.difference(jan1).inDays + 1;
    return ((days - date.weekday + 10) / 7).floor();
  }

  /// Get dates for last N days
  static List<DateTime> getLastNDays(int n) {
    return List.generate(
      n,
      (index) => today.subtract(Duration(days: index)),
    ).reversed.toList();
  }

  /// Get dates for next N days
  static List<DateTime> getNextNDays(int n) {
    return List.generate(
      n,
      (index) => today.add(Duration(days: index)),
    );
  }

  /// Check if habit should be active on given weekdays
  static bool isHabitActiveOnDate(DateTime date, List<int> frequencyDays) {
    if (frequencyDays.isEmpty) return true;
    
    // Convert DateTime weekday (1-7, Mon-Sun) to match our frequency days (1-7, Mon-Sun)
    return frequencyDays.contains(date.weekday);
  }

  /// Get weekday abbreviations
  static List<String> get weekdayAbbreviations {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  /// Get month abbreviations
  static List<String> get monthAbbreviations {
    return [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
  }

  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Create time of day from DateTime
  static TimeOfDay timeOfDayFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Create DateTime from date and TimeOfDay
  static DateTime dateTimeFromTimeOfDay(DateTime date, TimeOfDay timeOfDay) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}