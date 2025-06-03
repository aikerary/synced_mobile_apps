import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetings_app/common/widgets/loaders/animation_loader.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

import '../constants/colors.dart';

class TFullScreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: LHelperFunctions.isDarkMode(Get.context!)
              ? LColors.dark
              : LColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              LAnimationLoaderWidget(
                text: text,
                animation: animation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
