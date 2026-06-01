import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/app_button.dart';

const _habitos = [
  'Beber água',
  'Meditar',
  'Exercitar',
  'Dormir cedo',
  'Ler',
  'Estudar',
  'Caminhar',
  'Alongar',
  'Respirar',
];

class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final Set<String> _selecionados = {};

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
              const _ProgressBar(step: 2),
              const SizedBox(height: 24),
              const Text(
                'que hábitos quer cultivar?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _habitos.map((h) {
                    final sel = _selecionados.contains(h);
                    return GestureDetector(
                      onTap: () => setState(() {
                        sel ? _selecionados.remove(h) : _selecionados.add(h);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.accent : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? AppColors.accent : AppColors.muted,
                          ),
                        ),
                        child: Text(
                          h,
                          style: TextStyle(
                            color: sel ? AppColors.text : AppColors.soft,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                'continuar',
                onPressed: _selecionados.isEmpty
                    ? null
                    : () => context.push(
                          '/onboarding/step3',
                          extra: _selecionados.toList(),
                        ),
              ),
              const SizedBox(height: 8),
              AppButton(
                'criar hábito próprio',
                ghost: true,
                onPressed: () => context.push('/habit/add/step1'),
              ),
              const SizedBox(height: 16),
            ],
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
