import 'package:flutter/material.dart';

import '../core/theme.dart';

class HeatmapGrid extends StatelessWidget {
  final Map<DateTime, int> data;

  const HeatmapGrid({super.key, required this.data});

  Color _colorForIntensity(int intensity) {
    switch (intensity) {
      case 1:
        return AppColors.card;
      case 2:
        return AppColors.muted;
      case 3:
        return AppColors.accent;
      case 4:
        return AppColors.lighter;
      default:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = data.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final intensity = data[date] ?? 0;
            return Container(
              decoration: BoxDecoration(
                color: _colorForIntensity(intensity),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'menos',
              style: TextStyle(color: AppColors.soft, fontSize: 11),
            ),
            const SizedBox(width: 6),
            ...List.generate(5, (i) {
              return Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _colorForIntensity(i),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
            const SizedBox(width: 6),
            const Text(
              'mais',
              style: TextStyle(color: AppColors.soft, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
