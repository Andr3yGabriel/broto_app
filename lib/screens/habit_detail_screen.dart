import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme.dart';
import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../services/streak_service.dart';
import '../widgets/habit_row_tile.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.habitId) ?? 0;
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(logsProvider);

    final habit = habits.cast<dynamic>().firstWhere(
          (h) => h.id == id,
          orElse: () => null,
        );

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.deep,
          foregroundColor: AppColors.text,
        ),
        body: const Center(
          child: Text('hábito não encontrado',
              style: TextStyle(color: AppColors.soft)),
        ),
      );
    }

    final streak = StreakService.currentStreak(id, logs);
    final melhor = StreakService.bestStreak(id, logs);
    final taxa =
        StreakService.completionRate(id, habit.createdAt as DateTime, logs);
    final calendario = StreakService.calendarData(id, logs);

    final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.text,
        title: Text(habit.name as String),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/habit/$id/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      habitIcons[habit.icon] ?? Icons.check_circle_outline,
                      color: habitColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name as String,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (habit.reminderTime != null)
                            Text(
                              '🔔 ${habit.reminderTime}',
                              style: const TextStyle(
                                  color: AppColors.soft, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(label: 'sequência atual', value: '$streak'),
                  const SizedBox(width: 8),
                  _StatCard(label: 'melhor sequência', value: '$melhor'),
                  const SizedBox(width: 8),
                  _StatCard(
                      label: 'taxa do mês', value: '${(taxa * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: habit.createdAt as DateTime,
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = focused),
                eventLoader: (day) {
                  final d = DateTime(day.year, day.month, day.day);
                  return calendario[d] == true ? [true] : [];
                },
                selectedDayPredicate: (day) {
                  final now = DateTime.now();
                  return day.year == now.year &&
                      day.month == now.month &&
                      day.day == now.day;
                },
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: AppColors.text),
                  weekendTextStyle: TextStyle(color: AppColors.soft),
                  outsideTextStyle: TextStyle(color: AppColors.muted),
                  todayDecoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: AppColors.text),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AppColors.soft),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: AppColors.soft),
                  formatButtonVisible: false,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.soft),
                  weekendStyle: TextStyle(color: AppColors.soft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.lighter,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.soft, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
