import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/device/device_utility.dart';
import '../sync/sync_indicator.dart';

class LAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.showSyncIndicator = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool showSyncIndicator;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? Container(
            decoration: BoxDecoration(
              color: LColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Iconsax.arrow_left,
                  color: LColors.dark,
                )),
          )
          : leadingIcon != null
              ? IconButton(
                  onPressed: leadingOnPressed, icon: Icon(leadingIcon, color: Colors.white))
              : null,
      title: title,
      actions: [
        if (showSyncIndicator) 
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: SyncIndicator(showText: false),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  // Todo: implement preferredSize
  Size get preferredSize => Size.fromHeight(LDevicesUtils.getAppBarHeight());
}
