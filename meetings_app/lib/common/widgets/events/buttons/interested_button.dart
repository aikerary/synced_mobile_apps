import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class LInterestedButton extends StatelessWidget {
  final VoidCallback? onTap; // Parámetro opcional para manejar el clic

  const LInterestedButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    
    return InkWell(
      onTap: onTap, // Hace el botón clickeable
      borderRadius: BorderRadius.circular(8), // Efecto de onda en el borde
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: LSizes.sm, vertical: LSizes.sm),
        decoration: BoxDecoration(
          color: dark ? LColors.accent2.withValues(alpha: 1.2) : LColors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Interested',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LColors.primary,
          ),
        ),
      ),
    );
  }
}
