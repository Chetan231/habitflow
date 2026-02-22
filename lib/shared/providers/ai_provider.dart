import 'package:flutter_riverpod/flutter_riverpod.dart';

// AI service provider for mock data
final aiProvider = Provider<AIService>((ref) {
  return AIService();
});

final dailyMotivationProvider = FutureProvider<String>((ref) async {
  final aiService = ref.read(aiProvider);
  return aiService.getDailyMotivation();
});

final weeklySummaryProvider = FutureProvider<WeeklySummary>((ref) async {
  final aiService = ref.read(aiProvider);
  return aiService.getWeeklySummary();
});

final aiSuggestionsProvider = FutureProvider<List<AISuggestion>>((ref) async {
  final aiService = ref.read(aiProvider);
  return aiService.getSuggestions();
});

class AIService {
  Future<String> getDailyMotivation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final motivations = [
      "🌟 Every small step forward is progress worth celebrating!",
      "💪 You're building the foundation for lasting change, one habit at a time.",
      "🚀 Today's consistency becomes tomorrow's breakthrough.",
      "✨ Your commitment today shapes your success tomorrow.",
      "🎯 Focus on progress, not perfection. You've got this!",
      "🌱 Growth happens in the daily grind. Keep nurturing your habits!",
      "🔥 Your dedication is inspiring! Let's make today count.",
    ];
    
    final index = DateTime.now().day % motivations.length;
    return motivations[index];
  }

  Future<WeeklySummary> getWeeklySummary() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return WeeklySummary(
      completionRate: 0.78,
      totalHabits: 4,
      bestDay: 'Tuesday',
      improvementArea: 'Weekend consistency could use some work',
      encouragement: "Great job maintaining your streak! Your Tuesday performance was exceptional.",
    );
  }

  Future<List<AISuggestion>> getSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      AISuggestion(
        id: '1',
        type: SuggestionType.improvement,
        title: 'Try Morning Meditation',
        description: 'Starting your day with 5 minutes of meditation could boost your overall habit consistency.',
        icon: '🧘‍♀️',
        priority: 1,
      ),
      AISuggestion(
        id: '2',
        type: SuggestionType.streak,
        title: 'Weekend Habit Planning',
        description: 'Your weekday consistency is great! Set reminders for weekend habits to maintain momentum.',
        icon: '📅',
        priority: 2,
      ),
      AISuggestion(
        id: '3',
        type: SuggestionType.motivation,
        title: 'Celebrate Small Wins',
        description: 'Acknowledge your 3-day streak! Small celebrations reinforce positive behavior.',
        icon: '🎉',
        priority: 3,
      ),
    ];
  }
}

class WeeklySummary {
  final double completionRate;
  final int totalHabits;
  final String bestDay;
  final String improvementArea;
  final String encouragement;

  const WeeklySummary({
    required this.completionRate,
    required this.totalHabits,
    required this.bestDay,
    required this.improvementArea,
    required this.encouragement,
  });
}

enum SuggestionType {
  improvement,
  streak,
  motivation,
  newHabit,
}

class AISuggestion {
  final String id;
  final SuggestionType type;
  final String title;
  final String description;
  final String icon;
  final int priority;

  const AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });
}