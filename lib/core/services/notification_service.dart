import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../features/habits/domain/models/habit.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? granted = await androidImplementation?.requestPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    await cancelHabitReminder(habit.id);

    final reminderTime = habit.reminderTime!;
    final now = DateTime.now();
    
    // Schedule for each day in frequency
    final daysToSchedule = habit.frequencyDays.isEmpty 
        ? [1, 2, 3, 4, 5, 6, 7] 
        : habit.frequencyDays;

    for (final weekday in daysToSchedule) {
      final scheduledDate = _getNextWeekday(weekday, reminderTime);
      
      if (scheduledDate.isAfter(now)) {
        final notificationId = _getNotificationId(habit.id, weekday);
        
        await _notifications.zonedSchedule(
          notificationId,
          'Time for ${habit.name}! 🌟',
          _getReminderMessage(habit),
          tz.TZDateTime.from(scheduledDate, tz.local),
          _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'habit_reminder:${habit.id}',
        );
      }
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    // Cancel notifications for all weekdays
    for (int weekday = 1; weekday <= 7; weekday++) {
      final notificationId = _getNotificationId(habitId, weekday);
      await _notifications.cancel(notificationId);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _getNotificationDetails(),
      payload: payload,
    );
  }

  Future<void> showHabitCompletedNotification(Habit habit, {int? streak}) async {
    String title = 'Great job! 🎉';
    String body = 'You completed ${habit.name}!';
    
    if (streak != null && streak > 1) {
      if (streak % 10 == 0) {
        title = 'Amazing streak! 🔥';
        body = '${streak} days in a row for ${habit.name}! Keep it up!';
      } else if (streak >= 7) {
        title = 'Week streak! 🔥';
        body = '${streak} days streak for ${habit.name}!';
      } else {
        body = '${streak} day streak for ${habit.name}!';
      }
    }

    await showInstantNotification(
      title: title,
      body: body,
      payload: 'habit_completed:${habit.id}',
    );
  }

  Future<void> showMissedHabitNotification(List<Habit> missedHabits) async {
    if (missedHabits.isEmpty) return;

    String title = 'Don\'t break the chain! ⚡';
    String body;
    
    if (missedHabits.length == 1) {
      body = 'You missed ${missedHabits.first.name} yesterday. Get back on track today!';
    } else {
      body = 'You missed ${missedHabits.length} habits yesterday. Today\'s a fresh start!';
    }

    await showInstantNotification(
      title: title,
      body: body,
      payload: 'missed_habits',
    );
  }

  Future<void> showMotivationalNotification() async {
    final messages = [
      'Your future self will thank you! 💪',
      'Small steps, big changes! 🌱',
      'You\'re building something amazing! ✨',
      'Consistency is key! 🔑',
      'Every day counts! 📅',
    ];
    
    final message = messages[DateTime.now().day % messages.length];
    
    await showInstantNotification(
      title: 'HabitFlow Motivation',
      body: message,
      payload: 'motivation',
    );
  }

  DateTime _getNextWeekday(int weekday, TimeOfDay time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate days until the target weekday
    int daysUntilWeekday = (weekday - now.weekday) % 7;
    if (daysUntilWeekday == 0) {
      // It's the same weekday, check if time has passed
      final todayAtTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (now.isAfter(todayAtTime)) {
        daysUntilWeekday = 7; // Schedule for next week
      }
    }
    
    final targetDate = today.add(Duration(days: daysUntilWeekday));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, time.hour, time.minute);
  }

  int _getNotificationId(String habitId, int weekday) {
    // Create a unique notification ID using habit ID hash and weekday
    return (habitId.hashCode % 1000000) * 10 + weekday;
  }

  String _getReminderMessage(Habit habit) {
    final messages = {
      HabitType.yesNo: [
        'Time to complete your habit!',
        'Your daily habit is waiting!',
        'Let\'s keep the momentum going!',
        'Ready to maintain your streak?',
      ],
      HabitType.count: [
        'Don\'t forget to track your progress!',
        'Time to add to your count!',
        'Keep building those numbers!',
        'Every count matters!',
      ],
      HabitType.timer: [
        'Time to invest in yourself!',
        'Your focused time starts now!',
        'Ready for some productive minutes?',
        'Let\'s make every minute count!',
      ],
    };

    final typeMessages = messages[habit.habitType] ?? messages[HabitType.yesNo]!;
    return typeMessages[DateTime.now().hour % typeMessages.length];
  }

  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications to remind you about your habits',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6C63FF),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
  }

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle notification tap on iOS < 10
  }

  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap
      // This would typically navigate to a specific screen based on payload
      debugPrint('Notification payload: $payload');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true;
  }
}