import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/dose_occurrence_model.dart';

class DoseOccurrenceLocalDataSource {
  final Box<DoseOccurrenceModel> _box;

  DoseOccurrenceLocalDataSource()
      : _box = Hive.box<DoseOccurrenceModel>(HiveBoxNames.occurrences);

  Future<void> saveOccurrence(DoseOccurrenceModel occurrence) async {
    await _box.put(occurrence.id, occurrence);
  }

  Future<void> saveOccurrences(List<DoseOccurrenceModel> occurrences) async {
    final Map<String, DoseOccurrenceModel> entries = {
      for (var occ in occurrences) occ.id: occ,
    };
    await _box.putAll(entries);
  }

  Future<DoseOccurrenceModel?> getOccurrence(String id) async {
    return _box.get(id);
  }

  Future<List<DoseOccurrenceModel>> getOccurrences() async {
    return _box.values.toList();
  }

  Future<List<DoseOccurrenceModel>> getOccurrencesByMedicine(
      String medicineId) async {
    return _box.values.where((occ) => occ.medicineId == medicineId).toList();
  }

  Future<void> deleteOccurrence(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteOccurrencesByMedicine(String medicineId) async {
    final keysToDelete = _box.values
        .where((occ) => occ.medicineId == medicineId)
        .map((occ) => occ.id)
        .toList();
    await _box.deleteAll(keysToDelete);
  }

  Future<void> deleteFutureOccurrencesByMedicine(
      String medicineId, DateTime fromDate) async {
    final keysToDelete = _box.values
        .where((occ) =>
            occ.medicineId == medicineId && occ.scheduledAt.isAfter(fromDate) ||
            (occ.medicineId == medicineId &&
                occ.scheduledAt.isAtSameMomentAs(fromDate)))
        .map((occ) => occ.id)
        .toList();
    await _box.deleteAll(keysToDelete);
  }
}
