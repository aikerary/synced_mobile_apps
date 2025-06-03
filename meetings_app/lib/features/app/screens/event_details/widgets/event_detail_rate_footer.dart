import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/utils/constants/colors.dart';

// NOTA: Esta clase está obsoleta. Se debe usar AddCommentSection en su lugar.
// Se mantiene solo por compatibilidad con código existente.
class RateFooter extends StatelessWidget {
  const RateFooter({
    super.key,
    required this.dark,
    required this.event,
  });

  final bool dark;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Para comentar, usa la sección de comentarios en el detalle del evento.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? LColors.textWhite : LColors.dark,
            ),
      ),
    );
  }
}
