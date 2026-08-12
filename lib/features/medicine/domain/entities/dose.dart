class Dose {
  final String id;
  final String time;
  final double quantity;
  final String unit;
  final String foodInstruction;

  const Dose({
    required this.id,
    required this.time,
    required this.quantity,
    required this.unit,
    required this.foodInstruction,
  });
}
