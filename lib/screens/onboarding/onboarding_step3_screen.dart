import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/app_button.dart';

class OnboardingStep3Screen extends StatefulWidget {
  final Object? extra;
  const OnboardingStep3Screen({super.key, this.extra});

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  late List<String> _habitos;
  late Map<String, TimeOfDay> _horarios;

  @override
  void initState() {
    super.initState();
    _habitos =
        (widget.extra as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    _horarios = {
      for (final h in _habitos) h: const TimeOfDay(hour: 8, minute: 0),
    };
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(String habito) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horarios[habito]!,
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
    if (picked != null) {
      setState(() => _horarios[habito] = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _progressBar(3),
              const SizedBox(height: 24),
              const Text(
                'quando quer ser lembrado?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _habitos.length,
                  itemBuilder: (context, i) {
                    final h = _habitos[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(h,
                              style: const TextStyle(color: AppColors.text)),
                          TextButton(
                            onPressed: () => _pickTime(h),
                            child: Text(
                              _formatTime(_horarios[h]!),
                              style: const TextStyle(color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              AppButton(
                'confirmar horários',
                onPressed: () => context.push(
                  '/onboarding/step4',
                  extra: {
                    'habitos': _habitos,
                    'horarios': _horarios.map(
                      (k, v) => MapEntry(k, _formatTime(v)),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(int step) {
    return Row(
      children: List.generate(4, (i) {
        final ativo = i < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: ativo ? AppColors.accent : AppColors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
