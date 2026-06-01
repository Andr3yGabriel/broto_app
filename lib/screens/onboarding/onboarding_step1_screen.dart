import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onComecar() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _controller.text.trim());
    if (mounted) context.push('/onboarding/step2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Text(
                  '🌱 Broto',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'cultive seus hábitos, dia após dia',
                  style: TextStyle(color: AppColors.soft, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                AppTextField(
                  label: 'como podemos te chamar?',
                  controller: _controller,
                  hint: 'seu nome',
                ),
                const SizedBox(height: 24),
                AppButton('começar', onPressed: _onComecar),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
