import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/habit.dart';
import '../data/hive_boxes.dart';
import '../services/notification_service.dart';
import 'logs_provider.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier(this._ref) : super([]) {
    _loadHabits();
  }

  final Ref _ref;

  Box<Habit> get _box => Hive.box<Habit>(HiveBoxes.habits);

  void _loadHabits() {
    state = _box.values.toList();
  }

  Future<void> addHabit(Habit habit) async {
    await _box.add(habit);
    await NotificationService.scheduleReminder(habit);
    state = _box.values.toList();
  }

  Future<void> updateHabit(Habit habit) async {
    await NotificationService.cancelReminder(habit.id);
    await habit.save();
    await NotificationService.scheduleReminder(habit);
    state = _box.values.toList();
  }

  Future<void> deleteHabit(int id) async {
    final habit = state.firstWhere((h) => h.id == id);
    await NotificationService.cancelReminder(id);
    await _ref.read(logsProvider.notifier).deleteLogsForHabit(id);
    await habit.delete();
    state = _box.values.toList();
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>(
  (ref) => HabitsNotifier(ref),
);
