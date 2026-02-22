import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/strings.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/habit_entry.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._();
  
  AIService._();

  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppStrings.openAiApiKey}',
  };

  Future<String> getDailyMotivation({
    required List<Habit> habits,
    required List<HabitEntry> todayEntries,
    required Map<String, int> streaks,
  }) async {
    try {
      final completedCount = todayEntries.where((e) => e.completed).length;
      final totalCount = habits.where((h) => _isHabitActiveToday(h)).length;
      final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;
      
      final prompt = _buildMotivationPrompt(
        habits: habits,
        completedCount: completedCount,
        totalCount: totalCount,
        completionRate: completionRate,
        streaks: streaks,
      );

      final response = await _makeOpenAIRequest(prompt, maxTokens: 150);
      return response.trim();
    } catch (e) {
      return _getFallbackMotivation();
    }
  }

  Future<Map<String, dynamic>> getWeeklySummary({
    required List<Habit> habits,
    required List<HabitEntry> weekEntries,
    required Map<String, int> streaks,
  }) async {
    try {
      final analytics = _calculateWeeklyAnalytics(habits, weekEntries);
      
      final prompt = _buildSummaryPrompt(
        habits: habits,
        analytics: analytics,
        streaks: streaks,
      );

      final response = await _makeOpenAIRequest(prompt, maxTokens: 300);
      
      return {
        'summary': response.trim(),
        'score': analytics['weeklyScore'],
        'bestHabit': analytics['bestHabit'],
        'improvementArea': analytics['improvementArea'],
        'tip': _generateTip(analytics),
      };
    } catch (e) {
      return _getFallbackSummary();
    }
  }

  Future<List<String>> getHabitSuggestions({
    required List<Habit> currentHabits,
    required List<HabitEntry> recentEntries,
  }) async {
    try {
      final prompt = _buildSuggestionsPrompt(currentHabits, recentEntries);
      final response = await _makeOpenAIRequest(prompt, maxTokens: 200);
      
      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[\d\-\*\•]\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      return _getFallbackSuggestions();
    }
  }

  Future<List<String>> detectPatterns({
    required List<Habit> habits,
    required List<HabitEntry> entries,
  }) async {
    try {
      final prompt = _buildPatternsPrompt(habits, entries);
      final response = await _makeOpenAIRequest(prompt, maxTokens: 250);
      
      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[\d\-\*\•]\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .take(3)
          .toList();
    } catch (e) {
      return _getFallbackPatterns();
    }
  }

  Future<String> getHabitInsight(
    Habit habit,
    List<HabitEntry> entries,
    int currentStreak,
  ) async {
    try {
      final prompt = _buildInsightPrompt(habit, entries, currentStreak);
      final response = await _makeOpenAIRequest(prompt, maxTokens: 100);
      return response.trim();
    } catch (e) {
      return _getFallbackInsight(habit.name);
    }
  }

  Future<String> _makeOpenAIRequest(String prompt, {int maxTokens = 150}) async {
    final body = json.encode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content': 'You are an encouraging habit coach. Be positive, concise, and motivating. Use emojis sparingly and appropriately.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': maxTokens,
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  String _buildMotivationPrompt({
    required List<Habit> habits,
    required int completedCount,
    required int totalCount,
    required double completionRate,
    required Map<String, int> streaks,
  }) {
    final time = DateTime.now().hour;
    final timeOfDay = time < 12 ? 'morning' : time < 17 ? 'afternoon' : 'evening';
    
    final bestStreak = streaks.values.isEmpty ? 0 : streaks.values.reduce((a, b) => a > b ? a : b);
    
    return '''
It's $timeOfDay. The user has completed $completedCount out of $totalCount habits today (${(completionRate * 100).toInt()}% completion rate).

Their habits: ${habits.map((h) => h.name).join(', ')}
Best current streak: $bestStreak days

Give a personalized, encouraging daily motivation message. Keep it under 2 sentences and focus on their progress or potential.
''';
  }

  String _buildSummaryPrompt({
    required List<Habit> habits,
    required Map<String, dynamic> analytics,
    required Map<String, int> streaks,
  }) {
    return '''
Weekly habit summary for user with habits: ${habits.map((h) => h.name).join(', ')}

This week's performance:
- Weekly completion rate: ${(analytics['completionRate'] * 100).toInt()}%
- Best performing habit: ${analytics['bestHabit']}
- Most missed habit: ${analytics['worstHabit']}
- Total completions: ${analytics['totalCompletions']}
- Active streaks: ${streaks.values.where((s) => s > 0).length}

Provide an encouraging weekly summary in 2-3 sentences, highlighting their progress and one specific area for improvement.
''';
  }

  String _buildSuggestionsPrompt(List<Habit> currentHabits, List<HabitEntry> recentEntries) {
    final habitNames = currentHabits.map((h) => h.name).join(', ');
    final completionRate = recentEntries.isNotEmpty 
        ? recentEntries.where((e) => e.completed).length / recentEntries.length
        : 0.0;

    return '''
User's current habits: $habitNames
Recent completion rate: ${(completionRate * 100).toInt()}%

Suggest 3-5 new habit ideas that would complement their existing habits. Focus on:
- Health and wellness
- Productivity 
- Personal growth
- Balance areas they might be missing

Format as a simple list, one habit per line.
''';
  }

  String _buildPatternsPrompt(List<Habit> habits, List<HabitEntry> entries) {
    final weekdayCompletions = <int, int>{};
    final hourCompletions = <int, int>{};
    
    for (final entry in entries.where((e) => e.completed)) {
      final weekday = entry.date.weekday;
      final hour = entry.completedAt?.hour ?? 12;
      
      weekdayCompletions[weekday] = (weekdayCompletions[weekday] ?? 0) + 1;
      hourCompletions[hour] = (hourCompletions[hour] ?? 0) + 1;
    }

    return '''
Analyze these habit completion patterns:
- Habits: ${habits.map((h) => h.name).join(', ')}
- Weekday completions: $weekdayCompletions
- Hour completions: $hourCompletions
- Total entries analyzed: ${entries.length}

Identify 2-3 interesting patterns or insights about their habit completion behavior. Be specific and actionable.
Format as a list, one insight per line.
''';
  }

  String _buildInsightPrompt(Habit habit, List<HabitEntry> entries, int currentStreak) {
    final completedEntries = entries.where((e) => e.completed).toList();
    final completionRate = entries.isNotEmpty ? completedEntries.length / entries.length : 0.0;
    
    return '''
Habit: ${habit.name}
Type: ${habit.habitType.name}
Current streak: $currentStreak days
Completion rate: ${(completionRate * 100).toInt()}%
Recent entries: ${entries.length}

Provide a brief, encouraging insight about their progress with this specific habit. Include one actionable tip.
''';
  }

  Map<String, dynamic> _calculateWeeklyAnalytics(List<Habit> habits, List<HabitEntry> entries) {
    final habitCompletions = <String, int>{};
    final habitTotals = <String, int>{};
    
    for (final habit in habits) {
      habitCompletions[habit.name] = 0;
      habitTotals[habit.name] = 0;
    }
    
    for (final entry in entries) {
      final habitName = habits.firstWhere((h) => h.id == entry.habitId, orElse: () => Habit.empty()).name;
      if (habitName.isNotEmpty) {
        habitTotals[habitName] = (habitTotals[habitName] ?? 0) + 1;
        if (entry.completed) {
          habitCompletions[habitName] = (habitCompletions[habitName] ?? 0) + 1;
        }
      }
    }
    
    String bestHabit = '';
    String worstHabit = '';
    double bestRate = 0.0;
    double worstRate = 1.0;
    
    for (final habit in habitCompletions.keys) {
      final total = habitTotals[habit] ?? 1;
      final rate = (habitCompletions[habit] ?? 0) / total;
      
      if (rate > bestRate) {
        bestRate = rate;
        bestHabit = habit;
      }
      
      if (rate < worstRate && total > 0) {
        worstRate = rate;
        worstHabit = habit;
      }
    }
    
    final totalCompletions = habitCompletions.values.fold(0, (a, b) => a + b);
    final totalScheduled = habitTotals.values.fold(0, (a, b) => a + b);
    final overallRate = totalScheduled > 0 ? totalCompletions / totalScheduled : 0.0;
    
    return {
      'completionRate': overallRate,
      'bestHabit': bestHabit.isNotEmpty ? bestHabit : 'None',
      'worstHabit': worstHabit.isNotEmpty ? worstHabit : 'None',
      'improvementArea': worstHabit.isNotEmpty ? worstHabit : 'Consistency',
      'totalCompletions': totalCompletions,
      'weeklyScore': (overallRate * 100).round(),
    };
  }

  String _generateTip(Map<String, dynamic> analytics) {
    final tips = [
      'Try setting a specific time for ${analytics['improvementArea']} to build consistency.',
      'Stack ${analytics['improvementArea']} with an existing strong habit.',
      'Start with just 2 minutes of ${analytics['improvementArea']} to build the routine.',
      'Use visual cues to remind yourself about ${analytics['improvementArea']}.',
      'Celebrate small wins with ${analytics['improvementArea']} to build momentum.',
    ];
    
    return tips[DateTime.now().day % tips.length];
  }

  bool _isHabitActiveToday(Habit habit) {
    if (habit.frequencyDays.isEmpty) return true;
    return habit.frequencyDays.contains(DateTime.now().weekday);
  }

  // Fallback methods for when AI service is unavailable
  String _getFallbackMotivation() {
    final motivations = [
      'Every small step counts! Keep building your habits today. 💪',
      'You\'re creating positive change one day at a time! 🌟',
      'Progress over perfection - you\'ve got this! ⭐',
      'Your future self will thank you for today\'s efforts! 🚀',
      'Consistency is the key to lasting change! 🔑',
    ];
    
    return motivations[DateTime.now().day % motivations.length];
  }

  Map<String, dynamic> _getFallbackSummary() {
    return {
      'summary': 'You\'re making great progress! Keep up the consistent effort with your habits.',
      'score': 75,
      'bestHabit': 'Keep going!',
      'improvementArea': 'Consistency',
      'tip': 'Try to complete your habits at the same time each day.',
    };
  }

  List<String> _getFallbackSuggestions() {
    return [
      'Drink a glass of water first thing in the morning',
      'Take a 10-minute walk after lunch',
      'Read for 15 minutes before bed',
      'Practice gratitude by writing 3 things you\'re thankful for',
      'Do 5 minutes of deep breathing or meditation',
    ];
  }

  List<String> _getFallbackPatterns() {
    return [
      'Try to maintain consistency across all weekdays',
      'Consider setting specific times for your habits',
      'You tend to do better when you start early in the day',
    ];
  }

  String _getFallbackInsight(String habitName) {
    return 'You\'re building a great foundation with $habitName. Small, consistent actions lead to big results!';
  }
}