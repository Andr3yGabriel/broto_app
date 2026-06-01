import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitFormData {
  final String name;
  final String icon;
  final String color;
  final String frequency;
  final bool reminderEnabled;
  final String reminderTime;
  final List<int> reminderDays;

  const HabitFormData({
    this.name = '',
    this.icon = '',
    this.color = '#7F77DD',
    this.frequency = 'daily',
    this.reminderEnabled = false,
    this.reminderTime = '08:00',
    this.reminderDays = const [],
  });

  HabitFormData copyWith({
    String? name,
    String? icon,
    String? color,
    String? frequency,
    bool? reminderEnabled,
    String? reminderTime,
    List<int>? reminderDays,
  }) {
    return HabitFormData(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}

class HabitFormNotifier extends StateNotifier<HabitFormData> {
  HabitFormNotifier() : super(const HabitFormData());

  void updateStep1(String name, String icon, String color, String frequency) {
    state = state.copyWith(
      name: name,
      icon: icon,
      color: color,
      frequency: frequency,
    );
  }

  void updateStep2(
      bool reminderEnabled, String reminderTime, List<int> reminderDays) {
    state = state.copyWith(
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
    );
  }

  void reset() {
    state = const HabitFormData();
  }
}

final habitFormProvider =
    StateNotifierProvider<HabitFormNotifier, HabitFormData>(
  (ref) => HabitFormNotifier(),
);
