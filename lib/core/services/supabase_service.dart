import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show Provider;
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';
import '../../features/habits/domain/models/streak.dart';
import '../../features/auth/domain/models/user_profile.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  String? get userId => currentUser?.id;

  // Auth Methods
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _createUserProfile(response.user!);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await client.auth.signInWithOAuth(
        supa.Provider.google,
        redirectTo: 'io.supabase.habitflow://login-callback/',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // User Profile Methods
  Future<void> _createUserProfile(User user) async {
    try {
      final profile = UserProfile(
        id: user.id,
        email: user.email!,
        name: user.userMetadata?['full_name'] ?? 
              user.email!.split('@').first,
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await client.from('profiles').insert(profile.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      rethrow;
    }
  }

  // Habit Methods
  Future<List<Habit>> getHabits() async {
    try {
      if (userId == null) return [];
      
      final response = await client
          .from('habits')
          .select()
          .eq('user_id', userId!)
          .eq('is_archived', false)
          .order('position', ascending: true);
      
      return response.map<Habit>((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertHabit(Habit habit) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      final habitData = habit.toJson()..['user_id'] = userId!;
      await client.from('habits').insert(habitData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Habit> createHabit(Habit habit) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      final habitData = habit.toJson()..['user_id'] = userId!;
      final response = await client
          .from('habits')
          .insert(habitData)
          .select()
          .single();
      
      return Habit.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await client
          .from('habits')
          .update(habit.toJson())
          .eq('id', habit.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await client.from('habits').delete().eq('id', habitId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await client
          .from('habits')
          .update({'is_archived': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', habitId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> restoreHabit(String habitId) async {
    try {
      await client
          .from('habits')
          .update({'is_archived': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', habitId);
    } catch (e) {
      rethrow;
    }
  }

  // Habit Entry Methods
  Future<List<HabitEntry>> getHabitEntries({
    String? habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId == null) return [];
      
      var query = client
          .from('habit_entries')
          .select('*, habits!inner(user_id)')
          .eq('habits.user_id', userId!);
      
      if (habitId != null) {
        query = query.eq('habit_id', habitId);
      }
      
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }
      
      final response = await query.order('date', ascending: false);
      
      return response.map<HabitEntry>((json) => HabitEntry.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitEntry?> getHabitEntry(String habitId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('habit_entries')
          .select()
          .eq('habit_id', habitId)
          .eq('date', dateStr)
          .maybeSingle();
      
      return response != null ? HabitEntry.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HabitEntry>> getEntriesForDate(DateTime date) async {
    try {
      if (userId == null) return [];
      
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('habit_entries')
          .select('*, habits!inner(user_id)')
          .eq('habits.user_id', userId!)
          .eq('date', dateStr);
      
      return response.map<HabitEntry>((json) => HabitEntry.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> upsertEntry(HabitEntry entry) async {
    try {
      await client
          .from('habit_entries')
          .upsert(entry.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> batchUpdateHabits(List<Habit> habits) async {
    try {
      final updates = habits.map((habit) => habit.toJson()).toList();
      await client.from('habits').upsert(updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitEntry> createOrUpdateHabitEntry(HabitEntry entry) async {
    try {
      final dateStr = entry.date.toIso8601String().split('T')[0];
      final existingEntry = await getHabitEntry(entry.habitId, entry.date);
      
      if (existingEntry != null) {
        final updatedEntry = entry.copyWith(id: existingEntry.id);
        await client
            .from('habit_entries')
            .update(updatedEntry.toJson())
            .eq('id', existingEntry.id);
        return updatedEntry;
      } else {
        final response = await client
            .from('habit_entries')
            .insert(entry.toJson())
            .select()
            .single();
        return HabitEntry.fromJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabitEntry(String entryId) async {
    try {
      await client.from('habit_entries').delete().eq('id', entryId);
    } catch (e) {
      rethrow;
    }
  }

  // Streak Methods
  Future<List<Streak>> getStreaks([String? habitId]) async {
    try {
      if (userId == null) return [];
      
      var query = client
          .from('streaks')
          .select('*, habits!inner(user_id)')
          .eq('habits.user_id', userId!);
      
      if (habitId != null) {
        query = query.eq('habit_id', habitId);
      }
      
      final response = await query;
      
      return response.map<Streak>((json) => Streak.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Streak?> getStreak(String habitId) async {
    try {
      final response = await client
          .from('streaks')
          .select()
          .eq('habit_id', habitId)
          .maybeSingle();
      
      return response != null ? Streak.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrUpdateStreak(Streak streak) async {
    try {
      final existingStreak = await getStreak(streak.habitId);
      
      if (existingStreak != null) {
        await client
            .from('streaks')
            .update(streak.toJson())
            .eq('habit_id', streak.habitId);
      } else {
        await client.from('streaks').insert(streak.toJson());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId == null) return {};
      
      // Get completion stats
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 30));
      final end = endDate ?? now;
      
      final entries = await getHabitEntries(
        startDate: start,
        endDate: end,
      );
      
      final habits = await getHabits();
      final streaks = await getStreaks();
      
      // Calculate stats
      final totalHabits = habits.length;
      final completedEntries = entries.where((e) => e.completed).length;
      final totalEntries = entries.length;
      final completionRate = totalEntries > 0 ? completedEntries / totalEntries : 0.0;
      
      final activeStreaks = streaks.where((s) => s.currentStreak > 0).length;
      final longestStreak = streaks.isNotEmpty 
          ? streaks.map((s) => s.longestStreak).reduce((a, b) => a > b ? a : b)
          : 0;
      
      // Perfect days (all habits completed)
      final perfectDays = _calculatePerfectDays(entries, habits, start, end);
      
      return {
        'total_habits': totalHabits,
        'completion_rate': completionRate,
        'active_streaks': activeStreaks,
        'longest_streak': longestStreak,
        'perfect_days': perfectDays,
        'total_completed': completedEntries,
        'total_scheduled': totalEntries,
      };
    } catch (e) {
      rethrow;
    }
  }

  int _calculatePerfectDays(
    List<HabitEntry> entries,
    List<Habit> habits,
    DateTime start,
    DateTime end,
  ) {
    int perfectDays = 0;
    final current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final activeHabits = habits.where((habit) {
        return habit.frequencyDays.isEmpty || 
               habit.frequencyDays.contains(current.weekday);
      }).toList();
      
      if (activeHabits.isNotEmpty) {
        final dayEntries = entries.where((entry) {
          return entry.date.year == current.year &&
                 entry.date.month == current.month &&
                 entry.date.day == current.day &&
                 entry.completed;
        }).toList();
        
        final completedHabitIds = dayEntries.map((e) => e.habitId).toSet();
        final activeHabitIds = activeHabits.map((h) => h.id).toSet();
        
        if (activeHabitIds.every((id) => completedHabitIds.contains(id))) {
          perfectDays++;
        }
      }
      
      current.add(const Duration(days: 1));
    }
    
    return perfectDays;
  }

  // Utility Methods
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<bool> isConnected() async {
    try {
      await client.from('habits').select('count').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}