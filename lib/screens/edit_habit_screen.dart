import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/habits_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/habit_row_tile.dart';

const _cores = [
  '#7F77DD',
  '#1D9E75',
  '#D85A30',
  '#D4537E',
  '#BA7517',
  '#378ADD',
];

class EditHabitScreen extends ConsumerStatefulWidget {
  final String habitId;
  const EditHabitScreen({super.key, required this.habitId});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _nameController = TextEditingController();
  String? _icone;
  String _cor = _cores.first;
  String _frequencia = 'daily';
  bool _lembreteAtivo = false;
  TimeOfDay _horario = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _diasSelecionados = {};
  bool _inicializado = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

  Future<void> _salvar(int id) async {
    if (_nameController.text.trim().isEmpty || _icone == null) return;

    final habits = ref.read(habitsProvider);
    final habit = habits.firstWhere((h) => h.id == id);
    habit.name = _nameController.text.trim();
    habit.icon = _icone!;
    habit.color = _cor;
    habit.frequency = _frequencia;
    habit.reminderTime = _lembreteAtivo ? _formatTime(_horario) : null;
    habit.reminderDays = _lembreteAtivo ? _diasSelecionados.toList() : [];

    await ref.read(habitsProvider.notifier).updateHabit(habit);
    if (mounted) context.pop();
  }

  Future<void> _excluir(int id) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'excluir hábito',
      message:
          'todos os registros deste hábito serão apagados. essa ação não pode ser desfeita.',
      confirmLabel: 'excluir',
      destructive: true,
    );
    if (confirmar && mounted) {
      await ref.read(habitsProvider.notifier).deleteHabit(id);
      if (mounted) context.go('/home');
    }
  }

  Color _parseColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.habitId) ?? 0;
    final habits = ref.watch(habitsProvider);
    final habit = habits.cast<dynamic>().firstWhere(
          (h) => h.id == id,
          orElse: () => null,
        );

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.deep, foregroundColor: AppColors.text),
        body: const Center(
          child: Text('hábito não encontrado',
              style: TextStyle(color: AppColors.soft)),
        ),
      );
    }

    if (!_inicializado) {
      _nameController.text = habit.name as String;
      _icone = habit.icon as String;
      _cor = habit.color as String;
      _frequencia = habit.frequency as String;
      _lembreteAtivo = (habit.reminderTime as String?) != null;
      if (_lembreteAtivo) {
        final parts = (habit.reminderTime as String).split(':');
        _horario =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      _diasSelecionados = (habit.reminderDays as List<int>).toSet();
      _inicializado = true;
    }

    final isWeekly = _frequencia == 'weekly';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.text,
        title: const Text('editar hábito'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'nome do hábito',
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              const Text('ícone',
                  style: TextStyle(
                      color: AppColors.soft,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: habitIcons.entries.map((e) {
                  final sel = _icone == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _icone = e.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.muted,
                        ),
                      ),
                      child: Icon(e.value,
                          color: sel ? Colors.white : AppColors.soft, size: 28),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('cor',
                  style: TextStyle(
                      color: AppColors.soft,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: _cores.map((hex) {
                  final sel = _cor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _cor = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _parseColor(hex),
                        shape: BoxShape.circle,
                        border: sel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('frequência',
                  style: TextStyle(
                      color: AppColors.soft,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FreqBtn(
                    label: 'Diário',
                    value: 'daily',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                  const SizedBox(width: 8),
                  _FreqBtn(
                    label: 'Semanal',
                    value: 'weekly',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                  const SizedBox(width: 8),
                  _FreqBtn(
                    label: 'Dias úteis',
                    value: 'weekdays',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                ],
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
                const SizedBox(height: 8),
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
                      _DayBtn(
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
              AppButton('salvar alterações', onPressed: () => _salvar(id)),
              const SizedBox(height: 12),
              AppButton(
                'excluir hábito',
                destructive: true,
                onPressed: () => _excluir(id),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreqBtn extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _FreqBtn(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ativo = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: ativo ? AppColors.accent : AppColors.muted),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ativo ? Colors.white : AppColors.soft,
              fontSize: 13,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayBtn extends StatelessWidget {
  final String label;
  final int dia;
  final bool selecionado, habilitado;
  final VoidCallback? onTap;
  const _DayBtn(
      {required this.label,
      required this.dia,
      required this.selecionado,
      required this.habilitado,
      this.onTap});

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
              color: habilitado ? AppColors.muted : AppColors.surface),
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
