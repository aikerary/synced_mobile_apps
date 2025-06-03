import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/subscriptions/subscriptions.dart';
import 'package:meetings_app/features/app/screens/subscriptions/widgets/selector.dart';
import 'package:meetings_app/features/app/screens/subscriptions/widgets/subscription_event_card.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<EventController>()])
import 'subscriptions_screen_test.mocks.dart';

void main() {
  late MockEventController mockEventController;

  setUp(() {
    mockEventController = MockEventController();

    // Setup upcoming events
    final upcomingEvents = [
      Event(
        id: 1,
        titulo: "Upcoming Event 1",
        descripcion: "Test Description 1",
        tema: "IA",
        ponenteId: 1,
        fecha: DateTime.now().add(const Duration(days: 10)),
        horaInicio: "10:00",
        horaFin: "11:30",
        maxParticipantes: 100,
        suscritos: 40,
        imageUrl: "assets/images/event.jpg",
        speakers: [],
        trackNames: ["AI"],
      ),
    ];

    // Setup past events
    final pastEvents = [
      Event(
        id: 2,
        titulo: "Past Event 1",
        descripcion: "Past Description",
        tema: "Tech",
        ponenteId: 2,
        fecha: DateTime.now().subtract(const Duration(days: 10)),
        horaInicio: "14:00",
        horaFin: "15:30",
        maxParticipantes: 80,
        suscritos: 60,
        imageUrl: "assets/images/event.jpg",
        speakers: [],
        trackNames: ["Tech"],
      ),
    ];

    // Mock controller methods
    when(mockEventController.loadEvents()).thenAnswer((_) async {});
    when(mockEventController.getUpcomingSubscribedEvents())
        .thenReturn(upcomingEvents);
    when(mockEventController.getPastSubscribedEvents()).thenReturn(pastEvents);
  });

  testWidgets('SubscriptionsScreen shows upcoming events by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EventController>.value(
          value: mockEventController,
          child: const SubscriptionsScreen(),
        ),
      ),
    );

    // Allow async operations to complete
    await tester.pumpAndSettle();

    // Verify EventSubscriptionsSelector is displayed
    expect(find.byType(EventSubscriptionsSelector), findsOneWidget);

    // Verify the upcoming tab is selected by default
    expect(find.text('Próximos'), findsOneWidget);
    expect(find.text('Pasados'), findsOneWidget);

    // Verify upcoming event is displayed
    expect(find.text('Upcoming Event 1'), findsOneWidget);
    expect(find.byType(SubscriptionEventCard), findsOneWidget);

    // Past event should not be visible
    expect(find.text('Past Event 1'), findsNothing);
  });

  testWidgets('SubscriptionsScreen switches to past events',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EventController>.value(
          value: mockEventController,
          child: const SubscriptionsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the "Pasados" tab
    await tester.tap(find.text('Pasados'));
    await tester.pumpAndSettle();

    // Verify past event is displayed
    expect(find.text('Past Event 1'), findsOneWidget);
    expect(find.byType(SubscriptionEventCard), findsOneWidget);

    // Upcoming event should not be visible
    expect(find.text('Upcoming Event 1'), findsNothing);
  });

  testWidgets('SubscriptionsScreen shows empty state when no events',
      (WidgetTester tester) async {
    // Override mocks to return empty lists
    when(mockEventController.getUpcomingSubscribedEvents()).thenReturn([]);
    when(mockEventController.getPastSubscribedEvents()).thenReturn([]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EventController>.value(
          value: mockEventController,
          child: const SubscriptionsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state for upcoming events
    expect(find.text('No tienes eventos próximos'), findsOneWidget);
    expect(find.text('Suscríbete a eventos próximos para verlos aquí'),
        findsOneWidget);

    // Tap on "Pasados" tab
    await tester.tap(find.text('Pasados'));
    await tester.pumpAndSettle();

    // Verify empty state for past events
    expect(find.text('No tienes eventos pasados'), findsOneWidget);
    expect(find.text('Tus eventos pasados aparecerán aquí'), findsOneWidget);
  });

  testWidgets('SubscriptionsScreen refresh button works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EventController>.value(
          value: mockEventController,
          child: const SubscriptionsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the refresh button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify loadEvents was called
    verify(mockEventController.loadEvents())
        .called(2); // Once in initState, once on button press
  });
}
