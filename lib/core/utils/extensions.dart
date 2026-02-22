import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Create Color from hex string
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Convert Color to hex string
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Lighten the color by a percentage
  Color lighten(double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + percentage).clamp(0.0, 1.0))
        .toColor();
  }

  /// Darken the color by a percentage
  Color darken(double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - percentage).clamp(0.0, 1.0))
        .toColor();
  }

  /// Get a contrasting color (black or white) for text
  Color getContrastingColor() {
    // Calculate luminance
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Create a gradient with this color
  LinearGradient createGradient({
    Color? endColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [this, endColor ?? lighten(0.2)],
      begin: begin,
      end: end,
    );
  }
}

extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    return split(' ')
        .map((word) => word.capitalize)
        .join(' ');
  }

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is valid password (at least 6 characters)
  bool get isValidPassword {
    return length >= 6;
  }

  /// Remove extra whitespace
  String get trimmed {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Get initials from full name
  String get initials {
    final words = trimmed.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Truncate string to max length
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// Static utility class for DateTime extensions
class DateTimeExtensions {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}

extension DateTimeExtension on DateTime {
  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Get difference in days from another date
  int daysDifference(DateTime other) {
    return startOfDay.difference(other.startOfDay).inDays;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  /// Convert to DateTime with today's date
  DateTime toDateTime([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Convert to minutes since midnight
  int get totalMinutes => hour * 60 + minute;

  /// Create TimeOfDay from minutes since midnight
  static TimeOfDay fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  /// Format as string
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Check if before another time
  bool isBefore(TimeOfDay other) {
    return totalMinutes < other.totalMinutes;
  }

  /// Check if after another time
  bool isAfter(TimeOfDay other) {
    return totalMinutes > other.totalMinutes;
  }
}

extension ListExtension<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get random element
  T? get randomElement {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Chunk list into smaller lists of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

extension BuildContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is tablet
  bool get isTablet => screenWidth > 600;

  /// Check if device is mobile
  bool get isMobile => screenWidth <= 600;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: theme.colorScheme.error);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Navigate to route
  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route
  void pushReplacementNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Pop current route
  void pop([Object? result]) {
    Navigator.of(this).pop(result);
  }

  /// Pop until root
  void popUntilRoot() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

extension DoubleExtension on double {
  /// Clamp to 0-1 range
  double get normalized => clamp(0.0, 1.0);

  /// Convert to percentage string
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Round to specified decimal places
  double roundTo(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }
}

extension IntExtension on int {
  /// Convert to ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Pluralize a word based on count
  String pluralize(String singular, [String? plural]) {
    if (this == 1) return singular;
    return plural ?? '${singular}s';
  }
}