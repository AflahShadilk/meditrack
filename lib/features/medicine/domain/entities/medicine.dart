import 'dose.dart';

class Medicine {
  final String id;
  final String name;
  final String description;
  final String type;
  final String strength;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Dose> doses;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medicine({
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
}
