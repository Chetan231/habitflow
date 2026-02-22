import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'streak.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class Streak extends HiveObject {
  @HiveField(0)
  final String habitId;
  
  @HiveField(1)
  final int currentStreak;
  
  @HiveField(2)
  final int longestStreak;
  
  @HiveField(3)
  final DateTime? lastCompletedDate;
  
  @HiveField(4)
  final DateTime? streakStartDate;

  const Streak({
    required this.habitId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.streakStartDate,
  });

  factory Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);
  Map<String, dynamic> toJson() => _$StreakToJson(this);

  Streak copyWith({
    String? habitId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    DateTime? streakStartDate,
  }) {
    return Streak(
      habitId: habitId ?? this.habitId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
    );
  }

  // Helper methods
  bool get isActive => currentStreak > 0;
  
  bool get isAtRisk {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedDate!.year, 
      lastCompletedDate!.month, 
      lastCompletedDate!.day
    );
    
    // Streak is at risk if last completion was not yesterday or today
    return today.difference(lastCompleted).inDays > 1;
  }

  bool get isBroken {
    return isAtRisk && currentStreak == 0;
  }

  String get streakEmoji {
    if (currentStreak == 0) return '⚫';
    if (currentStreak >= 100) return '💎';
    if (currentStreak >= 50) return '👑';
    if (currentStreak >= 30) return '🔥';
    if (currentStreak >= 21) return '⚡';
    if (currentStreak >= 14) return '✨';
    if (currentStreak >= 7) return '🌟';
    if (currentStreak >= 3) return '🔆';
    return '⭐';
  }

  String get streakDescription {
    if (currentStreak == 0) return 'Start your streak!';
    if (currentStreak == 1) return '1 day streak';
    if (currentStreak < 7) return '$currentStreak day streak';
    if (currentStreak < 14) return '1 week streak!';
    if (currentStreak < 30) return '${(currentStreak / 7).floor()} week streak!';
    if (currentStreak < 365) return '${(currentStreak / 30).floor()} month streak!';
    return '${(currentStreak / 365).floor()} year streak!';
  }

  String get motivationalMessage {
    if (currentStreak == 0) return 'Every expert was once a beginner!';
    if (currentStreak == 1) return 'Great start! Keep the momentum going!';
    if (currentStreak == 7) return 'One week strong! You\'re building a habit!';
    if (currentStreak == 21) return 'Amazing! 21 days - you\'re forming a real habit!';
    if (currentStreak == 30) return 'Incredible! 30 days of consistency!';
    if (currentStreak == 100) return 'Legendary! 100 days of pure dedication!';
    if (currentStreak % 50 == 0) return 'Phenomenal! ${currentStreak} days of excellence!';
    if (currentStreak % 30 == 0) return 'Outstanding! ${currentStreak} days streak!';
    if (currentStreak % 7 == 0) return 'Fantastic! ${currentStreak} days in a row!';
    return 'Keep going strong! ${currentStreak} days and counting!';
  }

  Duration? get streakDuration {
    if (streakStartDate == null || lastCompletedDate == null) return null;
    return lastCompletedDate!.difference(streakStartDate!);
  }

  int get daysUntilMilestone {
    final milestones = [7, 14, 21, 30, 50, 100, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone - currentStreak;
      }
    }
    return 0;
  }

  String get nextMilestone {
    final milestones = [
      (7, '1 week'),
      (14, '2 weeks'),
      (21, '3 weeks'),
      (30, '1 month'),
      (50, '50 days'),
      (100, '100 days'),
      (365, '1 year'),
    ];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone.$1) {
        return milestone.$2;
      }
    }
    return 'Legend status';
  }

  double get progressToNextMilestone {
    final milestones = [7, 14, 21, 30, 50, 100, 365];
    int? previousMilestone;
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        final previous = previousMilestone ?? 0;
        return (currentStreak - previous) / (milestone - previous);
      }
      previousMilestone = milestone;
    }
    return 1.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Streak &&
        other.habitId == habitId &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak;
  }

  @override
  int get hashCode {
    return Object.hash(
      habitId,
      currentStreak,
      longestStreak,
    );
  }

  @override
  String toString() {
    return 'Streak(habitId: $habitId, current: $currentStreak, longest: $longestStreak, isActive: $isActive)';
  }
}