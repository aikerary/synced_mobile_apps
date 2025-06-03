import 'package:flutter/material.dart';

import 'package:meetings_app/utils/constants/colors.dart';

/// Widget para el botón de alertas, con icono que cambia según su estado.
class AlertToggleButton extends StatefulWidget {
  final String title; // Se utiliza para identificar o notificar el evento
  const AlertToggleButton({Key? key, required this.title}) : super(key: key);

  @override
  _AlertToggleButtonState createState() => _AlertToggleButtonState();
}

class _AlertToggleButtonState extends State<AlertToggleButton> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: LColors.accent,
      radius: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          isActive ? Icons.notifications_active : Icons.notifications_none,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            isActive = !isActive;
          });
          // Aquí se pueden disparar acciones adicionales al cambiar el estado.
          if (isActive) {
            print("Alerts activated for event: ${widget.title}");
          } else {
            print("Alerts deactivated for event: ${widget.title}");
          }
        },
      ),
    );
  }
}