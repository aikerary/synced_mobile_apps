import 'package:flutter/material.dart';

class LSectionHeading extends StatelessWidget {
  const LSectionHeading({
    super.key,
    this.textColor,
    this.showActionButton = true,
    this.isDetailTitle = false,
    required this.title,
    this.buttonTitle = "See all",
    this.onPressed,
  });

  final Color? textColor;
  final bool showActionButton;
  final bool isDetailTitle;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: isDetailTitle
                ? Theme.of(context).textTheme.headlineLarge!.apply(color: textColor)
                : Theme.of(context).textTheme.headlineSmall!.apply(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (showActionButton)
          TextButton(onPressed: onPressed, child: Text(buttonTitle))
      ],
    );
  }
}
