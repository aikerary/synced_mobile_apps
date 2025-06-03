import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meetings_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Subscriptions functionality tests', () {
    testWidgets('Should toggle between upcoming and past events',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Navigate to Subscriptions tab (assuming it's in the bottom navigation)
      // You might need to adjust this based on your actual navigation structure
      await tester.tap(find.text('Suscripciones'));
      await tester.pumpAndSettle();

      // Verify the selector is present
      expect(find.text('Proximos'), findsOneWidget);
      expect(find.text('Pasados'), findsOneWidget);

      // Initially "Upcoming" should be selected
      // Tap on "Past" tab
      await tester.tap(find.text('Pasados'));
      await tester.pumpAndSettle();

      // Tap back to "Upcoming" tab
      await tester.tap(find.text('Proximos'));
      await tester.pumpAndSettle();
    });

    testWidgets('Should display subscription event cards',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Navigate to Subscriptions tab
      await tester.tap(find.text('Suscripciones'));
      await tester.pumpAndSettle();

      // Verify subscription cards are present
      // This depends on your dummy data - adjust accordingly
      expect(find.text('Suscrito'), findsWidgets);
    });
  });
}
