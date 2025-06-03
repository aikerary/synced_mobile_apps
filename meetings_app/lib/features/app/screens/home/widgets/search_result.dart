import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Event> filteredEvents;
  const SearchResultsWidget({super.key, required this.filteredEvents});

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    if (filteredEvents.isEmpty) {
      return Center(
        child: Text(
          'No hay resultados',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: dark ? LColors.textWhite : LColors.black,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(LSizes.md),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final isPast = event.fecha.isBefore(DateTime.now());
        return ListTile(
          title: Text(
            event.titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: dark ? LColors.textWhite : LColors.black,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.tema,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark
                          ? LColors.textWhite.withOpacity(0.7)
                          : LColors.black.withOpacity(0.7),
                    ),
              ),
              if (isPast)
                Text(
                  'Evento pasado',
                  style: TextStyle(
                    color: LColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: LSizes.fontSizeSm,
                  ),
                ),
            ],
          ),
          leading: Icon(
            Iconsax.calendar_1,
            size: LSizes.iconMd,
            color: dark ? LColors.primary : LColors.primary,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: LSizes.sm,
            horizontal: LSizes.md,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event)),
            );
          },
        );
      },
    );
  }
}
