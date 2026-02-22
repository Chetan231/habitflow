import 'package:hive_flutter/hive_flutter.dart';
import '../features/habits/domain/models/habit.dart';
import '../features/habits/domain/models/habit_entry.dart';
import '../features/habits/domain/models/streak.dart';

class HiveBoxes {
  static const String habits = 'habits';
  static const String habitEntries = 'habit_entries';
  static const String streaks = 'streaks';
  static const String settings = 'settings';
  static const String offlineQueue = 'offline_queue';

  static Future<void> init() async {
    await Hive.openBox<Habit>(habits);
    await Hive.openBox<HabitEntry>(habitEntries);
    await Hive.openBox<Streak>(streaks);
    await Hive.openBox(settings);
    await Hive.openBox<Map>(offlineQueue);
  }

  // Getters for easy access
  static Box<Habit> get habitsBox => Hive.box<Habit>(habits);
  static Box<HabitEntry> get habitEntriesBox => Hive.box<HabitEntry>(habitEntries);
  static Box<Streak> get streaksBox => Hive.box<Streak>(streaks);
  static Box get settingsBox => Hive.box(settings);
  static Box<Map> get offlineQueueBox => Hive.box<Map>(offlineQueue);

  static Future<void> clearAllData() async {
    await habitsBox.clear();
    await habitEntriesBox.clear();
    await streaksBox.clear();
    // Keep settings and offline queue
  }

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}