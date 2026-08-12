import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_section_title.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_chip.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Design System Preview',
      body: ResponsiveLayout(
        mobile: _buildContent(context),
        tablet: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionTitle(title: 'Brand Colors'),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              _ColorBox(color: AppColors.primary, label: 'Primary'),
              _ColorBox(color: AppColors.success, label: 'Success'),
              _ColorBox(color: AppColors.warning, label: 'Warning'),
              _ColorBox(color: AppColors.error, label: 'Error'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Typography'),
          const SizedBox(height: AppSpacing.medium),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large',
                    style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: AppSpacing.small),
                Text('Headline Large',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.small),
                Text('Headline Medium',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.small),
                Text('Title Large',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.small),
                Text('Title Medium',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                Text('Body Large',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.small),
                Text('Body Medium',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.small),
                Text('Body Small',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.small),
                Text('Label Large',
                    style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Buttons'),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.medium,
            children: [
              AppButton(text: 'Primary Action', onPressed: () {}),
              AppButton(text: 'With Icon', icon: Icons.add, onPressed: () {}),
              const AppButton(text: 'Loading', isLoading: true),
              const AppButton(text: 'Disabled'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Text Field'),
          const SizedBox(height: AppSpacing.medium),
          const AppTextField(
            label: 'Medicine Name',
            hint: 'e.g., Paracetamol',
            prefixIcon: Icon(Icons.medication),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Card'),
          const SizedBox(height: AppSpacing.medium),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medicine Example',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: AppSpacing.small),
                Text('500 mg • 1 Tablet'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Statuses'),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            children: [
              StatusChip(label: 'Pending', color: AppColors.warning),
              StatusChip(label: 'Taken', color: AppColors.success),
              StatusChip(label: 'Missed', color: AppColors.error),
              StatusChip(label: 'Skipped', color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Empty State'),
          const SizedBox(height: AppSpacing.medium),
          AppCard(
            child: EmptyState(
              icon: Icons.medication_liquid,
              title: 'No medicines added yet.',
              message: 'Tap the button below to add your first medicine.',
              action: AppButton(text: 'Add Medicine', onPressed: () {}),
            ),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Loading View'),
          const SizedBox(height: AppSpacing.medium),
          const AppCard(
            child: SizedBox(
              height: 100,
              child: LoadingView(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          const AppSectionTitle(title: 'Error View'),
          const SizedBox(height: AppSpacing.medium),
          AppCard(
            child: SizedBox(
              height: 150,
              child: ErrorView(
                message: 'Unable to load your medicines.',
                onRetry: () {},
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
        ],
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
