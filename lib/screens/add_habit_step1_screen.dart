import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/habit_form_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/habit_row_tile.dart';

const _cores = [
  '#7F77DD',
  '#1D9E75',
  '#D85A30',
  '#D4537E',
  '#BA7517',
  '#378ADD',
];

class AddHabitStep1Screen extends ConsumerStatefulWidget {
  const AddHabitStep1Screen({super.key});

  @override
  ConsumerState<AddHabitStep1Screen> createState() =>
      _AddHabitStep1ScreenState();
}

class _AddHabitStep1ScreenState extends ConsumerState<AddHabitStep1Screen> {
  final _nameController = TextEditingController();
  String? _icone;
  String _cor = _cores.first;
  String _frequencia = 'daily';
  String? _erro;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onProximo() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _erro = 'informe um nome para o hábito');
      return;
    }
    if (_icone == null) {
      setState(() => _erro = 'selecione um ícone');
      return;
    }
    ref.read(habitFormProvider.notifier).updateStep1(
          _nameController.text.trim(),
          _icone!,
          _cor,
          _frequencia,
        );
    context.push('/habit/add/step2');
  }

  Color _parseColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.text,
        title: const Text('novo hábito'),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(6),
          child: _ProgressBar(step: 1),
        ),
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
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(_erro!,
                    style: const TextStyle(
                        color: AppColors.redDark, fontSize: 13)),
              ],
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
                  final selecionado = _icone == e.key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _icone = e.key;
                      _erro = null;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            selecionado ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selecionado ? AppColors.accent : AppColors.muted,
                        ),
                      ),
                      child: Icon(
                        e.value,
                        color: selecionado ? Colors.white : AppColors.soft,
                        size: 28,
                      ),
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
                  final selecionado = _cor == hex;
                  final cor = _parseColor(hex);
                  return GestureDetector(
                    onTap: () => setState(() => _cor = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                        border: selecionado
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
                  _FreqButton(
                    label: 'Diário',
                    value: 'daily',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                  const SizedBox(width: 8),
                  _FreqButton(
                    label: 'Semanal',
                    value: 'weekly',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                  const SizedBox(width: 8),
                  _FreqButton(
                    label: 'Dias úteis',
                    value: 'weekdays',
                    selected: _frequencia,
                    onTap: (v) => setState(() => _frequencia = v),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton('próximo', onPressed: _onProximo),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreqButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _FreqButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

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
            border: Border.all(
              color: ativo ? AppColors.accent : AppColors.muted,
            ),
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

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: List.generate(2, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < step ? AppColors.accent : AppColors.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
