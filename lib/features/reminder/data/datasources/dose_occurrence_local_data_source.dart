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

  Future<DoseOccurrenceModel?> getOccurrence(String id) async {
    return _box.get(id);
  }

  Future<List<DoseOccurrenceModel>> getOccurrences() async {
    return _box.values.toList();
  }

  Future<void> deleteOccurrence(String id) async {
    await _box.delete(id);
  }
}
