import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class LSearchContainer extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPostIcon;
  final VoidCallback postIconFunction;
  final TextEditingController? controller;
  final bool showBorder;
  final bool readOnly;

  const LSearchContainer({
    super.key,
    required this.text,
    required this.icon,
    required this.isPostIcon,
    required this.postIconFunction,
    this.controller,
    this.showBorder = true,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: dark ? LColors.textWhite : LColors.black),
        suffixIcon: isPostIcon
            ? Icon(icon, color: dark ? LColors.textWhite : LColors.black)
            : null,
        hintText: text,
        hintStyle: TextStyle(color: dark ? LColors.textWhite : LColors.black),
        filled: true,
        fillColor: dark
            ? LColors.white.withOpacity(0.1)
            : LColors.white.withOpacity(0.9),
        border: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(LSizes.cardRadiusMd),
                borderSide: BorderSide(
                  width: LSizes.dividerHeight,
                  color: dark
                      ? LColors.textWhite.withOpacity(0.5)
                      : LColors.black.withOpacity(0.5),
                ),
              )
            : const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LSizes.cardRadiusMd),
          borderSide: BorderSide(
            width: LSizes.dividerHeight,
            color: dark ? LColors.textWhite : LColors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LSizes.cardRadiusMd),
          borderSide: BorderSide(
            width: LSizes.dividerHeight,
            color: dark
                ? LColors.textWhite.withOpacity(0.1)
                : LColors.black.withOpacity(0.5),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: LSizes.sm,
          horizontal: LSizes.md,
        ),
      ),
    );
  }
}
