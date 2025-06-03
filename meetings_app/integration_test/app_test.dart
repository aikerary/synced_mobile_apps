import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meetings_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app tests', () {
    testWidgets('Complete onboarding and navigate to main screen',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the onboarding screen
      expect(find.text('Comenzar'), findsOneWidget);

      // Tap on "Comenzar" to complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Verify we're on the home screen (check for common home screen elements)
      expect(find.text('Próximos Eventos'), findsOneWidget);
      expect(find.text('Categorías'), findsOneWidget);
    });

    testWidgets('Navigate to Calendar screen', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Find and tap on Calendar tab (assuming bottom navigation)
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Verify we're on the Calendar screen
      expect(find.text('Calendario'), findsOneWidget);
    });

    testWidgets('Navigate to Search screen and perform search',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Find and tap on the search container
      await tester.tap(find.text('Buscar evento').first);
      await tester.pumpAndSettle();

      // Verify we're on the search screen
      expect(find.byType(TextField), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'evento');
      await tester.pumpAndSettle();

      // Verify search results appear (would depend on your dummy data)
      // This is a simplified assertion - adjust based on your actual UI
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
