import 'dose_status.dart';

class DoseOccurrence {
  final String id;
  final String medicineId;
  final String doseId;
  final DateTime scheduledAt;

  final double doseQuantity;
  final String doseUnit;
  final String foodInstruction;

  final DoseStatus status;

  final DateTime? actionAt;
  final DateTime? snoozedUntil;
  final DateTime createdAt;

  const DoseOccurrence({
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
}
