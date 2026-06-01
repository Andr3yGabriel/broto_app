import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/habit.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/habit_row_tile.dart';

const _mapeamento = {
  'Beber água': ('water', '#378ADD'),
  'Meditar': ('brain', '#7F77DD'),
  'Exercitar': ('run', '#1D9E75'),
  'Dormir cedo': ('moon', '#534AB7'),
  'Ler': ('book', '#BA7517'),
  'Estudar': ('pencil', '#7F77DD'),
  'Caminhar': ('run', '#1D9E75'),
  'Alongar': ('activity', '#D4537E'),
  'Respirar': ('heart', '#D85A30'),
};

class OnboardingStep4Screen extends ConsumerWidget {
  final Object? extra;
  const OnboardingStep4Screen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dados = extra as Map? ?? {};
    final habitos =
        (dados['habitos'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final horarios = (dados['horarios'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
        {};

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _progressBar(),
              const SizedBox(height: 24),
              const Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.check, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: SharedPreferences.getInstance()
                    .then((p) => p.getString('user_name') ?? ''),
                builder: (context, snap) {
                  final nome = snap.data ?? '';
                  return Text(
                    'tudo pronto${nome.isNotEmpty ? ", $nome" : ""}!',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: habitos.length,
                  itemBuilder: (context, i) {
                    final nome = habitos[i];
                    final map = _mapeamento[nome] ?? ('pencil', '#7F77DD');
                    final horario = horarios[nome] ?? '08:00';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(habitIcons[map.$1] ?? Icons.check,
                              color: Color(
                                  int.parse(map.$2.replaceFirst('#', '0xFF'))),
                              size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(nome,
                                style: const TextStyle(color: AppColors.text)),
                          ),
                          Text(
                            horario,
                            style: const TextStyle(
                                color: AppColors.soft, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              AppButton(
                'começar a brotar',
                onPressed: () => _salvar(context, ref, habitos, horarios),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvar(
    BuildContext context,
    WidgetRef ref,
    List<String> habitos,
    Map<String, String> horarios,
  ) async {
    for (final nome in habitos) {
      final map = _mapeamento[nome] ?? ('pencil', '#7F77DD');
      final habit = Habit()
        ..id = DateTime.now().millisecondsSinceEpoch + habitos.indexOf(nome)
        ..name = nome
        ..icon = map.$1
        ..color = map.$2
        ..frequency = 'daily'
        ..reminderTime = horarios[nome]
        ..reminderDays = []
        ..createdAt = DateTime.now();
      await ref.read(habitsProvider.notifier).addHabit(habit);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setString('member_since', DateTime.now().toIso8601String());

    if (context.mounted) context.go('/home');
  }

  Widget _progressBar() {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
