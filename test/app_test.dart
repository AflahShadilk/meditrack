import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/app.dart';

void main() {
  testWidgets('App Foundation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the placeholder text is present
    expect(find.text('MediTrack'), findsOneWidget);
    expect(find.text('Module 02: App Foundation Ready'), findsOneWidget);
  });
}
