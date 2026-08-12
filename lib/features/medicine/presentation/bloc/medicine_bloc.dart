import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_medicines_usecase.dart';
import '../../domain/usecases/pause_medicine_usecase.dart';
import '../../domain/usecases/resume_medicine_usecase.dart';
import '../../domain/usecases/update_medicine_usecase.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetMedicinesUseCase _getMedicines;
  final AddMedicineUseCase _addMedicine;
  final UpdateMedicineUseCase _updateMedicine;
  final DeleteMedicineUseCase _deleteMedicine;
  final PauseMedicineUseCase _pauseMedicine;
  final ResumeMedicineUseCase _resumeMedicine;

  MedicineBloc({
    required GetMedicinesUseCase getMedicines,
    required AddMedicineUseCase addMedicine,
    required UpdateMedicineUseCase updateMedicine,
    required DeleteMedicineUseCase deleteMedicine,
    required PauseMedicineUseCase pauseMedicine,
    required ResumeMedicineUseCase resumeMedicine,
  })  : _getMedicines = getMedicines,
        _addMedicine = addMedicine,
        _updateMedicine = updateMedicine,
        _deleteMedicine = deleteMedicine,
        _pauseMedicine = pauseMedicine,
        _resumeMedicine = resumeMedicine,
        super(const MedicineInitial()) {
    on<LoadMedicines>(_onLoadMedicines);
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<DeleteMedicine>(_onDeleteMedicine);
    on<PauseMedicine>(_onPauseMedicine);
    on<ResumeMedicine>(_onResumeMedicine);
  }

  Future<void> _onLoadMedicines(
      LoadMedicines event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to load medicines.'));
    }
  }

  Future<void> _onAddMedicine(
      AddMedicine event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      await _addMedicine(event.medicine);
      emit(const MedicineOperationSuccess('Medicine added successfully.'));
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to save medicine.'));
    }
  }

  Future<void> _onUpdateMedicine(
      UpdateMedicine event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      await _updateMedicine(event.medicine);
      emit(const MedicineOperationSuccess('Medicine updated successfully.'));
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to update medicine.'));
    }
  }

  Future<void> _onDeleteMedicine(
      DeleteMedicine event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      await _deleteMedicine(event.medicineId);
      emit(const MedicineOperationSuccess('Medicine deleted.'));
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to delete medicine.'));
    }
  }

  Future<void> _onPauseMedicine(
      PauseMedicine event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      await _pauseMedicine(event.medicine);
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to pause medicine.'));
    }
  }

  Future<void> _onResumeMedicine(
      ResumeMedicine event, Emitter<MedicineState> emit) async {
    emit(const MedicineLoading());
    try {
      await _resumeMedicine(event.medicine);
      final medicines = await _getMedicines();
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(const MedicineError('Unable to resume medicine.'));
    }
  }
}
