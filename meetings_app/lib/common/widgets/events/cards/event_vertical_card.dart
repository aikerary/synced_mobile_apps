import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/events/info/event_chip.dart';
import 'package:meetings_app/common/widgets/events/info/event_info.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class LEventVerticalCard extends StatelessWidget {
  final String image;
  final String title;
  final DateTime date;
  final String location;
  final List<String> tracks;
  final VoidCallback? onTap;
  final Event event;

  const LEventVerticalCard({
    super.key,
    required this.event,
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    required this.tracks,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 350,
          width: 280,
          decoration: BoxDecoration(
            color: dark ? LColors.accent2 : LColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack para la imagen y el botón de alertas
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 165,
                    ),
                  ),
                  // Botón circular que cambia de icono al presionarse
                  //Positioned( top: 10, right: 10, child: AlertToggleButton(title: title),),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: LSizes.lg, vertical: LSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips de los dos primeros tracks (si existen)
                    if (tracks.isNotEmpty)
                      Row(
                        children: List.generate(
                          tracks.length >= 2 ? 2 : tracks.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: LSizes.sm / 2),
                            child: TrackChip(context, tracks[index]),
                          ),
                        ),
                      ),
                    const SizedBox(height: LSizes.sm),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            color: dark ? LColors.textWhite : LColors.dark,
                          ),
                    ),
                    const SizedBox(height: LSizes.sm),
                    LEventDetail(
                      information: LHelperFunctions.formatDate(date),
                      icon: Icons.calendar_today,
                    ),
                    LEventDetail(
                      information: LHelperFunctions.formatTime(date),
                      icon: Icons.timelapse,
                    ),
                    LEventDetail(
                      information: location,
                      icon: Icons.location_on,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


