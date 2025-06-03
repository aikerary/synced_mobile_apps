import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/events/info/event_info.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';

class StylishEventCard extends StatelessWidget {
  final Event event;
  final bool isSubscribed;

  const StylishEventCard({
    super.key,
    required this.event,
    this.isSubscribed = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    final eventController = Provider.of<EventController>(context);

    // Intentar obtener el evento actualizado del controlador
    Event currentEvent = event;
    final updatedEvent = eventController.getEventById(event.id ?? 0);
    if (updatedEvent != null) {
      currentEvent = updatedEvent;
    }

    // Determinar si el evento es pasado o futuro
    final now = DateTime.now();
    final isPastEvent = currentEvent.fecha.isBefore(now);

    // Calcular si los cupos están agotados
    final cuposRestantes =
        currentEvent.maxParticipantes - currentEvent.suscritos;
    final cuposAgotados = cuposRestantes <= 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: LSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: dark ? LColors.accent2 : LColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            // Imagen del evento con esquinas redondeadas
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: 150, // Altura fija para la imagen
                width: double.infinity,
                child: Stack(
                  children: [
                    // Imagen
                    Image.asset(
                      currentEvent.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Indicador de evento pasado si aplica
                    if (isPastEvent)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Finalizado',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    // Indicador de evento sin cupos
                    if (!isPastEvent && cuposAgotados && !isSubscribed)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: LColors.error.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Sin cupos',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    // Indicador de suscripción si está suscrito
                    if (isSubscribed)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: LColors.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Suscrito',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Información del evento
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del evento
                  Text(
                    currentEvent.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? LColors.textWhite : LColors.dark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Detalles del evento
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fecha
                            LEventDetail(
                              information: LHelperFunctions.formatDate(
                                  currentEvent.fecha),
                              icon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 8),
                            // Tracks
                            LEventDetail(
                              information: currentEvent.trackNames.isNotEmpty
                                  ? currentEvent.trackNames.join(', ')
                                  : 'Track no especificado',
                              icon: Icons.category,
                            ),
                          ],
                        ),
                      ),
                      // Capacidad y asistentes
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: dark
                              ? LColors.dark.withOpacity(0.3)
                              : LColors.light,
                          borderRadius: BorderRadius.circular(12),
                          border: cuposAgotados && !isSubscribed
                              ? Border.all(color: LColors.error, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: cuposAgotados && !isSubscribed
                                  ? LColors.error
                                  : LColors.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentEvent.suscritos}/${currentEvent.maxParticipantes}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cuposAgotados && !isSubscribed
                                        ? LColors.error
                                        : (dark
                                            ? LColors.textWhite
                                            : LColors.dark),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
