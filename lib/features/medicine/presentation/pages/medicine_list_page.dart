import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/medicine.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../widgets/medicine_card.dart';
import 'add_edit_medicine_page.dart';

class MedicineListPage extends StatelessWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Medicines',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_medicine_fab',
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
      body: BlocListener<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is MedicineOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<MedicineBloc, MedicineState>(
          builder: (context, state) {
            if (state is MedicineInitial) {
              context.read<MedicineBloc>().add(const LoadMedicines());
              return const LoadingView();
            }
            if (state is MedicineLoading) return const LoadingView();
            if (state is MedicineError) {
              return ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<MedicineBloc>().add(const LoadMedicines()),
              );
            }
            if (state is MedicineLoaded) {
              if (state.medicines.isEmpty) {
                return const EmptyState(
                  icon: Icons.medication_outlined,
                  title: 'No medicines yet',
                  message: 'Tap the button below to add your first medicine.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.medium),
                itemCount: state.medicines.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.medium),
                itemBuilder: (context, index) {
                  final medicine = state.medicines[index];
                  return MedicineCard(
                    medicine: medicine,
                    onEdit: () => _navigateToEdit(context, medicine),
                    onDelete: () => _confirmDelete(context, medicine),
                    onPauseResume: () => _togglePauseResume(context, medicine),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<MedicineBloc>(),
        child: const AddEditMedicinePage(),
      ),
    ));
  }

  void _navigateToEdit(BuildContext context, Medicine medicine) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<MedicineBloc>(),
        child: AddEditMedicinePage(existingMedicine: medicine),
      ),
    ));
  }

  void _confirmDelete(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: Text(
          'This will remove "${medicine.name}" and all its scheduled doses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MedicineBloc>().add(DeleteMedicine(medicine.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _togglePauseResume(BuildContext context, Medicine medicine) {
    if (medicine.isActive) {
      context.read<MedicineBloc>().add(PauseMedicine(medicine));
    } else {
      context.read<MedicineBloc>().add(ResumeMedicine(medicine));
    }
  }
}
