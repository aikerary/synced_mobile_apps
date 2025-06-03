import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/events/info/event_info.dart';
import 'package:meetings_app/common/widgets/events/rate/star_rating.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/screens/event_details/event_detail.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class PastEventHorizontalCard extends StatelessWidget {
  final Event event;

  const PastEventHorizontalCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(bottom: LSizes.spaceBtwItems),
          decoration: BoxDecoration(
            color: dark ? LColors.accent2 : LColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.titulo,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontSize: 16,
                              color: dark ? LColors.textWhite : LColors.dark,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: LSizes.sm / 2),
                      LEventDetail(
                        information: LHelperFunctions.formatDate(event.fecha),
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: LSizes.sm),
                      // Usar Consumer para actualizar el rating en la card
                      Consumer<EventController>(
                        builder: (context, eventController, child) {
                          final averageRating = eventController
                              .getAverageRatingForEvent(event.id ?? 0);
                          return StarRating(rating: averageRating);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
