import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medicine/domain/entities/dose.dart';
import 'package:meditrack/features/medicine/domain/entities/medicine.dart';
import 'package:meditrack/features/medicine/domain/usecases/add_medicine_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/delete_medicine_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/generate_occurrences_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/get_medicines_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/pause_medicine_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/resume_medicine_usecase.dart';
import 'package:meditrack/features/medicine/domain/usecases/update_medicine_usecase.dart';
import 'package:meditrack/features/medicine/presentation/bloc/medicine_bloc.dart';
import 'package:meditrack/features/medicine/presentation/bloc/medicine_event.dart';
import 'package:meditrack/features/medicine/presentation/bloc/medicine_state.dart';

import 'medicine_usecases_test.dart';

void main() {
  late FakeMedicineRepository medicineRepo;
  late FakeOccurrenceRepository occurrenceRepo;
  late MedicineBloc bloc;

  setUp(() {
    medicineRepo = FakeMedicineRepository();
    occurrenceRepo = FakeOccurrenceRepository();

    final generateOccurrences = GenerateOccurrencesUseCase(occurrenceRepo);

    bloc = MedicineBloc(
      getMedicines: GetMedicinesUseCase(medicineRepo),
      addMedicine: AddMedicineUseCase(medicineRepo, generateOccurrences),
      updateMedicine: UpdateMedicineUseCase(
          medicineRepo, occurrenceRepo, generateOccurrences),
      deleteMedicine: DeleteMedicineUseCase(medicineRepo, occurrenceRepo),
      pauseMedicine: PauseMedicineUseCase(medicineRepo),
      resumeMedicine: ResumeMedicineUseCase(medicineRepo, generateOccurrences),
    );
  });

  tearDown(() {
    bloc.close();
  });

  Medicine _testMedicine() => buildMedicine(id: 'test_m1');

  test('initial state is MedicineInitial', () {
    expect(bloc.state, isA<MedicineInitial>());
  });

  test('LoadMedicines emits Loading then Loaded', () async {
    final med = _testMedicine();
    await medicineRepo.saveMedicine(med);

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    bloc.add(const LoadMedicines());

    // allow event loop to process
    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 2);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineLoaded>());
    expect((states[1] as MedicineLoaded).medicines.length, 1);
  });

  test('AddMedicine emits Loading, Success, then Loaded', () async {
    final med = _testMedicine();

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    bloc.add(AddMedicine(med));

    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 3);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineOperationSuccess>());
    expect(states[2], isA<MedicineLoaded>());

    final loadedState = states[2] as MedicineLoaded;
    expect(loadedState.medicines.length, 1);
    expect(loadedState.medicines.first.id, med.id);
  });

  test('UpdateMedicine emits Loading, Success, then Loaded', () async {
    final med = _testMedicine();
    await medicineRepo.saveMedicine(med);

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    final updated = buildMedicine(id: med.id, isActive: false);
    bloc.add(UpdateMedicine(updated));

    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 3);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineOperationSuccess>());
    expect(states[2], isA<MedicineLoaded>());

    final loadedState = states[2] as MedicineLoaded;
    expect(loadedState.medicines.first.isActive, isFalse);
  });

  test('DeleteMedicine emits Loading, Success, then Loaded', () async {
    final med = _testMedicine();
    await medicineRepo.saveMedicine(med);

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    bloc.add(DeleteMedicine(med.id));

    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 3);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineOperationSuccess>());
    expect(states[2], isA<MedicineLoaded>());

    final loadedState = states[2] as MedicineLoaded;
    expect(loadedState.medicines, isEmpty);
  });

  test('PauseMedicine emits Loading then Loaded', () async {
    final med = _testMedicine();
    await medicineRepo.saveMedicine(med);

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    bloc.add(PauseMedicine(med));

    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 2);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineLoaded>());

    final loadedState = states[1] as MedicineLoaded;
    expect(loadedState.medicines.first.isActive, isFalse);
  });

  test('ResumeMedicine emits Loading then Loaded', () async {
    final med = buildMedicine(id: 'test_m2', isActive: false);
    await medicineRepo.saveMedicine(med);

    final states = <MedicineState>[];
    bloc.stream.listen(states.add);

    bloc.add(ResumeMedicine(med));

    await Future.delayed(const Duration(milliseconds: 10));

    expect(states.length, 2);
    expect(states[0], isA<MedicineLoading>());
    expect(states[1], isA<MedicineLoaded>());

    final loadedState = states[1] as MedicineLoaded;
    expect(loadedState.medicines.first.isActive, isTrue);
  });
}
