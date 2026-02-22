import 'package:hive/hive.dart';

enum HabitType {
  yesNo,
  count,
  timer,
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 3;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.yesNo;
      case 1:
        return HabitType.count;
      case 2:
        return HabitType.timer;
      default:
        return HabitType.yesNo;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.yesNo:
        writer.writeByte(0);
        break;
      case HabitType.count:
        writer.writeByte(1);
        break;
      case HabitType.timer:
        writer.writeByte(2);
        break;
    }
  }
}

class Habit extends HiveObject {
  final String id;
  final String name;
  final String icon;
  final String color;
  final HabitType habitType;
  final int targetValue;
  final String unit;
  final List<int> frequencyDays;
  final String? reminderTime; // Store as "HH:mm" string
  final int position;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
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

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      habitType: HabitType.values.firstWhere(
        (e) => e.toString().split('.').last == json['habitType'],
        orElse: () => HabitType.yesNo,
      ),
      targetValue: json['targetValue'] as int? ?? 1,
      unit: json['unit'] as String? ?? '',
      frequencyDays: List<int>.from(json['frequencyDays'] ?? []),
      reminderTime: json['reminderTime'] as String?,
      position: json['position'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'habitType': habitType.toString().split('.').last,
      'targetValue': targetValue,
      'unit': unit,
      'frequencyDays': frequencyDays,
      'reminderTime': reminderTime,
      'position': position,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
    String? reminderTime,
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

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as String,
      habitType: fields[4] as HabitType,
      targetValue: fields[5] as int? ?? 1,
      unit: fields[6] as String? ?? '',
      frequencyDays: fields[7] != null ? List<int>.from(fields[7]) : [],
      reminderTime: fields[8] as String?,
      position: fields[9] as int? ?? 0,
      isArchived: fields[10] as bool? ?? false,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.habitType)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.frequencyDays)
      ..writeByte(8)
      ..write(obj.reminderTime)
      ..writeByte(9)
      ..write(obj.position)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }
}