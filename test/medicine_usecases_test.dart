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
import 'package:meditrack/features/reminder/domain/entities/dose_occurrence.dart';
import 'package:meditrack/features/reminder/domain/entities/dose_status.dart';
import 'package:meditrack/features/reminder/domain/repositories/dose_occurrence_repository.dart';
import 'package:meditrack/features/medicine/domain/repositories/medicine_repository.dart';
import 'package:meditrack/features/medicine/domain/entities/medicine.dart';

// ---------------------------------------------------------------------------
// Fake implementations for testing without Hive
// ---------------------------------------------------------------------------

class FakeMedicineRepository implements MedicineRepository {
  final Map<String, Medicine> _storage = {};

  @override
  Future<void> saveMedicine(Medicine medicine) async {
    _storage[medicine.id] = medicine;
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    _storage[medicine.id] = medicine;
  }

  @override
  Future<Medicine?> getMedicine(String id) async => _storage[id];

  @override
  Future<List<Medicine>> getMedicines() async => _storage.values.toList();

  @override
  Future<void> deleteMedicine(String id) async => _storage.remove(id);
}

class FakeOccurrenceRepository implements DoseOccurrenceRepository {
  final Map<String, DoseOccurrence> _storage = {};

  @override
  Future<void> saveOccurrence(DoseOccurrence occurrence) async {
    _storage[occurrence.id] = occurrence;
  }

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {
    for (final occ in occurrences) {
      _storage[occ.id] = occ;
    }
  }

  @override
  Future<DoseOccurrence?> getOccurrence(String id) async => _storage[id];

  @override
  Future<List<DoseOccurrence>> getOccurrences() async =>
      _storage.values.toList();

  @override
  Future<List<DoseOccurrence>> getOccurrencesByMedicine(
      String medicineId) async {
    return _storage.values
        .where((occ) => occ.medicineId == medicineId)
        .toList();
  }

  @override
  Future<void> deleteOccurrence(String id) async => _storage.remove(id);

  @override
  Future<void> deleteOccurrencesByMedicine(String medicineId) async {
    _storage.removeWhere((_, occ) => occ.medicineId == medicineId);
  }

  @override
  Future<void> deleteFutureOccurrencesByMedicine(
      String medicineId, DateTime fromDate) async {
    _storage.removeWhere((_, occ) =>
        occ.medicineId == medicineId && !occ.scheduledAt.isBefore(fromDate));
  }
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Medicine buildMedicine({
  String id = 'med_1',
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
  List<Dose>? doses,
}) {
  final now = DateTime.now();
  return Medicine(
    id: id,
    name: 'Paracetamol',
    description: 'Pain reliever',
    type: 'Tablet',
    strength: '500mg',
    startDate: startDate ?? now,
    endDate: endDate,
    doses: doses ??
        [
          const Dose(
              id: 'd1',
              time: '08:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
        ],
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMedicineRepository medicineRepo;
  late FakeOccurrenceRepository occurrenceRepo;
  late GenerateOccurrencesUseCase generateOccurrences;

  setUp(() {
    medicineRepo = FakeMedicineRepository();
    occurrenceRepo = FakeOccurrenceRepository();
    generateOccurrences = GenerateOccurrencesUseCase(occurrenceRepo);
  });

  // 1. Get Medicines
  group('GetMedicinesUseCase', () {
    test('returns empty list when no medicines saved', () async {
      final useCase = GetMedicinesUseCase(medicineRepo);
      final result = await useCase();
      expect(result, isEmpty);
    });

    test('returns all saved medicines', () async {
      await medicineRepo.saveMedicine(buildMedicine(id: 'a'));
      await medicineRepo.saveMedicine(buildMedicine(id: 'b'));
      final useCase = GetMedicinesUseCase(medicineRepo);
      final result = await useCase();
      expect(result.length, 2);
    });
  });

  // 2 & 3. Add Medicine
  group('AddMedicineUseCase', () {
    test('saves medicine and generates occurrences', () async {
      final useCase = AddMedicineUseCase(medicineRepo, generateOccurrences);
      final today = DateTime.now();
      final medicine = buildMedicine(
        startDate: today,
        endDate: today,
        doses: [
          const Dose(
              id: 'd1',
              time: '08:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
        ],
      );

      await useCase(medicine);

      expect(await medicineRepo.getMedicine(medicine.id), isNotNull);
      final occurrences =
          await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(occurrences.length, 1);
    });

    test('generates correct occurrences for multiple doses', () async {
      final useCase = AddMedicineUseCase(medicineRepo, generateOccurrences);
      final start = DateTime(2023, 8, 10);
      final end = DateTime(2023, 8, 16); // 7 days
      final medicine = buildMedicine(
        startDate: start,
        endDate: end,
        doses: [
          const Dose(
              id: 'd1',
              time: '08:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
          const Dose(
              id: 'd2',
              time: '14:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
          const Dose(
              id: 'd3',
              time: '20:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
        ],
      );

      await useCase(medicine);

      final occurrences =
          await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(occurrences.length, 21); // 7 days × 3 doses
    });

    test('throws when no doses provided', () async {
      final useCase = AddMedicineUseCase(medicineRepo, generateOccurrences);
      final medicine = buildMedicine(doses: []);

      expect(() => useCase(medicine), throwsArgumentError);
    });
  });

  // 6. Update Medicine
  group('UpdateMedicineUseCase', () {
    test('updates medicine in repository', () async {
      final medicine = buildMedicine(
        startDate: DateTime(2023, 8, 10),
        endDate: DateTime(2023, 8, 16),
      );
      await medicineRepo.saveMedicine(medicine);

      final useCase = UpdateMedicineUseCase(
          medicineRepo, occurrenceRepo, generateOccurrences);

      final updated = Medicine(
        id: medicine.id,
        name: 'Updated Paracetamol',
        description: medicine.description,
        type: medicine.type,
        strength: '650mg',
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        doses: medicine.doses,
        isActive: medicine.isActive,
        createdAt: medicine.createdAt,
        updatedAt: DateTime.now(),
      );

      await useCase(updated);

      final loaded = await medicineRepo.getMedicine(medicine.id);
      expect(loaded!.name, 'Updated Paracetamol');
      expect(loaded.strength, '650mg');
    });

    // 7. Historical occurrence preservation
    test('does not modify past occurrences when medicine is updated', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final pastOccurrence = DoseOccurrence(
        id: 'med_1_d1_${DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 0).toIso8601String()}',
        medicineId: 'med_1',
        doseId: 'd1',
        scheduledAt:
            DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 0),
        doseQuantity: 1,
        doseUnit: 'Tablet',
        foodInstruction: 'After food',
        status: DoseStatus.pending,
        createdAt: yesterday,
      );

      await occurrenceRepo.saveOccurrence(pastOccurrence);

      final medicine = buildMedicine(
        startDate: yesterday,
        endDate: DateTime.now().add(const Duration(days: 3)),
      );

      final useCase = UpdateMedicineUseCase(
          medicineRepo, occurrenceRepo, generateOccurrences);
      await useCase(medicine);

      // Past occurrence must still exist
      final stillExists = await occurrenceRepo.getOccurrence(pastOccurrence.id);
      expect(stillExists, isNotNull);
      expect(stillExists!.doseQuantity, 1);
    });

    // 8. Future occurrence synchronization
    test('removes obsolete future occurrences when dose is removed', () async {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 6));

      final medicine = buildMedicine(
        startDate: start,
        endDate: end,
        doses: [
          const Dose(
              id: 'd1',
              time: '08:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
          const Dose(
              id: 'd2',
              time: '20:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
        ],
      );

      await medicineRepo.saveMedicine(medicine);

      // Generate initial occurrences: 7 days × 2 doses = 14
      await generateOccurrences(medicine);
      final before = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(before.length, 14);

      // Update: remove dose d2
      final updatedMedicine = Medicine(
        id: medicine.id,
        name: medicine.name,
        description: medicine.description,
        type: medicine.type,
        strength: medicine.strength,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        doses: [medicine.doses.first], // only 08:00 remains
        isActive: true,
        createdAt: medicine.createdAt,
        updatedAt: DateTime.now(),
      );

      final useCase = UpdateMedicineUseCase(
          medicineRepo, occurrenceRepo, generateOccurrences);
      await useCase(updatedMedicine);

      final after = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      // Future 20:00 occurrences removed, only 1 dose × 7 days = 7 remain
      expect(after.length, 7);
    });
  });

  // 11. Delete Medicine
  group('DeleteMedicineUseCase', () {
    test('deletes medicine and all associated occurrences', () async {
      final medicine = buildMedicine(
        startDate: DateTime(2023, 8, 10),
        endDate: DateTime(2023, 8, 16),
      );
      await medicineRepo.saveMedicine(medicine);
      await generateOccurrences(medicine);

      final before = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(before.isNotEmpty, isTrue);

      final useCase = DeleteMedicineUseCase(medicineRepo, occurrenceRepo);
      await useCase(medicine.id);

      expect(await medicineRepo.getMedicine(medicine.id), isNull);
      final after = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(after, isEmpty);
    });
  });

  // 12. Pause Medicine
  group('PauseMedicineUseCase', () {
    test('sets isActive to false', () async {
      final medicine = buildMedicine(isActive: true);
      await medicineRepo.saveMedicine(medicine);

      final useCase = PauseMedicineUseCase(medicineRepo);
      await useCase(medicine);

      final loaded = await medicineRepo.getMedicine(medicine.id);
      expect(loaded!.isActive, isFalse);
    });
  });

  // 13 & 14. Resume Medicine
  group('ResumeMedicineUseCase', () {
    test('sets isActive to true', () async {
      final medicine = buildMedicine(isActive: false);
      await medicineRepo.saveMedicine(medicine);

      final useCase = ResumeMedicineUseCase(medicineRepo, generateOccurrences);
      await useCase(medicine);

      final loaded = await medicineRepo.getMedicine(medicine.id);
      expect(loaded!.isActive, isTrue);
    });

    test('does not create duplicates when resumed', () async {
      final today = DateTime.now();
      final medicine = buildMedicine(
        startDate: today,
        endDate: today,
        isActive: false,
      );
      await medicineRepo.saveMedicine(medicine);

      // Pre-generate occurrences
      await generateOccurrences(medicine);
      final before = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(before.length, 1);

      // Resume — should not create duplicate
      final useCase = ResumeMedicineUseCase(medicineRepo, generateOccurrences);
      await useCase(medicine);

      final after = await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(after.length, 1);
    });
  });

  // 15. Invalid date range
  group('AddMedicineUseCase - validation', () {
    test('generates 0 occurrences when endDate is before startDate', () async {
      final useCase = AddMedicineUseCase(medicineRepo, generateOccurrences);
      final medicine = buildMedicine(
        startDate: DateTime(2023, 8, 16),
        endDate: DateTime(2023, 8, 10), // invalid
      );

      await useCase(medicine);

      final occurrences =
          await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(occurrences, isEmpty);
    });

    test('same-day medicine generates occurrences for single day', () async {
      final useCase = AddMedicineUseCase(medicineRepo, generateOccurrences);
      final today = DateTime.now();
      final medicine = buildMedicine(
        startDate: today,
        endDate: today,
        doses: [
          const Dose(
              id: 'd1',
              time: '08:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
          const Dose(
              id: 'd2',
              time: '14:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
          const Dose(
              id: 'd3',
              time: '20:00',
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'After food'),
        ],
      );

      await useCase(medicine);

      final occurrences =
          await occurrenceRepo.getOccurrencesByMedicine(medicine.id);
      expect(occurrences.length, 3);
    });
  });
}
