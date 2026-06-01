import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/habit.dart';

const Map<String, IconData> habitIcons = {
  'water': Icons.water_drop_outlined,
  'brain': Icons.psychology_outlined,
  'run': Icons.directions_run,
  'moon': Icons.nightlight_outlined,
  'book': Icons.menu_book_outlined,
  'activity': Icons.favorite_outline,
  'heart': Icons.self_improvement,
  'pencil': Icons.edit_outlined,
};

class HabitRowTile extends StatefulWidget {
  final Habit habit;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitRowTile({
    super.key,
    required this.habit,
    required this.completed,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<HabitRowTile> createState() => _HabitRowTileState();
}

class _HabitRowTileState extends State<HabitRowTile> {
  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _parseColor(widget.habit.color);
    final icon = habitIcons[widget.habit.icon] ?? Icons.check_circle_outline;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: habitColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: habitColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.habit.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      widget.completed ? AppColors.accent : Colors.transparent,
                  border: Border.all(
                    color:
                        widget.completed ? AppColors.accent : AppColors.muted,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
