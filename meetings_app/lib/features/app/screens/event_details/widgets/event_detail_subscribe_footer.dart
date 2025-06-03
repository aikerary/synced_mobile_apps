import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/utils/constants/colors.dart';

class SubscribeFooter extends StatefulWidget {
  const SubscribeFooter({
    super.key,
    required this.dark,
    required this.event,
  });

  final bool dark;
  final Event event;

  @override
  State<SubscribeFooter> createState() => _SubscribeFooterState();
}

class _SubscribeFooterState extends State<SubscribeFooter> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Usar Provider para acceder al controlador
    final eventController = Provider.of<EventController>(context);
    final isSubscribed = eventController.isSubscribed(widget.event.id ?? 0);

    // Recuperar el evento nuevamente para tener los datos actualizados
    final updatedEvent = eventController.getEventById(widget.event.id ?? 0);
    Event currentEvent = updatedEvent ?? widget.event;

    final cuposRestantes =
        currentEvent.maxParticipantes - currentEvent.suscritos;
    final cuposAgotados = cuposRestantes <= 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Información de asistentes y cupos restantes
        Column(
          mainAxisSize: MainAxisSize.min, // Altura mínima
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${currentEvent.suscritos}/${currentEvent.maxParticipantes} asistentes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.dark ? LColors.textWhite : LColors.dark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              cuposRestantes > 0
                  ? 'Cupos restantes: $cuposRestantes'
                  : 'No hay cupos disponibles',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cuposRestantes > 0
                        ? (widget.dark ? LColors.textWhite : LColors.darkGrey)
                        : LColors.error,
                  ),
            ),
          ],
        ),
        const Spacer(),
        // Botón de suscripción
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSubscribed
                ? LColors.error
                : (cuposAgotados ? LColors.darkGrey : LColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: (cuposAgotados && !isSubscribed) || _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    bool success;
                    if (isSubscribed) {
                      // Cancelar suscripción
                      success = await eventController
                          .unsubscribeFromEvent(currentEvent.id ?? 0);
                      if (success) {
                        _showSnackBar('Suscripción cancelada');
                      } else {
                        _showSnackBar('Error al cancelar la suscripción',
                            isError: true);
                      }
                    } else {
                      // Suscribirse
                      success = await eventController
                          .subscribeToEvent(currentEvent.id ?? 0);
                      if (success) {
                        _showSnackBar('¡Te has suscrito al evento!');
                      } else if (cuposAgotados) {
                        _showSnackBar('No hay cupos disponibles',
                            isError: true);
                      } else {
                        _showSnackBar('Error al suscribirse al evento',
                            isError: true);
                      }
                    }
                  } catch (e) {
                    print('Error en suscripción: $e');
                    _showSnackBar('Error inesperado: $e', isError: true);
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isSubscribed
                      ? 'Cancelar suscripción'
                      : (cuposAgotados ? 'Sin cupos' : 'Suscribirse'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LColors.textWhite,
                        fontSize: 14,
                      ),
                ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LColors.error : LColors.primary,
      ),
    );
  }
}
