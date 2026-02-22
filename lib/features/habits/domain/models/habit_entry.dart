import 'package:hive/hive.dart';

class HabitEntry extends HiveObject {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final double value; // For count/timer habits
  final String notes;
  final DateTime? completedAt;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.value = 0.0,
    this.notes = '',
    this.completedAt,
  });

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'completed': completed,
      'value': value,
      'notes': notes,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

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

class HabitEntryAdapter extends TypeAdapter<HabitEntry> {
  @override
  final int typeId = 1;

  @override
  HabitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return HabitEntry(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
      completed: fields[3] as bool? ?? false,
      value: (fields[4] as num?)?.toDouble() ?? 0.0,
      notes: fields[5] as String? ?? '',
      completedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.completedAt);
  }
}