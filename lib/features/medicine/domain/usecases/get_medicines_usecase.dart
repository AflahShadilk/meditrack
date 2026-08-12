import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

class GetMedicinesUseCase {
  final MedicineRepository _repository;

  GetMedicinesUseCase(this._repository);

  Future<List<Medicine>> call() async {
    return _repository.getMedicines();
  }
}
