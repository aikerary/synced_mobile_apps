import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetings_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:meetings_app/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:meetings_app/utils/constants/text_strings.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnBoardingPage(title: LTexts.onBoardingTitle1, subTitle: LTexts.onBoardingSubTitle1),
        ],
      )
    );
  }
}