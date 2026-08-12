import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_box_names.dart';
import '../../features/medicine/data/models/dose_model.dart';
import '../../features/medicine/data/models/medicine_model.dart';
import '../../features/reminder/data/models/dose_occurrence_model.dart';
import '../../features/settings/data/models/settings_model.dart';

class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(MedicineModelAdapter());
    Hive.registerAdapter(DoseModelAdapter());
    Hive.registerAdapter(DoseOccurrenceModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    // Open Boxes
    await Hive.openBox<MedicineModel>(HiveBoxNames.medicines);
    await Hive.openBox<DoseOccurrenceModel>(HiveBoxNames.occurrences);
    await Hive.openBox<SettingsModel>(HiveBoxNames.settings);
  }
}
