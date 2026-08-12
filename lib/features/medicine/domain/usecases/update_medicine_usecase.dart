import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';
import '../../../../features/reminder/domain/repositories/dose_occurrence_repository.dart';
import 'generate_occurrences_usecase.dart';

class UpdateMedicineUseCase {
  final MedicineRepository _medicineRepository;
  final DoseOccurrenceRepository _occurrenceRepository;
  final GenerateOccurrencesUseCase _generateOccurrences;

  UpdateMedicineUseCase(
    this._medicineRepository,
    this._occurrenceRepository,
    this._generateOccurrences,
  );

  Future<void> call(Medicine medicine) async {
    // 1. Persist the updated medicine.
    await _medicineRepository.updateMedicine(medicine);

    // 2. Determine the cutoff: start of today.
    // Occurrences before today are historical and must not be touched.
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day);

    // 3. Delete obsolete future occurrences so the new schedule takes effect.
    await _occurrenceRepository.deleteFutureOccurrencesByMedicine(
      medicine.id,
      cutoff,
    );

    // 4. Regenerate future occurrences based on the new schedule.
    // GenerateOccurrencesUseCase is idempotent — it won't duplicate
    // any occurrences that were preserved (i.e., today's pending ones).
    await _generateOccurrences(medicine);
  }
}
