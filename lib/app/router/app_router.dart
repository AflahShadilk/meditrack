import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_section_title.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderHomePage(),
    ),
  ],
);

// This is just a placeholder to verify the foundation
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'MediTrack',
      body: ResponsiveLayout(
        mobile: _buildContent(context),
        tablet: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionTitle(title: 'Your medication companion'),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                Text(
                  '[ Foundation Ready ]',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Get Started',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
