import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/common/widgets/events/cards/past_event_horizontal_card.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';

class LPastEventList extends StatelessWidget {
  const LPastEventList({super.key});

  @override
  Widget build(BuildContext context) {
    final eventRepo = Provider.of<EventRepository>(context, listen: false);
    return FutureBuilder<List<Event>>(
      future: eventRepo.loadEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          final currentDate = DateTime.now();
          // Filtra los eventos cuya fecha es anterior a la fecha actual
          final List<Event> pastEvents = snapshot.data!.where(
            (event) => event.fecha.isBefore(currentDate)
          ).toList();

          // Toma los primeros 6 eventos que cumplen la condición
          final List<Event> firstSixPastEvents = pastEvents.take(6).toList();

          return Column(
            children: firstSixPastEvents
                .map((event) => PastEventHorizontalCard(event: event))
                .toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
