import 'package:flutter/material.dart';

import '../core/theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool destructive;

  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.ghost = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (destructive) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.redDark,
          side: const BorderSide(color: AppColors.redDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
        child: Text(label),
      );
    }

    if (ghost) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.soft,
          side: const BorderSide(color: AppColors.muted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
        child: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
