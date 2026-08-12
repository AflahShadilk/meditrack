import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/constants/app_colors.dart';
import 'package:meditrack/core/widgets/app_button.dart';
import 'package:meditrack/core/widgets/app_card.dart';
import 'package:meditrack/core/widgets/app_text_field.dart';
import 'package:meditrack/core/widgets/empty_state.dart';
import 'package:meditrack/core/widgets/error_view.dart';
import 'package:meditrack/core/widgets/status_chip.dart';
import 'package:meditrack/core/widgets/loading_view.dart';
import 'package:meditrack/core/responsive/responsive_layout.dart';
import 'package:meditrack/core/theme/app_theme.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('Design System Widgets', () {
    testWidgets('AppButton renders and handles taps',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestApp(
        AppButton(text: 'Click Me', onPressed: () => tapped = true),
      ));

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('AppTextField accepts input', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestApp(
        AppTextField(label: 'Name', controller: controller),
      ));

      expect(find.text('Name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Paracetamol');
      expect(controller.text, 'Paracetamol');
    });

    testWidgets('AppCard renders child', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const AppCard(child: Text('Card Content')),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('StatusChip renders label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusChip(label: 'Pending', color: AppColors.warning),
      ));

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('EmptyState renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const EmptyState(
            title: 'No Data', message: 'It is empty here.', icon: Icons.inbox),
      ));

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('It is empty here.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('ErrorView renders and handles retry',
        (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(buildTestApp(
        ErrorView(message: 'Error occurred', onRetry: () => retried = true),
      ));

      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('LoadingView renders', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const LoadingView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ResponsiveLayout', () {
    testWidgets('Shows mobile view on small screens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(
        const ResponsiveLayout(
          mobile: Text('Mobile View'),
          tablet: Text('Tablet View'),
        ),
      ));

      expect(find.text('Mobile View'), findsOneWidget);
      expect(find.text('Tablet View'), findsNothing);
    });

    testWidgets('Shows tablet view on wider screens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(
        const ResponsiveLayout(
          mobile: Text('Mobile View'),
          tablet: Text('Tablet View'),
        ),
      ));

      expect(find.text('Tablet View'), findsOneWidget);
      expect(find.text('Mobile View'), findsNothing);
    });
  });
}
