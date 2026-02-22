import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../core/services/supabase_service.dart';
import '../features/habits/domain/models/habit.dart';
import '../features/habits/domain/models/habit_entry.dart';
import '../features/habits/domain/models/streak.dart';
import 'hive_boxes.dart';

enum OfflineOperationType {
  createHabit,
  updateHabit,
  deleteHabit,
  createHabitEntry,
  updateHabitEntry,
  deleteHabitEntry,
  updateStreak,
}

class OfflineOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'],
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  OfflineOperation copyWith({
    String? id,
    OfflineOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class OfflineQueue {
  static OfflineQueue? _instance;
  static OfflineQueue get instance => _instance ??= OfflineQueue._();
  
  OfflineQueue._();

  static const int maxRetries = 3;
  final Uuid _uuid = const Uuid();
  final SupabaseService _supabase = SupabaseService.instance;

  Box<Map>? _queueBox;

  Future<void> initialize() async {
    _queueBox = HiveBoxes.offlineQueueBox;
  }

  Future<void> addOperation({
    required OfflineOperationType type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
  }) async {
    final operation = OfflineOperation(
      id: _uuid.v4(),
      type: type,
      data: data,
      timestamp: timestamp,
    );

    await _queueBox?.put(operation.id, operation.toJson().cast<String, dynamic>());
  }

  Future<void> processQueue() async {
    if (_queueBox == null) return;

    final operations = <OfflineOperation>[];
    
    for (final entry in _queueBox!.values) {
      try {
        final operation = OfflineOperation.fromJson(
          Map<String, dynamic>.from(entry.cast<String, dynamic>()),
        );
        operations.add(operation);
      } catch (e) {
        // Skip invalid operations
        continue;
      }
    }

    // Sort by timestamp to process in order
    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final operation in operations) {
      try {
        await _processOperation(operation);
        await _queueBox!.delete(operation.id);
      } catch (e) {
        if (operation.retryCount < maxRetries) {
          // Increment retry count and keep in queue
          final updatedOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
          );
          await _queueBox!.put(operation.id, updatedOperation.toJson().cast<String, dynamic>());
        } else {
          // Max retries reached, remove from queue
          await _queueBox!.delete(operation.id);
        }
      }
    }
  }

  Future<void> _processOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case OfflineOperationType.createHabit:
        final habit = Habit.fromJson(operation.data);
        await _supabase.createHabit(habit);
        break;

      case OfflineOperationType.updateHabit:
        final habit = Habit.fromJson(operation.data);
        await _supabase.updateHabit(habit);
        break;

      case OfflineOperationType.deleteHabit:
        final habitId = operation.data['id'] as String;
        await _supabase.deleteHabit(habitId);
        break;

      case OfflineOperationType.createHabitEntry:
      case OfflineOperationType.updateHabitEntry:
        final entry = HabitEntry.fromJson(operation.data);
        await _supabase.createOrUpdateHabitEntry(entry);
        break;

      case OfflineOperationType.deleteHabitEntry:
        final entryId = operation.data['id'] as String;
        await _supabase.deleteHabitEntry(entryId);
        break;

      case OfflineOperationType.updateStreak:
        final streak = Streak.fromJson(operation.data);
        await _supabase.createOrUpdateStreak(streak);
        break;
    }
  }

  Future<List<OfflineOperation>> getPendingOperations() async {
    if (_queueBox == null) return [];

    final operations = <OfflineOperation>[];
    
    for (final entry in _queueBox!.values) {
      try {
        final operation = OfflineOperation.fromJson(
          Map<String, dynamic>.from(entry.cast<String, dynamic>()),
        );
        operations.add(operation);
      } catch (e) {
        continue;
      }
    }

    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return operations;
  }

  Future<void> clearQueue() async {
    await _queueBox?.clear();
  }

  Future<void> removeOperation(String operationId) async {
    await _queueBox?.delete(operationId);
  }

  int get pendingCount => _queueBox?.length ?? 0;

  bool get hasPendingOperations => pendingCount > 0;

  Future<Map<OfflineOperationType, int>> getOperationCounts() async {
    final operations = await getPendingOperations();
    final counts = <OfflineOperationType, int>{};
    
    for (final operation in operations) {
      counts[operation.type] = (counts[operation.type] ?? 0) + 1;
    }
    
    return counts;
  }

  Future<void> retryFailedOperations() async {
    if (_queueBox == null) return;

    final operations = await getPendingOperations();
    final failedOperations = operations.where((op) => op.retryCount > 0);

    for (final operation in failedOperations) {
      try {
        await _processOperation(operation);
        await _queueBox!.delete(operation.id);
      } catch (e) {
        // Keep the operation in queue with current retry count
        continue;
      }
    }
  }

  // Utility methods for common operations
  Future<void> queueHabitCreate(Habit habit) async {
    await addOperation(
      type: OfflineOperationType.createHabit,
      data: habit.toJson(),
      timestamp: DateTime.now(),
    );
  }

  Future<void> queueHabitUpdate(Habit habit) async {
    await addOperation(
      type: OfflineOperationType.updateHabit,
      data: habit.toJson(),
      timestamp: DateTime.now(),
    );
  }

  Future<void> queueHabitDelete(String habitId) async {
    await addOperation(
      type: OfflineOperationType.deleteHabit,
      data: {'id': habitId},
      timestamp: DateTime.now(),
    );
  }

  Future<void> queueHabitEntryUpdate(HabitEntry entry) async {
    await addOperation(
      type: OfflineOperationType.updateHabitEntry,
      data: entry.toJson(),
      timestamp: DateTime.now(),
    );
  }

  Future<void> queueStreakUpdate(Streak streak) async {
    await addOperation(
      type: OfflineOperationType.updateStreak,
      data: streak.toJson(),
      timestamp: DateTime.now(),
    );
  }
}