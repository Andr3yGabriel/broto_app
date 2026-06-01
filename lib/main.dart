import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/habit.dart';
import 'data/habit_log.dart';
import 'data/hive_boxes.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitLogAdapter());
  await Hive.openBox<Habit>(HiveBoxes.habits);
  await Hive.openBox<HabitLog>(HiveBoxes.logs);

  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  runApp(const ProviderScope(child: BrotoApp()));
}
