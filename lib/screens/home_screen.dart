import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../services/streak_service.dart';
import '../widgets/app_button.dart';
import '../widgets/habit_row_tile.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _HomeTab(),
    StatsScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _userName = p.getString('user_name') ?? '');
    });
  }

  String _saudacao() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  bool _habitoDeHoje(habit) {
    final weekday = DateTime.now().weekday;
    return switch (habit.frequency as String) {
      'daily' => true,
      'weekdays' => weekday <= 5,
      'weekly' => (habit.reminderDays as List<int>).contains(weekday),
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(logsProvider);
    final hoje = DateTime.now();
    final diaHoje = DateTime(hoje.year, hoje.month, hoje.day);

    final habitosHoje = habits.where(_habitoDeHoje).toList();
    final concluidosHoje = habitosHoje.where((h) {
      return logs.any((l) {
        final d = DateTime(l.date.year, l.date.month, l.date.day);
        return l.habitId == h.id && l.completed && d == diaHoje;
      });
    }).toList();

    final total = habitosHoje.length;
    final concluidos = concluidosHoje.length;
    final progresso = total > 0 ? concluidos / total : 0.0;

    int streakAtual = 0;
    int melhorStreak = 0;
    for (final h in habits) {
      final s = StreakService.currentStreak(h.id, logs);
      final b = StreakService.bestStreak(h.id, logs);
      if (s > streakAtual) streakAtual = s;
      if (b > melhorStreak) melhorStreak = b;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/habit/add/step1'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            ref.invalidate(habitsProvider);
            ref.invalidate(logsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      '${_saudacao()}${_userName.isNotEmpty ? ", $_userName" : ""}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$concluidos de $total feitos hoje',
                      style:
                          const TextStyle(color: AppColors.soft, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 8,
                        backgroundColor: AppColors.surface,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreakCard(
                        currentStreak: streakAtual, bestStreak: melhorStreak),
                    const SizedBox(height: 20),
                    if (total > 0 && concluidos == total)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🏆 dia perfeito!',
                              style: TextStyle(
                                color: AppColors.lighter,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (habitosHoje.isEmpty) ...[
                      const SizedBox(height: 40),
                      const Center(
                        child: Icon(Icons.eco_outlined,
                            color: AppColors.muted, size: 64),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'nenhum hábito ainda',
                          style: TextStyle(color: AppColors.soft, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        'criar primeiro hábito',
                        onPressed: () => context.push('/habit/add/step1'),
                      ),
                    ],
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final habit = habitosHoje[i];
                      final completo =
                          concluidosHoje.any((h) => h.id == habit.id);
                      return HabitRowTile(
                        habit: habit,
                        completed: completo,
                        onToggle: () => ref
                            .read(logsProvider.notifier)
                            .toggleLog(habit.id, diaHoje),
                        onTap: () => context.push('/habit/${habit.id}'),
                      );
                    },
                    childCount: habitosHoje.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
