import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late String color;

  @HiveField(4)
  late String frequency;

  @HiveField(5)
  late String? reminderTime;

  @HiveField(6)
  late List<int> reminderDays;

  @HiveField(7)
  late DateTime createdAt;
}
