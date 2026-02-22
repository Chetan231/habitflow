import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'supabase_service.dart';
import '../utils/date_utils.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';
import '../../features/habits/domain/models/streak.dart';
import '../../local/hive_boxes.dart';
import '../../local/offline_queue.dart';

enum SyncStatus { idle, syncing, completed, error }

class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  
  SyncService._();

  final SupabaseService _supabase = SupabaseService.instance;
  final Connectivity _connectivity = Connectivity();
  final OfflineQueue _offlineQueue = OfflineQueue.instance;
  
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  Timer? _autoSyncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Future<void> initialize() async {
    await _offlineQueue.initialize();
    _setupConnectivityListener();
    _startAutoSync();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && _currentStatus != SyncStatus.syncing) {
        syncAll();
      }
    });
  }

  void _startAutoSync() {
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_currentStatus != SyncStatus.syncing) {
        syncAll();
      }
    });
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;
    
    return await _supabase.isConnected();
  }

  Future<void> syncAll() async {
    if (_currentStatus == SyncStatus.syncing) return;
    
    _updateStatus(SyncStatus.syncing);
    
    try {
      if (await _isOnline()) {
        // Process offline queue first
        await _offlineQueue.processQueue();
        
        // Sync data bidirectionally
        await _syncHabits();
        await _syncHabitEntries();
        await _syncStreaks();
        
        _updateStatus(SyncStatus.completed);
      } else {
        _updateStatus(SyncStatus.idle);
      }
    } catch (e) {
      _updateStatus(SyncStatus.error);
      rethrow;
    }
  }

  Future<void> _syncHabits() async {
    final localBox = Hive.box<Habit>(HiveBoxes.habits);
    final remoteHabits = await _supabase.getHabits();
    
    // Create maps for easier lookup
    final localHabits = {for (var habit in localBox.values) habit.id: habit};
    final remoteHabitsMap = {for (var habit in remoteHabits) habit.id: habit};
    
    // Sync from remote to local (download)
    for (final remoteHabit in remoteHabits) {
      final localHabit = localHabits[remoteHabit.id];
      
      if (localHabit == null) {
        // New habit from remote
        await localBox.put(remoteHabit.id, remoteHabit);
      } else {
        // Check if remote is newer
        if (remoteHabit.updatedAt.isAfter(localHabit.updatedAt)) {
          await localBox.put(remoteHabit.id, remoteHabit);
        }
      }
    }
    
    // Sync from local to remote (upload)
    for (final localHabit in localBox.values) {
      final remoteHabit = remoteHabitsMap[localHabit.id];
      
      if (remoteHabit == null) {
        // New habit to upload
        try {
          final uploadedHabit = await _supabase.createHabit(localHabit);
          await localBox.put(uploadedHabit.id, uploadedHabit);
        } catch (e) {
          // Handle conflict or error
          continue;
        }
      } else {
        // Check if local is newer
        if (localHabit.updatedAt.isAfter(remoteHabit.updatedAt)) {
          try {
            await _supabase.updateHabit(localHabit);
          } catch (e) {
            // Handle conflict or error
            continue;
          }
        }
      }
    }
  }

  Future<void> _syncHabitEntries() async {
    final localBox = Hive.box<HabitEntry>(HiveBoxes.habitEntries);
    
    // Sync last 30 days of entries
    final endDate = AppDateUtils.today;
    final startDate = endDate.subtract(const Duration(days: 30));
    
    final remoteEntries = await _supabase.getHabitEntries(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Create maps for easier lookup
    final localEntries = <String, HabitEntry>{};
    for (final entry in localBox.values) {
      final key = '${entry.habitId}_${AppDateUtils.formatIso(entry.date)}';
      localEntries[key] = entry;
    }
    
    final remoteEntriesMap = <String, HabitEntry>{};
    for (final entry in remoteEntries) {
      final key = '${entry.habitId}_${AppDateUtils.formatIso(entry.date)}';
      remoteEntriesMap[key] = entry;
    }
    
    // Sync from remote to local (download)
    for (final remoteEntry in remoteEntries) {
      final key = '${remoteEntry.habitId}_${AppDateUtils.formatIso(remoteEntry.date)}';
      final localEntry = localEntries[key];
      
      if (localEntry == null) {
        // New entry from remote
        await localBox.put(remoteEntry.id, remoteEntry);
      } else {
        // Check if remote is newer
        if (remoteEntry.completedAt != null && 
            (localEntry.completedAt == null || 
             remoteEntry.completedAt!.isAfter(localEntry.completedAt!))) {
          await localBox.put(remoteEntry.id, remoteEntry);
        }
      }
    }
    
    // Sync from local to remote (upload)
    for (final localEntry in localBox.values) {
      // Only sync recent entries
      if (localEntry.date.isBefore(startDate)) continue;
      
      final key = '${localEntry.habitId}_${AppDateUtils.formatIso(localEntry.date)}';
      final remoteEntry = remoteEntriesMap[key];
      
      if (remoteEntry == null) {
        // New entry to upload
        try {
          final uploadedEntry = await _supabase.createOrUpdateHabitEntry(localEntry);
          await localBox.put(uploadedEntry.id, uploadedEntry);
        } catch (e) {
          // Handle conflict or error
          continue;
        }
      } else {
        // Check if local is newer
        if (localEntry.completedAt != null && 
            (remoteEntry.completedAt == null || 
             localEntry.completedAt!.isAfter(remoteEntry.completedAt!))) {
          try {
            final updatedEntry = await _supabase.createOrUpdateHabitEntry(localEntry);
            await localBox.put(updatedEntry.id, updatedEntry);
          } catch (e) {
            // Handle conflict or error
            continue;
          }
        }
      }
    }
  }

  Future<void> _syncStreaks() async {
    final localBox = Hive.box<Streak>(HiveBoxes.streaks);
    final remoteStreaks = await _supabase.getStreaks();
    
    // Create maps for easier lookup
    final localStreaks = {for (var streak in localBox.values) streak.habitId: streak};
    final remoteStreaksMap = {for (var streak in remoteStreaks) streak.habitId: streak};
    
    // Sync from remote to local (download)
    for (final remoteStreak in remoteStreaks) {
      final localStreak = localStreaks[remoteStreak.habitId];
      
      if (localStreak == null) {
        // New streak from remote
        await localBox.put(remoteStreak.habitId, remoteStreak);
      } else {
        // Use the streak with higher values (more recent data)
        if (remoteStreak.currentStreak > localStreak.currentStreak ||
            remoteStreak.longestStreak > localStreak.longestStreak) {
          await localBox.put(remoteStreak.habitId, remoteStreak);
        }
      }
    }
    
    // Sync from local to remote (upload)
    for (final localStreak in localBox.values) {
      final remoteStreak = remoteStreaksMap[localStreak.habitId];
      
      if (remoteStreak == null) {
        // New streak to upload
        try {
          await _supabase.createOrUpdateStreak(localStreak);
        } catch (e) {
          // Handle conflict or error
          continue;
        }
      } else {
        // Upload if local has higher values
        if (localStreak.currentStreak > remoteStreak.currentStreak ||
            localStreak.longestStreak > remoteStreak.longestStreak) {
          try {
            await _supabase.createOrUpdateStreak(localStreak);
          } catch (e) {
            // Handle conflict or error
            continue;
          }
        }
      }
    }
  }

  // Immediate sync methods for critical operations
  Future<void> syncHabitImmediately(Habit habit) async {
    if (await _isOnline()) {
      try {
        await _supabase.createHabit(habit);
      } catch (e) {
        await _offlineQueue.addOperation(
          type: OfflineOperationType.createHabit,
          data: habit.toJson(),
          timestamp: DateTime.now(),
        );
      }
    } else {
      await _offlineQueue.addOperation(
        type: OfflineOperationType.createHabit,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> syncHabitEntryImmediately(HabitEntry entry) async {
    if (await _isOnline()) {
      try {
        await _supabase.createOrUpdateHabitEntry(entry);
      } catch (e) {
        await _offlineQueue.addOperation(
          type: OfflineOperationType.updateHabitEntry,
          data: entry.toJson(),
          timestamp: DateTime.now(),
        );
      }
    } else {
      await _offlineQueue.addOperation(
        type: OfflineOperationType.updateHabitEntry,
        data: entry.toJson(),
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> syncStreakImmediately(Streak streak) async {
    if (await _isOnline()) {
      try {
        await _supabase.createOrUpdateStreak(streak);
      } catch (e) {
        await _offlineQueue.addOperation(
          type: OfflineOperationType.updateStreak,
          data: streak.toJson(),
          timestamp: DateTime.now(),
        );
      }
    } else {
      await _offlineQueue.addOperation(
        type: OfflineOperationType.updateStreak,
        data: streak.toJson(),
        timestamp: DateTime.now(),
      );
    }
  }

  // Manual sync triggers
  Future<void> forceSyncFromRemote() async {
    if (_currentStatus == SyncStatus.syncing) return;
    
    _updateStatus(SyncStatus.syncing);
    
    try {
      if (await _isOnline()) {
        // Clear local data and re-download
        await _clearLocalData();
        
        final remoteHabits = await _supabase.getHabits();
        final remoteEntries = await _supabase.getHabitEntries();
        final remoteStreaks = await _supabase.getStreaks();
        
        // Populate local storage
        final habitsBox = Hive.box<Habit>(HiveBoxes.habits);
        for (final habit in remoteHabits) {
          await habitsBox.put(habit.id, habit);
        }
        
        final entriesBox = Hive.box<HabitEntry>(HiveBoxes.habitEntries);
        for (final entry in remoteEntries) {
          await entriesBox.put(entry.id, entry);
        }
        
        final streaksBox = Hive.box<Streak>(HiveBoxes.streaks);
        for (final streak in remoteStreaks) {
          await streaksBox.put(streak.habitId, streak);
        }
        
        _updateStatus(SyncStatus.completed);
      } else {
        throw Exception('No internet connection');
      }
    } catch (e) {
      _updateStatus(SyncStatus.error);
      rethrow;
    }
  }

  Future<void> _clearLocalData() async {
    await Hive.box<Habit>(HiveBoxes.habits).clear();
    await Hive.box<HabitEntry>(HiveBoxes.habitEntries).clear();
    await Hive.box<Streak>(HiveBoxes.streaks).clear();
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  // Conflict resolution helpers
  Future<void> resolveHabitConflict(Habit localHabit, Habit remoteHabit, {required bool preferLocal}) async {
    final habitToKeep = preferLocal ? localHabit : remoteHabit;
    
    if (await _isOnline()) {
      await _supabase.updateHabit(habitToKeep);
    }
    
    await Hive.box<Habit>(HiveBoxes.habits).put(habitToKeep.id, habitToKeep);
  }

  // Cleanup
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}