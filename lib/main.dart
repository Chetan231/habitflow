import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import 'app.dart';
import 'core/constants/strings.dart';
import 'features/habits/domain/models/habit.dart';
import 'features/habits/domain/models/habit_entry.dart';
import 'features/habits/domain/models/streak.dart';
import 'local/hive_boxes.dart';

/// Set to true to run without Supabase (demo/offline mode)
const bool kMockMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HabitAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitEntryAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(StreakAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(HabitTypeAdapter());
  
  // Open boxes
  await HiveBoxes.init();
  
  // Initialize Supabase only if not in mock mode
  if (!kMockMode && AppStrings.supabaseUrl != 'YOUR_SUPABASE_URL') {
    await Supabase.initialize(
      url: AppStrings.supabaseUrl,
      anonKey: AppStrings.supabaseAnonKey,
      debug: false,
    );
  }
  
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
