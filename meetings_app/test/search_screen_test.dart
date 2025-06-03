import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/screens/search/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'search_screen_test.mocks.dart';

void main() {
  late MockEventRepository mockEventRepository;

  setUp(() {
    mockEventRepository = MockEventRepository();

    // Mock the repository to return test events
    when(mockEventRepository.loadDummyEvents()).thenAnswer((_) async => [
          Event(
            id: 1,
            titulo: "Test Event 1",
            descripcion: "Test Description 1",
            tema: "IA",
            ponenteId: 1,
            fecha: DateTime(2025, 4, 10),
            horaInicio: "10:00",
            horaFin: "11:30",
            maxParticipantes: 100,
            suscritos: 40,
            imageUrl: "assets/images/event.jpg",
            speakers: [],
            trackNames: ["AI", "Tech"],
          ),
          Event(
            id: 2,
            titulo: "Flutter Workshop",
            descripcion: "Learning Flutter",
            tema: "Tech",
            ponenteId: 2,
            fecha: DateTime(2025, 5, 15),
            horaInicio: "14:00",
            horaFin: "16:00",
            maxParticipantes: 50,
            suscritos: 25,
            imageUrl: "assets/images/event.jpg",
            speakers: [],
            trackNames: ["Flutter", "Development"],
          ),
        ]);
  });

  testWidgets('SearchScreen shows empty state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<EventRepository>.value(
          value: mockEventRepository,
          child: const SearchScreen(),
        ),
      ),
    );

    // Verify search field is displayed and focused
    expect(find.byType(TextField), findsOneWidget);

    // Should show search icon in empty state
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Should show hint text
    expect(find.text('Busca eventos por título'), findsOneWidget);
  });

  testWidgets('SearchScreen shows results when typing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<EventRepository>.value(
          value: mockEventRepository,
          child: const SearchScreen(),
        ),
      ),
    );

    // Load events and rebuild
    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pumpAndSettle();

    // Should show the matching event
    expect(find.text('Test Event 1'), findsOneWidget);

    // Clear button should appear
    expect(find.byIcon(Icons.clear), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // Should return to empty state
    expect(find.text('Busca eventos por título'), findsOneWidget);
  });

  testWidgets('SearchScreen shows no results message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<EventRepository>.value(
          value: mockEventRepository,
          child: const SearchScreen(),
        ),
      ),
    );

    // Enter search text that won't match any event
    await tester.enterText(find.byType(TextField), 'nonexistent');
    await tester.pumpAndSettle();

    // Should show no results message
    expect(find.text('No hay resultados'), findsOneWidget);
  });
}
