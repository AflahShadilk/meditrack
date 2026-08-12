import '../repositories/medicine_repository.dart';
import '../../../../features/reminder/domain/repositories/dose_occurrence_repository.dart';

class DeleteMedicineUseCase {
  final MedicineRepository _medicineRepository;
  final DoseOccurrenceRepository _occurrenceRepository;

  DeleteMedicineUseCase(this._medicineRepository, this._occurrenceRepository);

  Future<void> call(String medicineId) async {
    // Delete all associated occurrences first, then the medicine itself.
    await _occurrenceRepository.deleteOccurrencesByMedicine(medicineId);
    await _medicineRepository.deleteMedicine(medicineId);
  }
}
