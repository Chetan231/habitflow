import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/constants/strings.dart';
import 'core/services/notification_service.dart';
import 'features/habits/domain/models/habit.dart';
import 'features/habits/domain/models/habit_entry.dart';
import 'features/habits/domain/models/streak.dart';
import 'local/hive_boxes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await _initializeHive();
  
  // Initialize Supabase
  await _initializeSupabase();
  
  // Initialize Notifications
  await _initializeNotifications();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const ProviderScope(child: HabitFlowApp()));
}

Future<void> _initializeHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Register adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitEntryAdapter());
  Hive.registerAdapter(StreakAdapter());
  Hive.registerAdapter(HabitTypeAdapter());
  
  // Open boxes
  await HiveBoxes.init();
}

Future<void> _initializeSupabase() async {
  await Supabase.initialize(
    url: AppStrings.supabaseUrl,
    anonKey: AppStrings.supabaseAnonKey,
    debug: false,
  );
}

Future<void> _initializeNotifications() async {
  await NotificationService.instance.initialize();
}