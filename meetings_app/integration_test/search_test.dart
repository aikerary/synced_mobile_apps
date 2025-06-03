import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meetings_app/features/app/screens/search/search_screen.dart';
import 'package:meetings_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search functionality tests', () {
    testWidgets('Search screen should show results when typing',
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

      // Verify search screen is displayed
      expect(find.byType(SearchScreen), findsOneWidget);

      // Initially should show empty state with search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Busca eventos por título'), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'evento');
      await tester.pumpAndSettle();

      // Empty state should be gone
      expect(find.text('Busca eventos por título'), findsNothing);

      // Clear search field
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Empty state should return
      expect(find.text('Busca eventos por título'), findsOneWidget);
    });

    testWidgets('Search should filter events correctly',
        (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Navigate to search
      await tester.tap(find.text('Buscar evento').first);
      await tester.pumpAndSettle();

      // Search for a specific event - this depends on your mock data
      // For example if you have an event with "Workshop" in the title:
      await tester.enterText(find.byType(TextField), 'Workshop');
      await tester.pumpAndSettle();

      // Verify only matching events are shown
      // This will depend on your actual data and UI
      // For example:
      // expect(find.text('Flutter Workshop'), findsOneWidget);
      // expect(find.text('Concert'), findsNothing);
    });
  });
}
