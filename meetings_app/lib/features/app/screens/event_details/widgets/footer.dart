import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/event_details/widgets/event_detail_subscribe_footer.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class EventDetailFooter extends StatelessWidget {
  const EventDetailFooter({
    super.key,
    required this.event,
    required this.pastEvent,
  });

  final Event event;
  final bool pastEvent;

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? LColors.dark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      // Si es un evento pasado, mostramos botón para calificar
      // Si es futuro, mostramos botón para suscribirse
      child: pastEvent
          ? const SizedBox(
              height:
                  0) // No mostramos nada aquí - los comentarios están en el cuerpo principal
          : SubscribeFooter(dark: dark, event: event),
    );
  }
}
