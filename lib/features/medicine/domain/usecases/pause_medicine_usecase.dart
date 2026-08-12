import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

class PauseMedicineUseCase {
  final MedicineRepository _repository;

  PauseMedicineUseCase(this._repository);

  Future<void> call(Medicine medicine) async {
    final paused = Medicine(
      id: medicine.id,
      name: medicine.name,
      description: medicine.description,
      type: medicine.type,
      strength: medicine.strength,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      doses: medicine.doses,
      isActive: false,
      createdAt: medicine.createdAt,
      updatedAt: DateTime.now(),
    );
    await _repository.updateMedicine(paused);
  }
}
