import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medicine/domain/entities/dose.dart';
import 'package:meditrack/features/medicine/domain/entities/medicine.dart';
import 'package:meditrack/features/medicine/domain/usecases/generate_occurrences_usecase.dart';
import 'package:meditrack/features/reminder/domain/entities/dose_occurrence.dart';
import 'package:meditrack/features/reminder/domain/repositories/dose_occurrence_repository.dart';

class FakeDoseOccurrenceRepository implements DoseOccurrenceRepository {
  final Map<String, DoseOccurrence> _storage = {};

  @override
  Future<void> saveOccurrence(DoseOccurrence occurrence) async {
    _storage[occurrence.id] = occurrence;
  }

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {
    for (var occ in occurrences) {
      _storage[occ.id] = occ;
    }
  }

  @override
  Future<DoseOccurrence?> getOccurrence(String id) async {
    return _storage[id];
  }

  @override
  Future<List<DoseOccurrence>> getOccurrences() async {
    return _storage.values.toList();
  }

  @override
  Future<List<DoseOccurrence>> getOccurrencesByMedicine(
      String medicineId) async {
    return _storage.values
        .where((occ) => occ.medicineId == medicineId)
        .toList();
  }

  @override
  Future<void> deleteOccurrence(String id) async {
    _storage.remove(id);
  }
}

void main() {
  late FakeDoseOccurrenceRepository repository;
  late GenerateOccurrencesUseCase useCase;

  setUp(() {
    repository = FakeDoseOccurrenceRepository();
    useCase = GenerateOccurrencesUseCase(repository);
  });

  Medicine createMedicine({
    required String id,
    required DateTime startDate,
    DateTime? endDate,
    required List<Dose> doses,
  }) {
    return Medicine(
      id: id,
      name: 'Test Med',
      description: 'Desc',
      type: 'Pill',
      strength: '10mg',
      startDate: startDate,
      endDate: endDate,
      doses: doses,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Dose createDose(String id, String time) {
    return Dose(
      id: id,
      time: time,
      quantity: 1.0,
      unit: 'pill',
      foodInstruction: 'None',
    );
  }

  test('TEST 1 - SAME DAY: Should generate exactly 3 occurrences', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm1',
      startDate: today,
      endDate: today,
      doses: [
        createDose('d1', '08:00'),
        createDose('d2', '14:00'),
        createDose('d3', '20:00'),
      ],
    );

    final result = await useCase(med);
    expect(result.length, 3);
  });

  test('TEST 2 - SEVEN DAYS / THREE DOSES: Should generate 21 occurrences',
      () async {
    final start = DateTime(2023, 8, 10);
    final end = DateTime(2023, 8, 16); // 10,11,12,13,14,15,16 = 7 days
    final med = createMedicine(
      id: 'm2',
      startDate: start,
      endDate: end,
      doses: [
        createDose('d1', '08:00'),
        createDose('d2', '14:00'),
        createDose('d3', '20:00'),
      ],
    );

    final result = await useCase(med);
    expect(result.length, 21);
  });

  test('TEST 3 - SEVEN DAYS / TWO DOSES: Should generate 14 occurrences',
      () async {
    final start = DateTime(2023, 8, 1);
    final end = DateTime(2023, 8, 7);
    final med = createMedicine(
      id: 'm3',
      startDate: start,
      endDate: end,
      doses: [
        createDose('d1', '08:00'),
        createDose('d2', '20:00'),
      ],
    );

    final result = await useCase(med);
    expect(result.length, 14);
  });

  test('TEST 4 - EXACT TIME PRESERVATION', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm4',
      startDate: today,
      endDate: today,
      doses: [createDose('d1', '08:30')],
    );

    final result = await useCase(med);
    expect(result.length, 1);
    expect(result.first.scheduledAt.hour, 8);
    expect(result.first.scheduledAt.minute, 30);
  });

  test('TEST 5 - MULTIPLE DOSE TIMES', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm5',
      startDate: today,
      endDate: today,
      doses: [
        createDose('d1', '08:00'),
        createDose('d2', '13:30'),
        createDose('d3', '21:00'),
      ],
    );

    final result = await useCase(med);
    expect(result.length, 3);

    final times = result
        .map((o) =>
            '${o.scheduledAt.hour.toString().padLeft(2, '0')}:${o.scheduledAt.minute.toString().padLeft(2, '0')}')
        .toList();
    expect(times, containsAll(['08:00', '13:30', '21:00']));
  });

  test('TEST 6 - ONGOING MEDICINE: Should limit to rolling window', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm6',
      startDate:
          today.subtract(const Duration(days: 10)), // started 10 days ago
      endDate: null, // ongoing
      doses: [createDose('d1', '08:00')],
    );

    final result = await useCase(med);

    // Rolling window is today to today + 14 days (inclusive) = 15 occurrences
    // Because: today + 1 day = 2, +14 days = 15 total days including today.
    expect(result.length, 15);

    // Verify it didn't generate past occurrences from 10 days ago
    final earliest = result
        .map((e) => e.scheduledAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    expect(earliest.year, today.year);
    expect(earliest.month, today.month);
    expect(earliest.day, today.day);
  });

  test('TEST 7 - DUPLICATE PREVENTION: Repeated generation is idempotent',
      () async {
    final start = DateTime(2023, 8, 10);
    final end = DateTime(2023, 8, 16);
    final med = createMedicine(
      id: 'm7',
      startDate: start,
      endDate: end,
      doses: [
        createDose('d1', '08:00'),
        createDose('d2', '14:00'),
        createDose('d3', '20:00'),
      ],
    );

    final firstRun = await useCase(med);
    expect(firstRun.length, 21);

    final secondRun = await useCase(med);
    expect(secondRun.length, 0); // No NEW occurrences generated

    final allInRepo = await repository.getOccurrencesByMedicine('m7');
    expect(allInRepo.length, 21);
  });

  test('TEST 8 - SNAPSHOT PRESERVATION', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm8',
      startDate: today,
      endDate: today,
      doses: [
        Dose(
            id: 'd1',
            time: '08:00',
            quantity: 1,
            unit: 'Tablet',
            foodInstruction: 'After Food'),
      ],
    );

    await useCase(med);

    // Simulate medicine being edited
    final editedMed = createMedicine(
      id: 'm8',
      startDate: today,
      endDate: today,
      doses: [
        Dose(
            id: 'd1',
            time: '08:00',
            quantity: 2,
            unit: 'Tablets',
            foodInstruction: 'Before Food'),
      ],
    );

    await useCase(editedMed); // Run generator again

    final allInRepo = await repository.getOccurrencesByMedicine('m8');
    expect(allInRepo.length, 1);

    final historical = allInRepo.first;
    expect(historical.doseQuantity, 1.0);
    expect(historical.doseUnit, 'Tablet');
    expect(historical.foodInstruction, 'After Food');
    // Snapshot was preserved, didn't update to editedMed values.
  });

  test('TEST 9 - EMPTY DOSES: Should generate zero occurrences', () async {
    final today = DateTime.now();
    final med = createMedicine(
      id: 'm9',
      startDate: today,
      endDate: today,
      doses: [],
    );

    final result = await useCase(med);
    expect(result.isEmpty, isTrue);
  });

  test('TEST 10 - INVALID DATE RANGE: startDate > endDate', () async {
    final start = DateTime(2023, 8, 10);
    final end = DateTime(2023, 8, 5); // Invalid
    final med = createMedicine(
      id: 'm10',
      startDate: start,
      endDate: end,
      doses: [createDose('d1', '08:00')],
    );

    final result = await useCase(med);
    expect(result.isEmpty, isTrue);
  });
}
