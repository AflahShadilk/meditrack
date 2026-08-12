import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/dose.dart';
import '../../domain/entities/medicine.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../widgets/dose_form_card.dart';

class AddEditMedicinePage extends StatefulWidget {
  final Medicine? existingMedicine;

  const AddEditMedicinePage({super.key, this.existingMedicine});

  bool get isEditing => existingMedicine != null;

  @override
  State<AddEditMedicinePage> createState() => _AddEditMedicinePageState();
}

class _AddEditMedicinePageState extends State<AddEditMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _strengthController;

  String _selectedType = 'Tablet';
  DateTime? _startDate;
  DateTime? _endDate;
  late List<Dose> _doses;

  static const List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Cream',
    'Inhaler',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.existingMedicine;
    _nameController = TextEditingController(text: m?.name ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
    _strengthController = TextEditingController(text: m?.strength ?? '');
    _selectedType = m?.type ?? 'Tablet';
    _startDate = m?.startDate;
    _endDate = m?.endDate;
    _doses = m != null ? List.of(m.doses) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  void _addDose() {
    setState(() {
      _doses.add(Dose(
        id: _generateId(),
        time: '08:00',
        quantity: 1.0,
        unit: 'Tablet',
        foodInstruction: 'After food',
      ));
    });
  }

  void _removeDose(int index) {
    setState(() => _doses.removeAt(index));
  }

  void _updateDose(int index, Dose updated) {
    setState(() => _doses[index] = updated);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's now before start date.
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date.')),
      );
      return;
    }

    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('End date must be on or after start date.')),
      );
      return;
    }

    if (_doses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one dose.')),
      );
      return;
    }

    final now = DateTime.now();
    final medicine = Medicine(
      id: widget.existingMedicine?.id ?? _generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      strength: _strengthController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate,
      doses: _doses,
      isActive: widget.existingMedicine?.isActive ?? true,
      createdAt: widget.existingMedicine?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.isEditing) {
      context.read<MedicineBloc>().add(UpdateMedicine(medicine));
    } else {
      context.read<MedicineBloc>().add(AddMedicine(medicine));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicineBloc, MedicineState>(
      listener: (context, state) {
        if (state is MedicineOperationSuccess) {
          Navigator.of(context).pop();
        } else if (state is MedicineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AppScaffold(
        title: widget.isEditing ? 'Edit Medicine' : 'Add Medicine',
        body: ResponsiveLayout(
          mobile: _buildForm(context),
          tablet: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Medicine Name',
            hint: 'e.g. Paracetamol',
            prefixIcon: const Icon(Icons.medication),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
          ),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'e.g. Pain reliever',
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _medicineTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v ?? 'Tablet'),
          ),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            controller: _strengthController,
            label: 'Strength',
            hint: 'e.g. 500mg',
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Strength is required.'
                : null,
          ),
          const SizedBox(height: AppSpacing.medium),
          // Date pickers
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _DateButton(
                  label: 'End Date (optional)',
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                  onClear: _endDate != null
                      ? () => setState(() => _endDate = null)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          // Doses section
          Row(
            children: [
              Text('Doses', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _addDose,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Dose'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          if (_doses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.medium),
              child: Text(
                'No doses added. Tap "Add Dose" to continue.',
                textAlign: TextAlign.center,
              ),
            ),
          ..._doses.asMap().entries.map((entry) {
            final index = entry.key;
            final dose = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: DoseFormCard(
                key: ValueKey(dose.id),
                dose: dose,
                onChanged: (updated) => _updateDose(index, updated),
                onRemove: () => _removeDose(index),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.large),
          BlocBuilder<MedicineBloc, MedicineState>(
            builder: (context, state) => AppButton(
              text: widget.isEditing ? 'Save Changes' : 'Add Medicine',
              isLoading: state is MedicineLoading,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16),
          const SizedBox(width: AppSpacing.xSmall),
          Expanded(
            child: Text(
              date != null
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }
}
