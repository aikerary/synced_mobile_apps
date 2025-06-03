import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/circular_container.dart';


class LPrimaryHeaderContainer extends StatelessWidget {
  const LPrimaryHeaderContainer({
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
    return LCurvedEdgeWidget(
      child: Container(
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
              if (defaultFigures) ...[
                Positioned(top: -100, right: -200, child: LCircularContainer(width: 400, height: 400, radius: 400, backgraundColor: LColors.accent)),
                Positioned(top: 70, right: 120, child: LCircularContainer(width: 300, height: 300, radius: 300, backgraundColor: LColors.secondary)),
                Positioned(top: -300, right: 40, child: LCircularContainer(width: 500, height: 500, radius: 500, backgraundColor: LColors.primary)),
              ],
              child
            ],
          ),
        ),
      ),
    );
  }
}

