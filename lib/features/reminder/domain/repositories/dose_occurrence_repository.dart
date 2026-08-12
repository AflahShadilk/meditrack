import '../entities/dose_occurrence.dart';

abstract class DoseOccurrenceRepository {
  Future<void> saveOccurrence(DoseOccurrence occurrence);
  Future<DoseOccurrence?> getOccurrence(String id);
  Future<List<DoseOccurrence>> getOccurrences();
  Future<void> deleteOccurrence(String id);
}
