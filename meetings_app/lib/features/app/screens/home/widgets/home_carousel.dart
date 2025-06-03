import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/events/cards/event_vertical_card.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/utils/constants/sizes.dart';

class LEventCarousel extends StatelessWidget {
  const LEventCarousel({super.key});

  final String image = 'assets/images/event.jpg'; // URL de la imagen

  Future<Map<String, dynamic>> _loadData() async {
    final events = await EventRepository().loadEvents();
    final tracks = await EventRepository().loadDummyTracks();
    return {'events': events, 'tracks': tracks};
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360, // Altura del carrusel
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar eventos: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            // Se obtienen la lista de eventos desde el Future.
            final List<Event> events = snapshot.data!['events'];
            // Toma solo los primeros 5 eventos.
            final List<Event> firstFiveEvents = events.take(5).toList();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: LSizes.lg * 1.5), // Margen izquierdo
                  ...firstFiveEvents.map((event) {
                    // Use the trackNames from the event directly
                    List<String> eventTracks =
                        event.trackNames.take(2).toList();
                    return Padding(
                      padding: const EdgeInsets.only(right: LSizes.lg),
                      child: LEventVerticalCard(
                        image: image,
                        title: event.titulo,
                        location: event.trackNames.isNotEmpty
                            ? event.trackNames.join(', ')
                            : 'Track no especificado',
                        date: event.fecha,
                        tracks: eventTracks,
                        event: event,
                      ),
                    );
                  }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
