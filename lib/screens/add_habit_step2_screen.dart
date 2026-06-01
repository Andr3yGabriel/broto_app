import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../data/habit.dart';
import '../providers/habit_form_provider.dart';
import '../providers/habits_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/habit_row_tile.dart';

class AddHabitStep2Screen extends ConsumerStatefulWidget {
  const AddHabitStep2Screen({super.key});

  @override
  ConsumerState<AddHabitStep2Screen> createState() =>
      _AddHabitStep2ScreenState();
}

class _AddHabitStep2ScreenState extends ConsumerState<AddHabitStep2Screen> {
  bool _lembreteAtivo = false;
  TimeOfDay _horario = const TimeOfDay(hour: 8, minute: 0);
  final Set<int> _diasSelecionados = {};

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horario,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _horario = picked);
  }

  Future<void> _salvar() async {
    final form = ref.read(habitFormProvider);
    final habit = Habit()
      ..id = DateTime.now().millisecondsSinceEpoch
      ..name = form.name
      ..icon = form.icon
      ..color = form.color
      ..frequency = form.frequency
      ..reminderTime = _lembreteAtivo ? _formatTime(_horario) : null
      ..reminderDays = _lembreteAtivo ? _diasSelecionados.toList() : []
      ..createdAt = DateTime.now();

    await ref.read(habitsProvider.notifier).addHabit(habit);
    ref.read(habitFormProvider.notifier).reset();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(habitFormProvider);
    final isWeekly = form.frequency == 'weekly';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.text,
        title: const Text('novo hábito'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _progressBar(),
        ),
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
                      habitIcons[form.icon] ?? Icons.check_circle_outline,
                      color: Color(
                          int.parse(form.color.replaceFirst('#', '0xFF'))),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      form.name,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('ativar lembrete',
                    style: TextStyle(color: AppColors.text)),
                value: _lembreteAtivo,
                onChanged: (v) => setState(() => _lembreteAtivo = v),
              ),
              if (_lembreteAtivo) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('horário',
                        style: TextStyle(color: AppColors.soft)),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickTime,
                      child: Text(
                        _formatTime(_horario),
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('dias da semana',
                    style: TextStyle(color: AppColors.soft, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final entry in const {
                      1: 'S',
                      2: 'T',
                      3: 'Q',
                      4: 'Q',
                      5: 'S',
                      6: 'S',
                      7: 'D',
                    }.entries)
                      _DayButton(
                        label: entry.value,
                        dia: entry.key,
                        selecionado: _diasSelecionados.contains(entry.key),
                        habilitado: isWeekly,
                        onTap: isWeekly
                            ? () => setState(() {
                                  _diasSelecionados.contains(entry.key)
                                      ? _diasSelecionados.remove(entry.key)
                                      : _diasSelecionados.add(entry.key);
                                })
                            : null,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              AppButton('salvar hábito', onPressed: _salvar),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: List.generate(2, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  final String label;
  final int dia;
  final bool selecionado;
  final bool habilitado;
  final VoidCallback? onTap;

  const _DayButton({
    required this.label,
    required this.dia,
    required this.selecionado,
    required this.habilitado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: habilitado ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selecionado ? AppColors.accent : AppColors.surface,
          border: Border.all(
            color: habilitado ? AppColors.muted : AppColors.surface,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: !habilitado
                  ? AppColors.muted
                  : selecionado
                      ? Colors.white
                      : AppColors.soft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
