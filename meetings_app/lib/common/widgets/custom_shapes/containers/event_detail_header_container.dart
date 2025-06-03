import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';


class LEventDetailHeaderContainer extends StatelessWidget {
  const LEventDetailHeaderContainer({
    super.key,
    required this.child,
    this.defaultFigures = true,
    this.height = 250,
    this.image,
  });

  final Widget child;
  final bool defaultFigures;
  final double height;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LColors.light, // Se mueve aquí el color
        image: image != null
            ? DecorationImage(
                image: AssetImage(image!),
                fit: BoxFit.cover,
              )
            : null, // Si `image` es null, no se agrega la imagen
      ),
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            child
          ],
        ),
      ),
    );
  }
}

