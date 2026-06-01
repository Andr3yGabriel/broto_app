import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../services/streak_service.dart';
import '../widgets/heatmap_grid.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(logsProvider);

    int streakAtual = 0;
    int melhorStreak = 0;
    double taxaMedia = 0;

    if (habits.isNotEmpty) {
      for (final h in habits) {
        final s = StreakService.currentStreak(h.id, logs);
        final b = StreakService.bestStreak(h.id, logs);
        final t = StreakService.completionRate(h.id, h.createdAt, logs);
        if (s > streakAtual) streakAtual = s;
        if (b > melhorStreak) melhorStreak = b;
        taxaMedia += t;
      }
      taxaMedia = taxaMedia / habits.length;
    }

    final weeklyRates = StreakService.weeklyCompletionRates(habits, logs);
    final heatmap = StreakService.heatmapData(habits, logs);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diasLabels = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      return nomes[d.weekday - 1];
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'estatísticas',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                      label: 'sequência atual', value: '$streakAtual dias'),
                  _StatCard(
                      label: 'taxa do mês',
                      value: '${(taxaMedia * 100).round()}%'),
                  _StatCard(label: 'hábitos ativos', value: '${habits.length}'),
                  _StatCard(
                      label: 'melhor sequência', value: '$melhorStreak dias'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'últimos 7 dias',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(7, (i) {
                      final rate = weeklyRates[i];
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: rate,
                            color: rate >= 0.75
                                ? AppColors.accent
                                : AppColors.muted,
                            width: 28,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Text(
                            diasLabels[v.toInt()],
                            style: const TextStyle(
                                color: AppColors.soft, fontSize: 11),
                          ),
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    maxY: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'últimas 5 semanas',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              HeatmapGrid(data: heatmap),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.lighter,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.soft, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
