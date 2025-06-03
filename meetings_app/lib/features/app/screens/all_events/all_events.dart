import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/screens/all_events/widgets/filter.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/events/cards/stylish_event_card.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

// Filtros posibles (índices)
enum EventDateFilter { all, thisWeek, thisMonth, nextMonth, past }

class AllEventsScreen extends StatefulWidget {
  final String? trackName;
  // Si trackName es nulo, muestra todos los eventos; de lo contrario, muestra solo los eventos del track.
  // defaultFilter: Por defecto se selecciona "all" (futuros), pero si se pasa, se usará ese filtro, por ejemplo: EventDateFilter.past.
  final EventDateFilter? defaultFilter;

  const AllEventsScreen({super.key, this.trackName, this.defaultFilter});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  late Future<List<Event>> _futureEvents;
  int _selectedFilterIndex =
      0; // 0: All, 1: This Week, 2: This Month, 3: Next Month, 4: Past

  @override
  void initState() {
    super.initState();
    // Establecer filtro por defecto a partir del parámetro, si se pasa.
    _selectedFilterIndex = widget.defaultFilter?.index ?? 0;
    final eventRepo = Provider.of<EventRepository>(context, listen: false);
    _futureEvents = eventRepo.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackName ?? "All Events"),
        backgroundColor: dark ? LColors.dark : LColors.light,
      ),
      backgroundColor: dark
          ? LColors.dark.withValues(alpha: 0.95)
          : LColors.light.withValues(alpha: 0.95),
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            // Lista completa de eventos.
            List<Event> events = snapshot.data!;
            return FutureBuilder<List<Event>>(
              future: _filterByTrack(events, widget.trackName),
              builder: (context, filteredTrackSnap) {
                if (filteredTrackSnap.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (filteredTrackSnap.hasError) {
                  return Center(
                      child: Text('Error: ${filteredTrackSnap.error}'));
                }
                if (filteredTrackSnap.hasData) {
                  events = filteredTrackSnap.data!;
                  // Aplica el filtro de fecha seleccionado.
                  events = _applyDateFilter(events, _selectedFilterIndex);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila de filtros en forma de chips desplazables horizontalmente.
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilterChipsRow(
                          selectedFilterIndex: _selectedFilterIndex,
                          onFilterSelected: (newIndex) {
                            setState(() {
                              _selectedFilterIndex = newIndex;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 4),
                        child: Text(
                          '${events.length} events found',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    dark ? LColors.textWhite : LColors.darkGrey,
                              ),
                        ),
                      ),
                      // Lista de eventos filtrados.
                      Expanded(
                        child: events.isEmpty
                            ? Center(
                                child: Text(
                                  "No events found",
                                  style: TextStyle(
                                    color: dark
                                        ? LColors.textWhite
                                        : LColors.darkGrey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EventDetailScreen(event: event),
                                          ),
                                        );
                                      },
                                      child: StylishEventCard(event: event),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Filtra eventos según el track, si trackName no es null.
  Future<List<Event>> _filterByTrack(
      List<Event> events, String? trackName) async {
    if (trackName == null) return events;
    // Filter events by trackNames field since Track no longer has eventos field
    return events
        .where((event) => event.trackNames
            .any((name) => name.toLowerCase() == trackName.toLowerCase()))
        .toList();
  }

  /// Aplica el filtro de fecha al listado de eventos.
  /// 0 => All, 1 => This Week, 2 => This Month, 3 => Next Month, 4 => Past
  List<Event> _applyDateFilter(List<Event> events, int index) {
    final now = DateTime.now();
    switch (index) {
      case 1: // This Week
        final oneWeekLater = now.add(const Duration(days: 7));
        return events
            .where(
                (e) => e.fecha.isAfter(now) && e.fecha.isBefore(oneWeekLater))
            .toList();
      case 2: // This Month
        return events
            .where((e) =>
                e.fecha.year == now.year &&
                e.fecha.month == now.month &&
                e.fecha.isAfter(now))
            .toList();
      case 3: // Next Month
        final nextMonth = (now.month == 12) ? 1 : now.month + 1;
        final nextYear = (now.month == 12) ? now.year + 1 : now.year;
        return events
            .where(
                (e) => e.fecha.year == nextYear && e.fecha.month == nextMonth)
            .toList();
      case 4: // Past
        return events.where((e) => e.fecha.isBefore(now)).toList();
      case 0: // All (por defecto, mostramos solo los futuros).
      default:
        return events.where((e) => e.fecha.isAfter(now)).toList();
    }
  }
}
