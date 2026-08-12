import '../entities/medicine.dart';

abstract class MedicineRepository {
  Future<void> saveMedicine(Medicine medicine);
  Future<void> updateMedicine(Medicine medicine);
  Future<Medicine?> getMedicine(String id);
  Future<List<Medicine>> getMedicines();
  Future<void> deleteMedicine(String id);
}
