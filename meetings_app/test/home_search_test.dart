import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/screens/home/home.dart';
import 'package:meetings_app/features/app/screens/search/search_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<EventRepository>(), MockSpec<NavigatorObserver>()])
import 'home_search_test.mocks.dart';

void main() {
  late MockEventRepository mockEventRepository;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockEventRepository = MockEventRepository();
    mockNavigatorObserver = MockNavigatorObserver();

    // Setup mock repository to return empty lists
    when(mockEventRepository.loadDummyEvents())
        .thenAnswer((_) async => <Event>[]);
  });

  testWidgets('HomeScreen search container navigates to search screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<EventRepository>.value(
          value: mockEventRepository,
          child: const HomeScreen(),
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );

    await tester.pumpAndSettle();

    // Find the search container
    expect(find.byType(LSearchContainer), findsOneWidget);
    expect(find.text('Buscar evento'), findsOneWidget);

    // Tap on the search container
    await tester.tap(find.byType(LSearchContainer));
    await tester.pumpAndSettle();

    // Verify navigation to SearchScreen
    verify(mockNavigatorObserver.didPush(any, any));

    // Check if we're on the search screen
    expect(find.byType(SearchScreen), findsOneWidget);

    // Search field should be focused automatically
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('HomeScreen search container is non-editable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<EventRepository>.value(
          value: mockEventRepository,
          child: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Try to enter text in the search field
    await tester.enterText(find.byType(LSearchContainer), 'test query');
    await tester.pump();

    // Verify that the text was not entered (should still show placeholder text)
    expect(find.text('test query'), findsNothing);
    expect(find.text('Buscar evento'), findsOneWidget);
  });
}
