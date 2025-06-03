import 'package:flutter/material.dart';
import 'package:meetings_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: LDevicesUtils.getAppBarHeight(),
      right: LSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.completeOnBoarding(),
        child: const Text('Get Started')

      ),
    );
  }
}