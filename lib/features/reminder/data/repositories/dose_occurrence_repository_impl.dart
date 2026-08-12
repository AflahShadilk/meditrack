import '../../domain/entities/dose_occurrence.dart';
import '../../domain/repositories/dose_occurrence_repository.dart';
import '../datasources/dose_occurrence_local_data_source.dart';
import '../models/dose_occurrence_model.dart';

class DoseOccurrenceRepositoryImpl implements DoseOccurrenceRepository {
  final DoseOccurrenceLocalDataSource _dataSource;

  DoseOccurrenceRepositoryImpl(this._dataSource);

  @override
  Future<void> saveOccurrence(DoseOccurrence occurrence) async {
    final model = DoseOccurrenceModel.fromEntity(occurrence);
    await _dataSource.saveOccurrence(model);
  }

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {
    final models =
        occurrences.map((o) => DoseOccurrenceModel.fromEntity(o)).toList();
    await _dataSource.saveOccurrences(models);
  }

  @override
  Future<DoseOccurrence?> getOccurrence(String id) async {
    final model = await _dataSource.getOccurrence(id);
    return model?.toEntity();
  }

  @override
  Future<List<DoseOccurrence>> getOccurrences() async {
    final models = await _dataSource.getOccurrences();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DoseOccurrence>> getOccurrencesByMedicine(
      String medicineId) async {
    final models = await _dataSource.getOccurrencesByMedicine(medicineId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteOccurrence(String id) async {
    await _dataSource.deleteOccurrence(id);
  }

  @override
  Future<void> deleteOccurrencesByMedicine(String medicineId) async {
    await _dataSource.deleteOccurrencesByMedicine(medicineId);
  }

  @override
  Future<void> deleteFutureOccurrencesByMedicine(
      String medicineId, DateTime fromDate) async {
    await _dataSource.deleteFutureOccurrencesByMedicine(medicineId, fromDate);
  }
}
