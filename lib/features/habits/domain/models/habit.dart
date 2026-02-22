import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/date_utils.dart';

part 'habit.g.dart';

@JsonEnum()
@HiveType(typeId: 0)
enum HabitType {
  @HiveField(0)
  @JsonValue('yes_no')
  yesNo,
  
  @HiveField(1)
  @JsonValue('count')
  count,
  
  @HiveField(2)
  @JsonValue('timer')
  timer,
}

@JsonSerializable()
@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String icon;
  
  @HiveField(3)
  final String color;
  
  @HiveField(4)
  final HabitType habitType;
  
  @HiveField(5)
  final int targetValue;
  
  @HiveField(6)
  final String unit;
  
  @HiveField(7)
  final List<int> frequencyDays; // 1-7 (Monday-Sunday)
  
  @HiveField(8)
  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay? reminderTime;
  
  @HiveField(9)
  final int position;
  
  @HiveField(10)
  final bool isArchived;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.habitType,
    this.targetValue = 1,
    this.unit = '',
    this.frequencyDays = const [],
    this.reminderTime,
    this.position = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);

  static Habit empty() => Habit(
        id: '',
        name: '',
        icon: '',
        color: '',
        habitType: HabitType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    HabitType? habitType,
    int? targetValue,
    String? unit,
    List<int>? frequencyDays,
    TimeOfDay? reminderTime,
    int? position,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      habitType: habitType ?? this.habitType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      reminderTime: reminderTime ?? this.reminderTime,
      position: position ?? this.position,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool isActiveToday() {
    if (frequencyDays.isEmpty) return true;
    return frequencyDays.contains(DateTime.now().weekday);
  }

  bool isActiveOnDate(DateTime date) {
    if (frequencyDays.isEmpty) return true;
    return frequencyDays.contains(date.weekday);
  }

  String get frequencyDescription {
    if (frequencyDays.isEmpty) return 'Daily';
    if (frequencyDays.length == 7) return 'Daily';
    if (frequencyDays.length == 5 && 
        frequencyDays.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    }
    if (frequencyDays.length == 2 && 
        frequencyDays.contains(6) && frequencyDays.contains(7)) {
      return 'Weekends';
    }
    
    final dayNames = frequencyDays.map((day) => _getDayName(day)).join(', ');
    return dayNames;
  }

  String get targetDescription {
    switch (habitType) {
      case HabitType.yesNo:
        return 'Complete';
      case HabitType.count:
        return '$targetValue ${unit.isNotEmpty ? unit : 'times'}';
      case HabitType.timer:
        return '$targetValue ${unit.isNotEmpty ? unit : 'minutes'}';
    }
  }

  String get iconEmoji {
    final iconMap = {
      'water': '💧',
      'exercise': '💪',
      'book': '📚',
      'meditation': '🧘',
      'sleep': '😴',
      'walk': '🚶',
      'healthy_food': '🥗',
      'no_phone': '📱',
      'journal': '📝',
      'stretch': '🤸',
      'music': '🎵',
      'art': '🎨',
      'work': '💼',
      'study': '📖',
      'code': '💻',
      'gym': '🏋️',
      'run': '🏃',
      'bike': '🚴',
      'swim': '🏊',
      'yoga': '🧘‍♀️',
    };
    
    return iconMap[icon] ?? '⭐';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  static TimeOfDay? _timeOfDayFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int);
  }

  static Map<String, dynamic>? _timeOfDayToJson(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return null;
    return {'hour': timeOfDay.hour, 'minute': timeOfDay.minute};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.habitType == habitType &&
        other.targetValue == targetValue &&
        other.unit == unit &&
        other.position == position &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      icon,
      color,
      habitType,
      targetValue,
      unit,
      position,
      isArchived,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, type: $habitType, target: $targetDescription, frequency: $frequencyDescription)';
  }
}

// Hive adapter for TimeOfDay since it's not a primitive type
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String format12Hour() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  DateTime toDateTime([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => format24Hour();
}