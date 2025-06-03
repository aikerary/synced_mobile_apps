import 'package:flutter/material.dart';

import 'package:meetings_app/utils/constants/colors.dart';

class LAttendeesPreviewImages extends StatelessWidget {
  const LAttendeesPreviewImages({
    super.key,
    required this.showCounter,
    required this.maxVisible,
    required this.attendees,
    required this.remainingCount,
  });

  final bool showCounter;
  final int maxVisible;
  final List<String> attendees;
  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          showCounter ? maxVisible : attendees.length,
          (index) => Transform.translate(
            offset: Offset(-index * 9.0, 0), // Superposición de avatares
            child: CircleAvatar(
              backgroundImage: AssetImage(attendees[index]),
              radius: 12,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        if (showCounter)
          Transform.translate(
            offset: Offset(-maxVisible * 9.0, 0), // Alinear con los avatares
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: LColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
