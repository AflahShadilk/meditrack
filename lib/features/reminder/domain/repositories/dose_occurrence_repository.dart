import '../entities/dose_occurrence.dart';

abstract class DoseOccurrenceRepository {
  Future<void> saveOccurrence(DoseOccurrence occurrence);
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences);
  Future<DoseOccurrence?> getOccurrence(String id);
  Future<List<DoseOccurrence>> getOccurrences();
  Future<List<DoseOccurrence>> getOccurrencesByMedicine(String medicineId);
  Future<void> deleteOccurrence(String id);
  Future<void> deleteOccurrencesByMedicine(String medicineId);
  Future<void> deleteFutureOccurrencesByMedicine(
      String medicineId, DateTime fromDate);
}
