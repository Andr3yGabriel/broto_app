import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/habit_log.dart';
import '../data/hive_boxes.dart';

class LogsNotifier extends StateNotifier<List<HabitLog>> {
  LogsNotifier() : super([]) {
    _loadLogs();
  }

  Box<HabitLog> get _box => Hive.box<HabitLog>(HiveBoxes.logs);

  void _loadLogs() {
    state = _box.values.toList();
  }

  Future<void> toggleLog(int habitId, DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    final existing = state.firstWhere(
      (l) =>
          l.habitId == habitId &&
          DateTime(l.date.year, l.date.month, l.date.day) == d,
      orElse: () => HabitLog()
        ..habitId = -1
        ..date = d
        ..completed = false,
    );

    if (existing.habitId != -1 && existing.completed) {
      await existing.delete();
    } else if (existing.habitId != -1 && !existing.completed) {
      existing.completed = true;
      await existing.save();
    } else {
      final log = HabitLog()
        ..habitId = habitId
        ..date = d
        ..completed = true;
      await _box.add(log);
    }
    state = _box.values.toList();
  }

  List<HabitLog> getLogsForHabit(int habitId) {
    return state.where((l) => l.habitId == habitId).toList();
  }

  List<HabitLog> getLogsForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return state.where((l) {
      return DateTime(l.date.year, l.date.month, l.date.day) == d;
    }).toList();
  }

  Future<void> deleteLogsForHabit(int habitId) async {
    final toDelete = state.where((l) => l.habitId == habitId).toList();
    for (final log in toDelete) {
      await log.delete();
    }
    state = _box.values.toList();
  }
}

final logsProvider = StateNotifierProvider<LogsNotifier, List<HabitLog>>(
    (ref) => LogsNotifier());
