import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/screens/all_events/all_events.dart';
import 'package:meetings_app/utils/constants/colors.dart';

class TrackCardWidget extends StatelessWidget {
  final Track track;
  final bool dark;
  const TrackCardWidget({
    super.key,
    required this.track,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a AllEventsScreen con el trackName.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllEventsScreen(trackName: track.nombre),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: dark ? LColors.accent2 : LColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          track.nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(color: LColors.textWhite, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}