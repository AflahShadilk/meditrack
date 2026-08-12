import '../../../../features/reminder/domain/entities/dose_occurrence.dart';
import '../../../../features/reminder/domain/entities/dose_status.dart';
import '../../../../features/reminder/domain/repositories/dose_occurrence_repository.dart';
import '../entities/medicine.dart';

class GenerateOccurrencesUseCase {
  final DoseOccurrenceRepository _repository;

  GenerateOccurrencesUseCase(this._repository);

  Future<List<DoseOccurrence>> call(Medicine medicine) async {
    if (medicine.doses.isEmpty) {
      return [];
    }

    final today = DateTime.now();
    final rollingWindowStart = DateTime(today.year, today.month, today.day);
    final medStart = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
    );

    DateTime generationStart;
    DateTime generationEnd;

    if (medicine.endDate != null) {
      final medEnd = DateTime(
        medicine.endDate!.year,
        medicine.endDate!.month,
        medicine.endDate!.day,
      );
      if (medStart.isAfter(medEnd)) {
        return [];
      }
      generationStart = medStart;
      generationEnd = medEnd;
    } else {
      generationStart =
          medStart.isAfter(rollingWindowStart) ? medStart : rollingWindowStart;
      generationEnd = rollingWindowStart.add(const Duration(days: 14));
    }

    // Fetch existing occurrences for this medicine to prevent duplicates
    final existingOccurrences =
        await _repository.getOccurrencesByMedicine(medicine.id);
    final existingIds = existingOccurrences.map((o) => o.id).toSet();

    final List<DoseOccurrence> newOccurrences = [];
    DateTime current = generationStart;

    while (!current.isAfter(generationEnd)) {
      for (final dose in medicine.doses) {
        final timeParts = dose.time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final scheduledAt = DateTime(
          current.year,
          current.month,
          current.day,
          hour,
          minute,
        );

        final id = '${medicine.id}_${dose.id}_${scheduledAt.toIso8601String()}';

        if (!existingIds.contains(id)) {
          newOccurrences.add(
            DoseOccurrence(
              id: id,
              medicineId: medicine.id,
              doseId: dose.id,
              scheduledAt: scheduledAt,
              doseQuantity: dose.quantity,
              doseUnit: dose.unit,
              foodInstruction: dose.foodInstruction,
              status: DoseStatus.pending,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
      current = DateTime(current.year, current.month, current.day + 1);
    }

    if (newOccurrences.isNotEmpty) {
      await _repository.saveOccurrences(newOccurrences);
    }

    return newOccurrences;
  }
}
