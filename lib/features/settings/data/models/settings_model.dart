import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 3)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool notificationsOn;

  @HiveField(1)
  bool vibrationOn;

  @HiveField(2)
  int defaultSnoozeMin;

  @HiveField(3)
  String sound;

  SettingsModel({
    required this.notificationsOn,
    required this.vibrationOn,
    required this.defaultSnoozeMin,
    required this.sound,
  });
}
