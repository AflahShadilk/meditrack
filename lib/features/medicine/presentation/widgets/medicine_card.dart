import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPauseResume;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onPauseResume,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = medicine.isActive;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      '${medicine.strength} · ${medicine.type}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: isActive ? 'Active' : 'Paused',
                color: isActive ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
          if (medicine.doses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              children: medicine.doses
                  .map(
                    (dose) => Chip(
                      label: Text(
                        '${dose.time} · ${dose.quantity} ${dose.unit}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onPauseResume,
                icon: Icon(
                  isActive ? Icons.pause_outlined : Icons.play_arrow_outlined,
                  size: 16,
                ),
                label: Text(isActive ? 'Pause' : 'Resume'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
