import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../data/habit.dart';
import '../data/habit_log.dart';
import '../data/hive_boxes.dart';
import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../services/notification_service.dart';
import '../widgets/confirm_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _nome = '';
  String _membroDesde = '';
  bool _notifReminders = true;
  bool _notifSummary = false;
  bool _notifStreak = false;
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _carregarPrefs();
  }

  Future<void> _carregarPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final since = DateTime.tryParse(prefs.getString('member_since') ?? '');
    setState(() {
      _nome = prefs.getString('user_name') ?? '';
      if (since != null) {
        const meses = [
          'janeiro',
          'fevereiro',
          'março',
          'abril',
          'maio',
          'junho',
          'julho',
          'agosto',
          'setembro',
          'outubro',
          'novembro',
          'dezembro',
        ];
        _membroDesde = '${meses[since.month - 1]} de ${since.year}';
      }
      _notifReminders = prefs.getBool('notif_reminders') ?? true;
      _notifSummary = prefs.getBool('notif_summary') ?? false;
      _notifStreak = prefs.getBool('notif_streak_alert') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? true;
    });
  }

  Future<void> _salvar(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _redefinir() async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'redefinir dados',
      message: 'todos os hábitos e registros serão apagados permanentemente.',
      confirmLabel: 'redefinir',
      destructive: true,
    );
    if (!confirmar || !mounted) return;

    await Hive.box<Habit>(HiveBoxes.habits).clear();
    await Hive.box<HabitLog>(HiveBoxes.logs).clear();
    await NotificationService.cancelAll();

    ref.invalidate(habitsProvider);
    ref.invalidate(logsProvider);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) context.go('/onboarding/step1');
  }

  @override
  Widget build(BuildContext context) {
    final inicial = _nome.isNotEmpty ? _nome[0].toUpperCase() : '?';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'configurações',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nome,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_membroDesde.isNotEmpty)
                        Text(
                          'membro desde $_membroDesde',
                          style: const TextStyle(
                              color: AppColors.soft, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _secao('NOTIFICAÇÕES'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('lembretes diários',
                    style: TextStyle(color: AppColors.text)),
                value: _notifReminders,
                onChanged: (v) {
                  setState(() => _notifReminders = v);
                  _salvar('notif_reminders', v);
                  if (!v) NotificationService.cancelAll();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('resumo noturno',
                    style: TextStyle(color: AppColors.text)),
                subtitle: const Text('notificação às 22:30',
                    style: TextStyle(color: AppColors.soft, fontSize: 12)),
                value: _notifSummary,
                onChanged: (v) {
                  setState(() => _notifSummary = v);
                  _salvar('notif_summary', v);
                  if (v) {
                    NotificationService.scheduleNightSummary();
                  } else {
                    NotificationService.cancelNightSummary();
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('alerta de streak',
                    style: TextStyle(color: AppColors.text)),
                value: _notifStreak,
                onChanged: (v) {
                  setState(() => _notifStreak = v);
                  _salvar('notif_streak_alert', v);
                },
              ),
              const SizedBox(height: 16),
              _secao('APARÊNCIA'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('modo escuro',
                    style: TextStyle(color: AppColors.text)),
                subtitle: const Text('app sempre usa tema escuro',
                    style: TextStyle(color: AppColors.soft, fontSize: 12)),
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _salvar('dark_mode', v);
                },
              ),
              const SizedBox(height: 16),
              _secao('DADOS'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('redefinir todos os dados',
                    style: TextStyle(color: AppColors.redDark)),
                trailing:
                    const Icon(Icons.delete_outline, color: AppColors.redDark),
                onTap: _redefinir,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.soft,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
