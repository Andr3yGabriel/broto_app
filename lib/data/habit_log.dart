import 'package:hive/hive.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  @HiveField(0)
  late int habitId;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late bool completed;
}
