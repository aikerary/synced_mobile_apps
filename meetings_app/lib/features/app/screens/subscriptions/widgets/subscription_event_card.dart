import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/events/info/event_info.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class SubscriptionEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const SubscriptionEventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Márgenes externos mejorados para no tocar los bordes de la pantalla
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: dark ? LColors.accent2 : LColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0.5,
            ),
          ],
          // Borde destacado para eventos suscritos
          border: Border.all(
            color: LColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Imagen del evento con esquinas redondeadas
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), // Ajustado por el borde
                topRight: Radius.circular(18),
              ),
              child: SizedBox(
                height: 160, // Altura un poco mayor para la imagen
                width: double.infinity,
                child: Stack(
                  children: [
                    // Imagen con filtro de oscurecimiento para mejorar contraste
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.15),
                        BlendMode.darken,
                      ),
                      child: Image.asset(
                        currentEvent.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Indicador de evento pasado si aplica
                    if (isPastEvent)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                    // Indicador de "Suscrito" siempre visible
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: LColors.primary.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
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
                    // Título del evento superpuesto sobre la imagen
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          currentEvent.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Información del evento con padding mejorado
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detalles del evento
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fecha con estilo mejorado
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color:
                                      dark ? LColors.primary : LColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  LHelperFunctions.formatDate(
                                      currentEvent.fecha),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: dark
                                            ? LColors.textWhite
                                            : LColors.dark,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Lugar con estilo mejorado
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color:
                                      dark ? LColors.primary : LColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currentEvent.trackNames.isNotEmpty
                                        ? currentEvent.trackNames.join(', ')
                                        : 'Track no especificado',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: dark
                                              ? LColors.light
                                              : LColors.darkGrey,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Capacidad y asistentes con estilo mejorado
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: dark
                              ? LColors.dark.withOpacity(0.3)
                              : LColors.light.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: cuposAgotados
                              ? Border.all(color: LColors.error, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: cuposAgotados
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
                                    color: cuposAgotados
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
                  // Muestra "Hora" del evento
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: dark ? LColors.primary : LColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LHelperFunctions.formatTime(currentEvent.fecha),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark ? LColors.light : LColors.darkGrey,
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
