import 'package:hive/hive.dart';
import '../../domain/entities/medicine.dart';
import 'dose_model.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String type;

  @HiveField(4)
  String strength;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime? endDate;

  @HiveField(7)
  List<DoseModel> doses;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  MedicineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.strength,
    required this.startDate,
    this.endDate,
    required this.doses,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineModel.fromEntity(Medicine entity) {
    return MedicineModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      strength: entity.strength,
      startDate: entity.startDate,
      endDate: entity.endDate,
      doses: entity.doses.map((d) => DoseModel.fromEntity(d)).toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Medicine toEntity() {
    return Medicine(
      id: id,
      name: name,
      description: description,
      type: type,
      strength: strength,
      startDate: startDate,
      endDate: endDate,
      doses: doses.map((d) => d.toEntity()).toList(),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
