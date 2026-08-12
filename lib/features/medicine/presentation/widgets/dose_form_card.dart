import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/dose.dart';

class DoseFormCard extends StatefulWidget {
  final Dose dose;
  final ValueChanged<Dose> onChanged;
  final VoidCallback onRemove;

  const DoseFormCard({
    super.key,
    required this.dose,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<DoseFormCard> createState() => _DoseFormCardState();
}

class _DoseFormCardState extends State<DoseFormCard> {
  late TextEditingController _timeController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _foodController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.dose.time);
    _quantityController =
        TextEditingController(text: widget.dose.quantity.toString());
    _unitController = TextEditingController(text: widget.dose.unit);
    _foodController = TextEditingController(text: widget.dose.foodInstruction);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      Dose(
        id: widget.dose.id,
        time: _timeController.text.trim(),
        quantity: double.tryParse(_quantityController.text.trim()) ?? 1.0,
        unit: _unitController.text.trim(),
        foodInstruction: _foodController.text.trim(),
      ),
    );
  }

  Future<void> _pickTime() async {
    final parts = _timeController.text.split(':');
    final initialTime = (parts.length == 2)
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _timeController.text = formatted;
      _notifyChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dose',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.error,
                tooltip: 'Remove dose',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          // Time picker row
          GestureDetector(
            onTap: _pickTime,
            child: AbsorbPointer(
              child: AppTextField(
                controller: _timeController,
                label: 'Time',
                hint: 'e.g. 08:00',
                prefixIcon: const Icon(Icons.access_time),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: 'e.g. 1',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _notifyChange(),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: AppTextField(
                  controller: _unitController,
                  label: 'Unit',
                  hint: 'e.g. Tablet',
                  onChanged: (_) => _notifyChange(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          AppTextField(
            controller: _foodController,
            label: 'Food Instruction',
            hint: 'e.g. After food',
            onChanged: (_) => _notifyChange(),
          ),
        ],
      ),
    );
  }
}
