import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/custom_shapes/curved_edges/curved_edges.dart';

class LCurvedEdgeWidget extends StatelessWidget {
  const LCurvedEdgeWidget({
    super.key,
    this.child
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: LCustomCurvedEdges(),
      child: child,
    );
  }
}