import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditrack/core/constants/hive_box_names.dart';
import 'package:meditrack/features/medicine/data/datasources/medicine_local_data_source.dart';
import 'package:meditrack/features/medicine/data/models/dose_model.dart';
import 'package:meditrack/features/medicine/data/models/medicine_model.dart';
import 'package:meditrack/features/medicine/data/repositories/medicine_repository_impl.dart';
import 'package:meditrack/features/medicine/domain/entities/dose.dart';
import 'package:meditrack/features/medicine/domain/entities/medicine.dart';
import 'package:meditrack/features/reminder/data/datasources/dose_occurrence_local_data_source.dart';
import 'package:meditrack/features/reminder/data/models/dose_occurrence_model.dart';
import 'package:meditrack/features/reminder/data/repositories/dose_occurrence_repository_impl.dart';
import 'package:meditrack/features/reminder/domain/entities/dose_occurrence.dart';
import 'package:meditrack/features/reminder/domain/entities/dose_status.dart';
import 'package:meditrack/features/settings/data/models/settings_model.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);

    Hive.registerAdapter(MedicineModelAdapter());
    Hive.registerAdapter(DoseModelAdapter());
    Hive.registerAdapter(DoseOccurrenceModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
  });

  setUp(() async {
    await Hive.openBox<MedicineModel>(HiveBoxNames.medicines);
    await Hive.openBox<DoseOccurrenceModel>(HiveBoxNames.occurrences);
    await Hive.openBox<SettingsModel>(HiveBoxNames.settings);
  });

  tearDown(() async {
    await Hive.box<MedicineModel>(HiveBoxNames.medicines).clear();
    await Hive.box<DoseOccurrenceModel>(HiveBoxNames.occurrences).clear();
    await Hive.box<SettingsModel>(HiveBoxNames.settings).clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Medicine Persistence Test', () {
    test('Should save and load a Medicine entity correctly', () async {
      final dataSource = MedicineLocalDataSource();
      final repository = MedicineRepositoryImpl(dataSource);

      final date = DateTime(2023, 1, 1);
      final medicine = Medicine(
        id: 'med_1',
        name: 'Paracetamol',
        description: 'Pain reliever',
        type: 'Tablet',
        strength: '500mg',
        startDate: date,
        endDate: null,
        isActive: true,
        createdAt: date,
        updatedAt: date,
        doses: const [
          Dose(
            id: 'dose_1',
            time: '08:00',
            quantity: 1.0,
            unit: 'tablet',
            foodInstruction: 'After food',
          ),
          Dose(
            id: 'dose_2',
            time: '14:00',
            quantity: 1.0,
            unit: 'tablet',
            foodInstruction: 'After food',
          ),
          Dose(
            id: 'dose_3',
            time: '20:00',
            quantity: 1.0,
            unit: 'tablet',
            foodInstruction: 'After food',
          ),
        ],
      );

      await repository.saveMedicine(medicine);

      final loadedMedicine = await repository.getMedicine('med_1');

      expect(loadedMedicine, isNotNull);
      expect(loadedMedicine!.id, 'med_1');
      expect(loadedMedicine.name, 'Paracetamol');
      expect(loadedMedicine.description, 'Pain reliever');
      expect(loadedMedicine.type, 'Tablet');
      expect(loadedMedicine.strength, '500mg');
      expect(loadedMedicine.startDate, date);
      expect(loadedMedicine.endDate, isNull);
      expect(loadedMedicine.isActive, isTrue);
      expect(loadedMedicine.createdAt, date);
      expect(loadedMedicine.updatedAt, date);

      // Multiple doses test
      expect(loadedMedicine.doses.length, 3);
      expect(loadedMedicine.doses[0].time, '08:00');
      expect(loadedMedicine.doses[1].time, '14:00');
      expect(loadedMedicine.doses[2].time, '20:00');
    });
  });

  group('DoseOccurrence Persistence Test', () {
    test('Should save and load a DoseOccurrence entity correctly', () async {
      final dataSource = DoseOccurrenceLocalDataSource();
      final repository = DoseOccurrenceRepositoryImpl(dataSource);

      final scheduledDate = DateTime(2023, 1, 1, 8, 0);
      final actionDate = DateTime(2023, 1, 1, 8, 15);
      final createdDate = DateTime(2023, 1, 1, 7, 0);

      final occurrence = DoseOccurrence(
        id: 'occ_1',
        medicineId: 'med_1',
        doseId: 'dose_1',
        scheduledAt: scheduledDate,
        doseQuantity: 2.0,
        doseUnit: 'tablets',
        foodInstruction: 'Before food',
        status: DoseStatus.taken,
        actionAt: actionDate,
        snoozedUntil: null,
        createdAt: createdDate,
      );

      await repository.saveOccurrence(occurrence);

      final loadedOccurrence = await repository.getOccurrence('occ_1');

      expect(loadedOccurrence, isNotNull);
      expect(loadedOccurrence!.id, 'occ_1');
      expect(loadedOccurrence.medicineId, 'med_1');
      expect(loadedOccurrence.doseId, 'dose_1');
      expect(loadedOccurrence.scheduledAt, scheduledDate);
      expect(loadedOccurrence.doseQuantity, 2.0);
      expect(loadedOccurrence.doseUnit, 'tablets');
      expect(loadedOccurrence.foodInstruction, 'Before food');
      expect(loadedOccurrence.status, DoseStatus.taken);
      expect(loadedOccurrence.actionAt, actionDate);
      expect(loadedOccurrence.snoozedUntil, isNull);
      expect(loadedOccurrence.createdAt, createdDate);
    });

    test('Should persist and restore all DoseStatus enum values correctly',
        () async {
      final dataSource = DoseOccurrenceLocalDataSource();
      final repository = DoseOccurrenceRepositoryImpl(dataSource);
      final date = DateTime(2023, 1, 1);

      for (var i = 0; i < DoseStatus.values.length; i++) {
        final status = DoseStatus.values[i];
        final occ = DoseOccurrence(
          id: 'occ_$i',
          medicineId: 'm1',
          doseId: 'd1',
          scheduledAt: date,
          doseQuantity: 1,
          doseUnit: 'u',
          foodInstruction: '',
          status: status,
          createdAt: date,
        );

        await repository.saveOccurrence(occ);
        final loaded = await repository.getOccurrence('occ_$i');
        expect(loaded!.status, status);
      }
    });
  });

  group('Settings Persistence Test', () {
    test('Should save and load SettingsModel correctly', () async {
      final box = Hive.box<SettingsModel>(HiveBoxNames.settings);

      final settings = SettingsModel(
        notificationsOn: true,
        vibrationOn: false,
        defaultSnoozeMin: 10,
        sound: 'chime.mp3',
      );

      await box.put('user_settings', settings);

      final loadedSettings = box.get('user_settings');

      expect(loadedSettings, isNotNull);
      expect(loadedSettings!.notificationsOn, isTrue);
      expect(loadedSettings.vibrationOn, isFalse);
      expect(loadedSettings.defaultSnoozeMin, 10);
      expect(loadedSettings.sound, 'chime.mp3');
    });
  });

  group('Entity/Model Conversion Test', () {
    test('Medicine Model fromEntity and toEntity preserves values', () {
      final date = DateTime(2023, 1, 1);
      final medicine = Medicine(
        id: 'med_2',
        name: 'Ibuprofen',
        description: 'Pain relief',
        type: 'Capsule',
        strength: '200mg',
        startDate: date,
        endDate: null,
        doses: const [
          Dose(
              id: 'd1',
              time: '10:00',
              quantity: 1,
              unit: 'pill',
              foodInstruction: 'With food')
        ],
        isActive: false,
        createdAt: date,
        updatedAt: date,
      );

      final model = MedicineModel.fromEntity(medicine);
      final convertedEntity = model.toEntity();

      expect(convertedEntity.id, medicine.id);
      expect(convertedEntity.name, medicine.name);
      expect(convertedEntity.description, medicine.description);
      expect(convertedEntity.type, medicine.type);
      expect(convertedEntity.strength, medicine.strength);
      expect(convertedEntity.startDate, medicine.startDate);
      expect(convertedEntity.endDate, medicine.endDate);
      expect(convertedEntity.isActive, medicine.isActive);
      expect(convertedEntity.createdAt, medicine.createdAt);
      expect(convertedEntity.updatedAt, medicine.updatedAt);
      expect(convertedEntity.doses.length, medicine.doses.length);
      expect(convertedEntity.doses.first.id, medicine.doses.first.id);
    });

    test('DoseOccurrence Model fromEntity and toEntity preserves values', () {
      final date = DateTime(2023, 1, 1);
      final occurrence = DoseOccurrence(
        id: 'occ_2',
        medicineId: 'm2',
        doseId: 'd2',
        scheduledAt: date,
        doseQuantity: 3,
        doseUnit: 'drops',
        foodInstruction: 'None',
        status: DoseStatus.missed,
        actionAt: null,
        snoozedUntil: date,
        createdAt: date,
      );

      final model = DoseOccurrenceModel.fromEntity(occurrence);

      // Verify internal string storage
      expect(model.status, 'missed');

      final convertedEntity = model.toEntity();

      expect(convertedEntity.id, occurrence.id);
      expect(convertedEntity.medicineId, occurrence.medicineId);
      expect(convertedEntity.doseId, occurrence.doseId);
      expect(convertedEntity.scheduledAt, occurrence.scheduledAt);
      expect(convertedEntity.doseQuantity, occurrence.doseQuantity);
      expect(convertedEntity.doseUnit, occurrence.doseUnit);
      expect(convertedEntity.foodInstruction, occurrence.foodInstruction);
      expect(convertedEntity.status, occurrence.status);
      expect(convertedEntity.actionAt, occurrence.actionAt);
      expect(convertedEntity.snoozedUntil, occurrence.snoozedUntil);
      expect(convertedEntity.createdAt, occurrence.createdAt);
    });
  });
}
