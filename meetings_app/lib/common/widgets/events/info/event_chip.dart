import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

/// Construye un chip/label simple con estilos básicos.
Widget TrackChip(BuildContext context, String label) {
  final dark = LHelperFunctions.isDarkMode(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: dark ? LColors.primary : LColors.accent2,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LColors.white,
            fontWeight: FontWeight.w500,
          ),
    ),
  );
}