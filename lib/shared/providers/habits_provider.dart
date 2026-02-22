import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/date_utils.dart';

// Habit notifier
class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier(this._supabaseService, this._habitsBox) 
      : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final SupabaseService _supabaseService;
  final Box<Habit> _habitsBox;

  Future<void> loadHabits() async {
    try {
      state = const AsyncValue.loading();
      
      // Load from local cache first
      final cachedHabits = _habitsBox.values
          .where((habit) => !habit.isArchived)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      
      if (cachedHabits.isNotEmpty) {
        state = AsyncValue.data(cachedHabits);
      }
      
      // Then sync with server
      final serverHabits = await _supabaseService.getHabits();
      
      // Update local cache
      await _habitsBox.clear();
      for (final habit in serverHabits) {
        await _habitsBox.put(habit.id, habit);
      }
      
      final filteredHabits = serverHabits
          .where((habit) => !habit.isArchived)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      
      state = AsyncValue.data(filteredHabits);
    } catch (error, stackTrace) {
      // If server fails, use cached data
      final cachedHabits = _habitsBox.values
          .where((habit) => !habit.isArchived)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      
      if (cachedHabits.isNotEmpty) {
        state = AsyncValue.data(cachedHabits);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      // Optimistically add to local state
      final currentHabits = state.value ?? [];
      final updatedHabit = habit.copyWith(
        position: currentHabits.length,
      );
      
      state = AsyncValue.data([...currentHabits, updatedHabit]);
      
      // Add to local cache
      await _habitsBox.put(updatedHabit.id, updatedHabit);
      
      // Sync to server
      await _supabaseService.insertHabit(updatedHabit);
    } catch (error, stackTrace) {
      // Revert on error
      await loadHabits();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final currentHabits = state.value ?? [];
      final index = currentHabits.indexWhere((h) => h.id == habit.id);
      
      if (index != -1) {
        final updatedHabits = [...currentHabits];
        updatedHabits[index] = habit;
        state = AsyncValue.data(updatedHabits);
        
        // Update local cache
        await _habitsBox.put(habit.id, habit);
        
        // Sync to server
        await _supabaseService.updateHabit(habit);
      }
    } catch (error, stackTrace) {
      // Revert on error
      await loadHabits();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      final currentHabits = state.value ?? [];
      final updatedHabits = currentHabits.where((h) => h.id != habitId).toList();
      state = AsyncValue.data(updatedHabits);
      
      // Remove from local cache
      await _habitsBox.delete(habitId);
      
      // Sync to server
      await _supabaseService.deleteHabit(habitId);
    } catch (error, stackTrace) {
      // Revert on error
      await loadHabits();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reorderHabits(List<Habit> reorderedHabits) async {
    try {
      // Update positions
      final updatedHabits = reorderedHabits.asMap().entries.map((entry) {
        return entry.value.copyWith(position: entry.key);
      }).toList();
      
      state = AsyncValue.data(updatedHabits);
      
      // Update local cache
      for (final habit in updatedHabits) {
        await _habitsBox.put(habit.id, habit);
      }
      
      // Batch update to server
      await _supabaseService.batchUpdateHabits(updatedHabits);
    } catch (error, stackTrace) {
      // Revert on error
      await loadHabits();
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Today entries notifier
class TodayEntriesNotifier extends StateNotifier<AsyncValue<Map<String, HabitEntry>>> {
  TodayEntriesNotifier(this._supabaseService, this._entriesBox) 
      : super(const AsyncValue.loading()) {
    loadTodayEntries();
  }

  final SupabaseService _supabaseService;
  final Box<HabitEntry> _entriesBox;

  Future<void> loadTodayEntries() async {
    try {
      state = const AsyncValue.loading();
      final today = DateUtils.today();
      final todayKey = DateUtils.formatDate(today);
      
      // Load from local cache first
      final cachedEntries = <String, HabitEntry>{};
      for (final entry in _entriesBox.values) {
        if (DateUtils.isSameDay(entry.date, today)) {
          cachedEntries[entry.habitId] = entry;
        }
      }
      
      if (cachedEntries.isNotEmpty) {
        state = AsyncValue.data(cachedEntries);
      }
      
      // Then sync with server
      final serverEntries = await _supabaseService.getEntriesForDate(today);
      
      // Update local cache
      final entriesToCache = <String, HabitEntry>{};
      for (final entry in serverEntries) {
        entriesToCache[entry.habitId] = entry;
        await _entriesBox.put('${entry.habitId}_$todayKey', entry);
      }
      
      state = AsyncValue.data(entriesToCache);
    } catch (error, stackTrace) {
      // If server fails, use cached data
      final today = DateUtils.today();
      final cachedEntries = <String, HabitEntry>{};
      for (final entry in _entriesBox.values) {
        if (DateUtils.isSameDay(entry.date, today)) {
          cachedEntries[entry.habitId] = entry;
        }
      }
      
      if (cachedEntries.isNotEmpty) {
        state = AsyncValue.data(cachedEntries);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> toggleEntry(String habitId) async {
    try {
      final currentEntries = state.value ?? {};
      final today = DateUtils.today();
      final existingEntry = currentEntries[habitId];
      
      HabitEntry newEntry;
      if (existingEntry != null) {
        newEntry = existingEntry.copyWith(
          completed: !existingEntry.completed,
          completedAt: !existingEntry.completed ? DateTime.now() : null,
        );
      } else {
        newEntry = HabitEntry(
          id: '${habitId}_${DateUtils.formatDate(today)}',
          habitId: habitId,
          date: today,
          completed: true,
          completedAt: DateTime.now(),
        );
      }
      
      // Update local state
      final updatedEntries = {...currentEntries};
      updatedEntries[habitId] = newEntry;
      state = AsyncValue.data(updatedEntries);
      
      // Update local cache
      await _entriesBox.put(newEntry.id, newEntry);
      
      // Sync to server
      await _supabaseService.upsertEntry(newEntry);
    } catch (error, stackTrace) {
      // Revert on error
      await loadTodayEntries();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateEntryValue(String habitId, double value) async {
    try {
      final currentEntries = state.value ?? {};
      final today = DateUtils.today();
      final existingEntry = currentEntries[habitId];
      
      HabitEntry newEntry;
      if (existingEntry != null) {
        newEntry = existingEntry.copyWith(
          value: value,
          completed: value > 0,
          completedAt: value > 0 && existingEntry.completedAt == null 
              ? DateTime.now() 
              : existingEntry.completedAt,
        );
      } else {
        newEntry = HabitEntry(
          id: '${habitId}_${DateUtils.formatDate(today)}',
          habitId: habitId,
          date: today,
          completed: value > 0,
          value: value,
          completedAt: value > 0 ? DateTime.now() : null,
        );
      }
      
      // Update local state
      final updatedEntries = {...currentEntries};
      updatedEntries[habitId] = newEntry;
      state = AsyncValue.data(updatedEntries);
      
      // Update local cache
      await _entriesBox.put(newEntry.id, newEntry);
      
      // Sync to server
      await _supabaseService.upsertEntry(newEntry);
    } catch (error, stackTrace) {
      // Revert on error
      await loadTodayEntries();
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final habitsBoxProvider = Provider<Box<Habit>>((ref) {
  return Hive.box<Habit>('habits');
});

final entriesBoxProvider = Provider<Box<HabitEntry>>((ref) {
  return Hive.box<HabitEntry>('habit_entries');
});

final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final habitsBox = ref.watch(habitsBoxProvider);
  return HabitsNotifier(supabaseService, habitsBox);
});

final todayEntriesProvider = StateNotifierProvider<TodayEntriesNotifier, AsyncValue<Map<String, HabitEntry>>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final entriesBox = ref.watch(entriesBoxProvider);
  return TodayEntriesNotifier(supabaseService, entriesBox);
});

final dailyProgressProvider = Provider<double>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final entriesAsync = ref.watch(todayEntriesProvider);
  
  return habitsAsync.when(
    data: (habits) {
      return entriesAsync.when(
        data: (entries) {
          if (habits.isEmpty) return 0.0;
          
          final today = DateUtils.today();
          final activeHabits = habits.where((habit) => habit.isActiveOnDate(today)).toList();
          
          if (activeHabits.isEmpty) return 0.0;
          
          int completedCount = 0;
          for (final habit in activeHabits) {
            final entry = entries[habit.id];
            if (entry != null && entry.completed) {
              // For count/timer habits, check if target is met
              if (habit.habitType == HabitType.count || habit.habitType == HabitType.timer) {
                if (entry.value >= habit.targetValue) {
                  completedCount++;
                }
              } else {
                // For yes/no habits, just check completed flag
                completedCount++;
              }
            }
          }
          
          return completedCount / activeHabits.length;
        },
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Helper provider for habit entry by id
final habitEntryProvider = Provider.family<HabitEntry?, String>((ref, habitId) {
  final entriesAsync = ref.watch(todayEntriesProvider);
  return entriesAsync.when(
    data: (entries) => entries[habitId],
    loading: () => null,
    error: (_, __) => null,
  );
});

// Helper provider for habit by id
final habitProvider = Provider.family<Habit?, String>((ref, habitId) {
  final habitsAsync = ref.watch(habitsProvider);
  return habitsAsync.when(
    data: (habits) => habits.firstWhere(
      (habit) => habit.id == habitId,
      orElse: () => null,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});