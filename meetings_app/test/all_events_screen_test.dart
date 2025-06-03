import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/repository/track_repository.dart';
import 'package:meetings_app/features/app/screens/all_events/all_events.dart';
import 'package:meetings_app/features/app/screens/all_events/widgets/filter.dart';
import 'package:meetings_app/common/widgets/events/cards/stylish_event_card.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<EventRepository>(), MockSpec<TrackRepository>()])
import 'all_events_screen_test.mocks.dart';

void main() {
  late MockEventRepository mockEventRepository;
  late MockTrackRepository mockTrackRepository;
  final DateTime now = DateTime.now();

  setUp(() {
    mockEventRepository = MockEventRepository();
    mockTrackRepository = MockTrackRepository();

    // Setup test events with different dates
    final List<Event> testEvents = [
      // Future events
      Event(
        id: 1,
        titulo: "Next Week Event",
        descripcion: "An event next week",
        tema: "Tech",
        ponenteId: 1,
        fecha: now.add(const Duration(days: 5)),
        horaInicio: "10:00",
        horaFin: "11:00",
        maxParticipantes: 100,
        suscritos: 50,
        imageUrl: "assets/images/event.jpg",
      ),
      Event(
        id: 2,
        titulo: "This Month Event",
        descripcion: "An event this month",
        tema: "IA",
        ponenteId: 2,
        fecha: now.add(Duration(
            days: 15, hours: now.hour > 0 ? 0 : 1)), // Ensure it's this month
        horaInicio: "14:00",
        horaFin: "15:00",
        maxParticipantes: 80,
        suscritos: 40,
        imageUrl: "assets/images/event.jpg",
      ),
      Event(
        id: 3,
        titulo: "Next Month Event",
        descripcion: "An event next month",
        tema: "Exito",
        ponenteId: 3,
        fecha: DateTime(now.year, now.month + 1, 15), // Next month
        horaInicio: "11:00",
        horaFin: "12:30",
        maxParticipantes: 120,
        suscritos: 70,
        imageUrl: "assets/images/event.jpg",
      ),
      // Past event
      Event(
        id: 4,
        titulo: "Past Event",
        descripcion: "A past event",
        tema: "Negocios",
        ponenteId: 4,
        fecha: now.subtract(const Duration(days: 5)),
        horaInicio: "15:00",
        horaFin: "16:30",
        maxParticipantes: 90,
        suscritos: 85,
        imageUrl: "assets/images/event.jpg",
      ),
    ];

    // Mock track data
    final List<Track> testTracks = [
      Track(nombre: "Tech"),
      Track(nombre: "IA"),
      Track(nombre: "Exito"),
      Track(nombre: "Negocios"),
    ];

    when(mockEventRepository.loadDummyEvents())
        .thenAnswer((_) async => testEvents);
    when(mockTrackRepository.loadDummyTracks())
        .thenAnswer((_) async => testTracks);
  });

  testWidgets('AllEventsScreen shows all future events by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EventRepository>.value(value: mockEventRepository),
            Provider<TrackRepository>.value(value: mockTrackRepository),
          ],
          child: const AllEventsScreen(),
        ),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Check filter chips are shown
    expect(find.byType(FilterChipsRow), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);

    // Check future events are shown
    expect(find.text('Next Week Event'), findsOneWidget);
    expect(find.text('This Month Event'), findsOneWidget);
    expect(find.text('Next Month Event'), findsOneWidget);

    // Past event should not be visible by default
    expect(find.text('Past Event'), findsNothing);

    // Check event count text
    expect(find.text('3 events found'), findsOneWidget);
  });

  testWidgets('AllEventsScreen filters by This Week',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EventRepository>.value(value: mockEventRepository),
            Provider<TrackRepository>.value(value: mockTrackRepository),
          ],
          child: const AllEventsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on "Esta semana" filter
    await tester.tap(find.text('Esta semana'));
    await tester.pumpAndSettle();

    // Only next week event should be visible
    expect(find.text('Next Week Event'), findsOneWidget);
    expect(find.text('This Month Event'), findsNothing);
    expect(find.text('Next Month Event'), findsNothing);

    // Check event count updated
    expect(find.text('1 events found'), findsOneWidget);
  });

  testWidgets('AllEventsScreen filters by Past events',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EventRepository>.value(value: mockEventRepository),
            Provider<TrackRepository>.value(value: mockTrackRepository),
          ],
          child: const AllEventsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on "Pasados" filter
    await tester.tap(find.text('Pasados'));
    await tester.pumpAndSettle();

    // Only past event should be visible
    expect(find.text('Past Event'), findsOneWidget);
    expect(find.text('Next Week Event'), findsNothing);
    expect(find.text('This Month Event'), findsNothing);
    expect(find.text('Next Month Event'), findsNothing);

    // Check event count updated
    expect(find.text('1 events found'), findsOneWidget);
  });

  testWidgets('AllEventsScreen can filter by track',
      (WidgetTester tester) async {
    // Create AllEventsScreen with specific track filter
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EventRepository>.value(value: mockEventRepository),
            Provider<TrackRepository>.value(value: mockTrackRepository),
          ],
          child: const AllEventsScreen(trackName: "IA"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should only show events with "IA" track
    expect(find.text('This Month Event'), findsOneWidget);
    expect(find.text('Next Week Event'), findsNothing);
    expect(find.text('Next Month Event'), findsNothing);
    expect(find.text('Past Event'), findsNothing);

    // Check event count
    expect(find.text('1 events found'), findsOneWidget);
  });

  testWidgets('AllEventsScreen shows empty state when no events match filter',
      (WidgetTester tester) async {
    // Create AllEventsScreen with non-existent track
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EventRepository>.value(value: mockEventRepository),
            Provider<TrackRepository>.value(value: mockTrackRepository),
          ],
          child: const AllEventsScreen(trackName: "NonExistent"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should show no events message
    expect(find.text("No events found"), findsOneWidget);

    // No event cards should be visible
    expect(find.byType(StylishEventCard), findsNothing);
  });
}
