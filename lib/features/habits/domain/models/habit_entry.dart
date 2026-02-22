import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'habit_entry.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class HabitEntry extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String habitId;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final bool completed;
  
  @HiveField(4)
  final double value; // For count/timer habits
  
  @HiveField(5)
  final String notes;
  
  @HiveField(6)
  final DateTime? completedAt;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.value = 0.0,
    this.notes = '',
    this.completedAt,
  });

  factory HabitEntry.fromJson(Map<String, dynamic> json) => _$HabitEntryFromJson(json);
  Map<String, dynamic> toJson() => _$HabitEntryToJson(this);

  static HabitEntry empty() => HabitEntry(
        id: '',
        habitId: '',
        date: DateTime.now(),
      );

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    double? value,
    String? notes,
    DateTime? completedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods
  bool get isCompletedToday {
    final now = DateTime.now();
    return completed && 
           date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  String get formattedValue {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Duration get completionDuration {
    if (completedAt != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      return completedAt!.difference(startOfDay);
    }
    return Duration.zero;
  }

  String get completionTimeString {
    if (completedAt == null) return '';
    
    final hour = completedAt!.hour;
    final minute = completedAt!.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntry &&
        other.id == id &&
        other.habitId == habitId &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.completed == completed &&
        other.value == value;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      habitId,
      date.year,
      date.month,
      date.day,
      completed,
      value,
    );
  }

  @override
  String toString() {
    return 'HabitEntry(id: $id, habitId: $habitId, date: ${date.toString().split(' ')[0]}, completed: $completed, value: $value)';
  }
}