import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final Function(double)? onRatingChanged;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRating({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return InkWell(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: size,
            color: index < rating
                ? activeColor ?? LColors.warning
                : inactiveColor ?? Colors.grey,
          ),
        );
      }),
    );
  }
}
