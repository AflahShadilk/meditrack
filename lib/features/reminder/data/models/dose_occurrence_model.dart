import 'package:hive/hive.dart';
import '../../domain/entities/dose_occurrence.dart';
import '../../domain/entities/dose_status.dart';

part 'dose_occurrence_model.g.dart';

@HiveType(typeId: 2)
class DoseOccurrenceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String medicineId;

  @HiveField(2)
  String doseId;

  @HiveField(3)
  DateTime scheduledAt;

  @HiveField(4)
  double doseQuantity;

  @HiveField(5)
  String doseUnit;

  @HiveField(6)
  String foodInstruction;

  @HiveField(7)
  String status;

  @HiveField(8)
  DateTime? actionAt;

  @HiveField(9)
  DateTime? snoozedUntil;

  @HiveField(10)
  DateTime createdAt;

  DoseOccurrenceModel({
    required this.id,
    required this.medicineId,
    required this.doseId,
    required this.scheduledAt,
    required this.doseQuantity,
    required this.doseUnit,
    required this.foodInstruction,
    required this.status,
    this.actionAt,
    this.snoozedUntil,
    required this.createdAt,
  });

  factory DoseOccurrenceModel.fromEntity(DoseOccurrence entity) {
    return DoseOccurrenceModel(
      id: entity.id,
      medicineId: entity.medicineId,
      doseId: entity.doseId,
      scheduledAt: entity.scheduledAt,
      doseQuantity: entity.doseQuantity,
      doseUnit: entity.doseUnit,
      foodInstruction: entity.foodInstruction,
      status: entity.status.name, // Convert enum to string
      actionAt: entity.actionAt,
      snoozedUntil: entity.snoozedUntil,
      createdAt: entity.createdAt,
    );
  }

  DoseOccurrence toEntity() {
    return DoseOccurrence(
      id: id,
      medicineId: medicineId,
      doseId: doseId,
      scheduledAt: scheduledAt,
      doseQuantity: doseQuantity,
      doseUnit: doseUnit,
      foodInstruction: foodInstruction,
      status: DoseStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => DoseStatus.pending,
      ), // Convert string to enum
      actionAt: actionAt,
      snoozedUntil: snoozedUntil,
      createdAt: createdAt,
    );
  }
}
