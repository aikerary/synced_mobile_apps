import 'package:flutter/material.dart';

import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';

class LEventDetail extends StatelessWidget {
  const LEventDetail({
    super.key,
    required this.information,
    required this.icon,
  });

  final IconData icon;
  final String information;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: LColors.primary, size: 16),
        const SizedBox(width: LSizes.sm/2),
        Text(information, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: LColors.primary,
        )),
      ],
    );
  }
}
