import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/events/cards/stylish_event_card.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:meetings_app/features/app/screens/subscriptions/widgets/selector.dart';
import 'package:meetings_app/features/app/screens/subscriptions/widgets/subscription_event_card.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  // Boolean para saber si se muestra la lista de eventos próximos o pasados.
  bool isUpcomingSelected = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final eventController =
          Provider.of<EventController>(context, listen: false);
      await eventController
          .loadEvents(); // Cargar todos los eventos si no están cargados
    } catch (e) {
      print('Error cargando eventos: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    final eventController =
        Provider.of<EventController>(context); // Listen: true por defecto

    // Filtrar eventos según la selección (próximos o pasados)
    final List<Event> subscribedEvents = isUpcomingSelected
        ? eventController.getUpcomingSubscribedEvents()
        : eventController.getPastSubscribedEvents();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Suscripciones"),
        backgroundColor: dark ? LColors.dark : LColors.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      backgroundColor: dark
          ? LColors.dark.withValues(alpha: 0.95)
          : LColors.light.withValues(alpha: 0.95),
      body: Column(
        children: [
          // Selector de eventos próximos o pasados
          EventSubscriptionsSelector(
            isUpcomingSelected: isUpcomingSelected,
            onSelectUpcoming: () {
              setState(() {
                isUpcomingSelected = true;
              });
            },
            onSelectPast: () {
              setState(() {
                isUpcomingSelected = false;
              });
            },
          ),

          // Lista de eventos suscritos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : subscribedEvents.isEmpty
                    ? _buildEmptyState(dark, isUpcomingSelected)
                    : _buildEventsList(subscribedEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool dark, bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.event_available : Icons.history,
            size: 72,
            color: dark ? LColors.accent3 : LColors.darkGrey,
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming
                ? 'No tienes eventos próximos'
                : 'No tienes eventos pasados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: dark ? LColors.textWhite : LColors.dark,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isUpcoming
                  ? 'Suscríbete a eventos próximos para verlos aquí'
                  : 'Tus eventos pasados aparecerán aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? LColors.textWhite : LColors.dark,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: 8), // Padding reducido porque ya lo tiene la tarjeta
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        // Usando la nueva SubscriptionEventCard en lugar de StylishEventCard
        return SubscriptionEventCard(
          event: event,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            ).then((_) {
              // Actualizar al volver
              setState(() {});
            });
          },
        );
      },
    );
  }
}
