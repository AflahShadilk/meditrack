import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/medicine_model.dart';

class MedicineLocalDataSource {
  final Box<MedicineModel> _box;

  MedicineLocalDataSource()
      : _box = Hive.box<MedicineModel>(HiveBoxNames.medicines);

  Future<void> saveMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  Future<MedicineModel?> getMedicine(String id) async {
    return _box.get(id);
  }

  Future<List<MedicineModel>> getMedicines() async {
    return _box.values.toList();
  }

  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }
}
