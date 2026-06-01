import '../data/habit.dart';
import '../data/habit_log.dart';

class StreakService {
  static int currentStreak(int habitId, List<HabitLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completed = logs
        .where((l) => l.habitId == habitId && l.completed)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet();

    DateTime cursor = completed.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    int streak = 0;
    while (completed.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int bestStreak(int habitId, List<HabitLog> logs) {
    final dates = logs
        .where((l) => l.habitId == habitId && l.completed)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toList()
      ..sort();

    if (dates.isEmpty) return 0;

    int best = 1;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
  }

  static double completionRate(
      int habitId, DateTime createdAt, List<HabitLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final start = createdAt.isAfter(monthStart)
        ? DateTime(createdAt.year, createdAt.month, createdAt.day)
        : monthStart;

    final diasEsperados = today.difference(start).inDays + 1;
    if (diasEsperados <= 0) return 0;

    final diasCompletos = logs.where((l) {
      final d = DateTime(l.date.year, l.date.month, l.date.day);
      return l.habitId == habitId &&
          l.completed &&
          !d.isBefore(start) &&
          !d.isAfter(today);
    }).length;

    return diasCompletos / diasEsperados;
  }

  static Map<DateTime, bool> calendarData(int habitId, List<HabitLog> logs) {
    final result = <DateTime, bool>{};
    for (final log in logs) {
      if (log.habitId == habitId && log.completed) {
        final d = DateTime(log.date.year, log.date.month, log.date.day);
        result[d] = true;
      }
    }
    return result;
  }

  static List<double> weeklyCompletionRates(
      List<Habit> habits, List<HabitLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      if (habits.isEmpty) return 0.0;

      final completedCount = habits.where((h) {
        return logs.any((l) {
          final d = DateTime(l.date.year, l.date.month, l.date.day);
          return l.habitId == h.id && l.completed && d == day;
        });
      }).length;

      return completedCount / habits.length;
    });
  }

  static Map<DateTime, int> heatmapData(
      List<Habit> habits, List<HabitLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime, int>{};

    for (int i = 34; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      if (habits.isEmpty) {
        result[day] = 0;
        continue;
      }

      final completedCount = habits.where((h) {
        return logs.any((l) {
          final d = DateTime(l.date.year, l.date.month, l.date.day);
          return l.habitId == h.id && l.completed && d == day;
        });
      }).length;

      final ratio = completedCount / habits.length;
      int intensity;
      if (ratio == 0) {
        intensity = 0;
      } else if (ratio <= 0.25) {
        intensity = 1;
      } else if (ratio <= 0.5) {
        intensity = 2;
      } else if (ratio <= 0.75) {
        intensity = 3;
      } else {
        intensity = 4;
      }
      result[day] = intensity;
    }
    return result;
  }
}
