import '../../domain/entities/medicine.dart';

abstract class MedicineState {
  const MedicineState();
}

class MedicineInitial extends MedicineState {
  const MedicineInitial();
}

class MedicineLoading extends MedicineState {
  const MedicineLoading();
}

class MedicineLoaded extends MedicineState {
  final List<Medicine> medicines;
  const MedicineLoaded(this.medicines);
}

class MedicineOperationSuccess extends MedicineState {
  final String message;
  const MedicineOperationSuccess(this.message);
}

class MedicineError extends MedicineState {
  final String message;
  const MedicineError(this.message);
}
