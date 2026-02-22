import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_provider.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/extensions.dart';

// Daily completion percentage provider
final dailyCompletionProvider = Provider<double>((ref) {
  final todayHabits = ref.watch(todayHabitsProvider);
  final todayEntries = ref.watch(todayEntriesProvider);
  
  return todayHabits.when(
    data: (habits) => todayEntries.when(
      data: (entries) {
        if (habits.isEmpty) return 0.0;
        
        final completedHabits = habits.where((habit) {
          final entry = entries[habit.id];
          
          if (entry == null) return false;
          
          switch (habit.habitType) {
            case HabitType.yesNo:
              return entry.completed;
            case HabitType.count:
            case HabitType.timer:
              return entry.value >= habit.targetValue;
          }
        }).length;
        
        return completedHabits / habits.length;
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    ),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Current streaks provider
final currentStreaksProvider = Provider<AsyncValue<List<HabitStreak>>>((ref) {
  final habits = ref.watch(habitsProvider);
  final entries = ref.watch(habitEntriesProvider);
  
  return habits.when(
    data: (habitList) => entries.when(
      data: (entryList) {
        final streaks = habitList.map((habit) {
          final habitEntries = entryList
              .where((entry) => entry.habitId == habit.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          
          int currentStreak = 0;
          int longestStreak = 0;
          int tempStreak = 0;
          DateTime? lastDate;
          
          for (final entry in habitEntries.reversed) {
            final isCompleted = habit.habitType == HabitType.yesNo
                ? entry.completed
                : entry.value >= habit.targetValue;
            
            if (isCompleted) {
              tempStreak++;
              if (lastDate == null || 
                  entry.date.difference(lastDate).inDays == 1 ||
                  DateTimeExtensions.isSameDay(entry.date, lastDate.add(const Duration(days: 1)))) {
                if (tempStreak > longestStreak) {
                  longestStreak = tempStreak;
                }
              }
            } else {
              if (DateTimeExtensions.isSameDay(entry.date, DateTime.now()) ||
                  entry.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                currentStreak = 0;
              } else {
                currentStreak = tempStreak;
              }
              tempStreak = 0;
            }
            lastDate = entry.date;
          }
          
          // Calculate current streak from today backwards
          final today = DateTimeExtensions.startOfDay(DateTime.now());
          currentStreak = 0;
          for (int i = 0; i < 30; i++) {
            final date = today.subtract(Duration(days: i));
            HabitEntry? dayEntry;
            try {
              dayEntry = entryList.firstWhere(
                (entry) => entry.habitId == habit.id && 
                           DateTimeExtensions.isSameDay(entry.date, date),
              );
            } catch (e) {
              break;
            }
            
            final isCompleted = habit.habitType == HabitType.yesNo
                ? dayEntry.completed
                : dayEntry.value >= habit.targetValue;
            
            if (isCompleted) {
              currentStreak++;
            } else {
              break;
            }
          }
          
          return HabitStreak(
            habitId: habit.id,
            habitName: habit.name,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
          );
        }).toList();
        
        return AsyncValue.data(streaks);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Weekly completion rate provider
final weeklyCompletionProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final habits = ref.watch(habitsProvider);
  final entries = ref.watch(habitEntriesProvider);
  
  return habits.when(
    data: (habitList) => entries.when(
      data: (entryList) {
        final today = DateTime.now();
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final weeklyData = <String, double>{};
        
        for (int i = 0; i < 7; i++) {
          final date = startOfWeek.add(Duration(days: i));
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
          
          final dayHabits = habitList.where((habit) => habit.isActiveOnDate(date));
          if (dayHabits.isEmpty) {
            weeklyData[dayName] = 0.0;
            continue;
          }
          
          final completedCount = dayHabits.where((habit) {
            HabitEntry? entry;
            try {
              entry = entryList.firstWhere(
                (e) => e.habitId == habit.id && 
                       DateTimeExtensions.isSameDay(e.date, date),
              );
            } catch (e) {
              return false;
            }
            
            return habit.habitType == HabitType.yesNo
                ? entry.completed
                : entry.value >= habit.targetValue;
          }).length;
          
          weeklyData[dayName] = dayHabits.isEmpty ? 0.0 : completedCount / dayHabits.length;
        }
        
        return AsyncValue.data(weeklyData);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Best performing habits provider
final bestHabitsProvider = Provider<AsyncValue<List<HabitPerformance>>>((ref) {
  final streaks = ref.watch(currentStreaksProvider);
  final habits = ref.watch(habitsProvider);
  
  return streaks.when(
    data: (streakList) => habits.when(
      data: (habitList) {
        final performances = streakList.map((streak) {
          final habit = habitList.firstWhere((h) => h.id == streak.habitId);
          return HabitPerformance(
            habit: habit,
            currentStreak: streak.currentStreak,
            longestStreak: streak.longestStreak,
            completionRate: _calculateCompletionRate(habit, ref),
          );
        }).toList()
          ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
        
        return AsyncValue.data(performances.take(5).toList());
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Heatmap data provider
final heatmapDataProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final entries = ref.watch(habitEntriesProvider);
  
  return entries.when(
    data: (entryList) {
      final heatmapData = <String, int>{};
      final completedEntries = entryList.where((entry) => entry.completed);
      
      for (final entry in completedEntries) {
        final dateKey = AppDateUtils.formatIso(entry.date);
        heatmapData[dateKey] = (heatmapData[dateKey] ?? 0) + 1;
      }
      
      return AsyncValue.data(heatmapData);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Weekly chart data provider
final weeklyDataProvider = Provider<AsyncValue<List<double>>>((ref) {
  final weeklyCompletion = ref.watch(weeklyCompletionProvider);
  
  return weeklyCompletion.when(
    data: (weeklyData) {
      final data = <double>[];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      for (final day in days) {
        data.add(weeklyData[day] ?? 0.0);
      }
      
      return AsyncValue.data(data);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Monthly chart data provider  
final monthlyDataProvider = Provider<AsyncValue<List<double>>>((ref) {
  final entries = ref.watch(habitEntriesProvider);
  final habits = ref.watch(habitsProvider);
  
  return entries.when(
    data: (entryList) => habits.when(
      data: (habitList) {
        final monthlyData = <double>[];
        final now = DateTime.now();
        
        for (int i = 29; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayHabits = habitList.where((habit) => habit.isActiveOnDate(date));
          
          if (dayHabits.isEmpty) {
            monthlyData.add(0.0);
            continue;
          }
          
          final completedCount = dayHabits.where((habit) {
            try {
              final entry = entryList.firstWhere(
                (e) => e.habitId == habit.id && 
                       DateTimeExtensions.isSameDay(e.date, date),
              );
              
              return habit.habitType == HabitType.yesNo
                  ? entry.completed
                  : entry.value >= habit.targetValue;
            } catch (e) {
              return false;
            }
          }).length;
          
          monthlyData.add(completedCount / dayHabits.length);
        }
        
        return AsyncValue.data(monthlyData);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

double _calculateCompletionRate(Habit habit, ProviderRef ref) {
  final entries = ref.read(habitEntriesProvider).value ?? [];
  final habitEntries = entries.where((e) => e.habitId == habit.id).toList();
  
  if (habitEntries.isEmpty) return 0.0;
  
  final completedEntries = habitEntries.where((entry) {
    return habit.habitType == HabitType.yesNo
        ? entry.completed
        : entry.value >= habit.targetValue;
  }).length;
  
  return completedEntries / habitEntries.length;
}

class HabitStreak {
  final String habitId;
  final String habitName;
  final int currentStreak;
  final int longestStreak;

  const HabitStreak({
    required this.habitId,
    required this.habitName,
    required this.currentStreak,
    required this.longestStreak,
  });
}

class HabitPerformance {
  final Habit habit;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;

  const HabitPerformance({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
  });
}