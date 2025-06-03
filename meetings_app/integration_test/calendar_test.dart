import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meetings_app/features/app/screens/calendar/calendar.dart';
import 'package:meetings_app/main.dart' as app;
import 'package:table_calendar/table_calendar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar functionality tests', () {
    testWidgets('Calendar should display and allow date selection',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Navigate to Calendar screen
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Verify calendar is displayed
      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.text('Calendario'), findsOneWidget);

      // Find today's date cell and tap it
      // This is a simplification - in a real test you might need to find the specific day
      final today = DateTime.now().day.toString();
      await tester.tap(find.text(today).first);
      await tester.pumpAndSettle();

      // Navigate to next month using the right chevron
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Navigate back using the left chevron
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
    });
  });
}
