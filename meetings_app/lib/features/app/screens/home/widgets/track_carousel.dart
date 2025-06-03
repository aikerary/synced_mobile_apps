import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/tracks/cards/track_card.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/repository/track_repository.dart';
class TrackCarouselWidget extends StatelessWidget {
  final bool dark;
  const TrackCarouselWidget({super.key, required this.dark});

  @override
  Widget build(BuildContext context) {
    final trackRepo = Provider.of<TrackRepository>(context, listen: false);
    return FutureBuilder<List<Track>>(
      future: trackRepo.loadDummyTracks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          final tracks = snapshot.data!;
          if (tracks.isEmpty) {
            return const Text("No tracks available");
          }
          return SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return TrackCardWidget(track: track, dark: dark);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

