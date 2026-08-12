import 'package:hive/hive.dart';
import '../../domain/entities/dose.dart';

part 'dose_model.g.dart';

@HiveType(typeId: 1)
class DoseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String time;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit;

  @HiveField(4)
  String foodInstruction;

  DoseModel({
    required this.id,
    required this.time,
    required this.quantity,
    required this.unit,
    required this.foodInstruction,
  });

  factory DoseModel.fromEntity(Dose entity) {
    return DoseModel(
      id: entity.id,
      time: entity.time,
      quantity: entity.quantity,
      unit: entity.unit,
      foodInstruction: entity.foodInstruction,
    );
  }

  Dose toEntity() {
    return Dose(
      id: id,
      time: time,
      quantity: quantity,
      unit: unit,
      foodInstruction: foodInstruction,
    );
  }
}
