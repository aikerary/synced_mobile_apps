import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class EventSubscriptionsSelector extends StatelessWidget {
  const EventSubscriptionsSelector({
    super.key,
    required this.isUpcomingSelected,
    required this.onSelectUpcoming,
    required this.onSelectPast,
  });

  final bool isUpcomingSelected;
  final VoidCallback onSelectUpcoming;
  final VoidCallback onSelectPast;

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Container(
      height: 50,
      color: dark ? LColors.accent3 : LColors.light,
      child: Row(
        children: [
          // Botón para "Upcoming"
          Expanded(
            child: InkWell(
              onTap: onSelectUpcoming,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isUpcomingSelected
                      ? (dark ? LColors.white.withValues(alpha: 0.1) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Proximos',
                  style: TextStyle(
                    color: isUpcomingSelected
                        ? (dark ? LColors.textWhite : LColors.dark)
                        : (dark ? LColors.textWhite : LColors.darkGrey),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Botón para "Past"
          Expanded(
            child: InkWell(
              onTap: onSelectPast,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: !isUpcomingSelected
                      ? (dark ? LColors.white.withValues(alpha: 0.1) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Pasados',
                  style: TextStyle(
                    color: !isUpcomingSelected
                        ? (dark ? LColors.textWhite : LColors.dark)
                        : (dark ? LColors.textWhite : LColors.darkGrey),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
