import '../../domain/entities/medicine.dart';

abstract class MedicineEvent {
  const MedicineEvent();
}

class LoadMedicines extends MedicineEvent {
  const LoadMedicines();
}

class AddMedicine extends MedicineEvent {
  final Medicine medicine;
  const AddMedicine(this.medicine);
}

class UpdateMedicine extends MedicineEvent {
  final Medicine medicine;
  const UpdateMedicine(this.medicine);
}

class DeleteMedicine extends MedicineEvent {
  final String medicineId;
  const DeleteMedicine(this.medicineId);
}

class PauseMedicine extends MedicineEvent {
  final Medicine medicine;
  const PauseMedicine(this.medicine);
}

class ResumeMedicine extends MedicineEvent {
  final Medicine medicine;
  const ResumeMedicine(this.medicine);
}
