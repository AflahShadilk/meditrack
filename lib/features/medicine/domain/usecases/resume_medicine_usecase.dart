import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';
import 'generate_occurrences_usecase.dart';

class ResumeMedicineUseCase {
  final MedicineRepository _medicineRepository;
  final GenerateOccurrencesUseCase _generateOccurrences;

  ResumeMedicineUseCase(this._medicineRepository, this._generateOccurrences);

  Future<void> call(Medicine medicine) async {
    final resumed = Medicine(
      id: medicine.id,
      name: medicine.name,
      description: medicine.description,
      type: medicine.type,
      strength: medicine.strength,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      doses: medicine.doses,
      isActive: true,
      createdAt: medicine.createdAt,
      updatedAt: DateTime.now(),
    );
    await _medicineRepository.updateMedicine(resumed);

    // Regenerate any missing future occurrences.
    // GenerateOccurrencesUseCase is idempotent — no duplicates will be created.
    await _generateOccurrences(resumed);
  }
}
