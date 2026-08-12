import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_local_data_source.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDataSource _dataSource;

  MedicineRepositoryImpl(this._dataSource);

  @override
  Future<void> saveMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    await _dataSource.saveMedicine(model);
  }

  @override
  Future<Medicine?> getMedicine(String id) async {
    final model = await _dataSource.getMedicine(id);
    return model?.toEntity();
  }

  @override
  Future<List<Medicine>> getMedicines() async {
    final models = await _dataSource.getMedicines();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await _dataSource.deleteMedicine(id);
  }
}
