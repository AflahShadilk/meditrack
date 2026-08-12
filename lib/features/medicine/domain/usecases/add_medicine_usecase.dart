import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';
import 'generate_occurrences_usecase.dart';

class AddMedicineUseCase {
  final MedicineRepository _medicineRepository;
  final GenerateOccurrencesUseCase _generateOccurrences;

  AddMedicineUseCase(this._medicineRepository, this._generateOccurrences);

  Future<void> call(Medicine medicine) async {
    if (medicine.doses.isEmpty) {
      throw ArgumentError('A medicine must have at least one dose.');
    }
    await _medicineRepository.saveMedicine(medicine);
    await _generateOccurrences(medicine);
  }
}
