import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:meetings_app/features/app/controllers/calendar_controller.dart';

class CalendarEventList extends StatelessWidget {
  const CalendarEventList({
    super.key,
    required DateTime selectedDay,
    required this.controller,
  }) : _selectedDay = selectedDay;

  final DateTime _selectedDay;
  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final events = controller.getEventsForDay(_selectedDay);
    if (events.isEmpty) {
      return const Center(
        child: Text('No hay eventos para esta fecha'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final eventInstance = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              // Navegar al EventDetailScreen pasando el evento como parámetro.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: eventInstance),
                ),
              );
            },
            title: Text(eventInstance.titulo),
            subtitle: Text(
              'Evento para ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
            ),
            leading: const Icon(Icons.event),
          ),
        );
      },
    );
  }
}