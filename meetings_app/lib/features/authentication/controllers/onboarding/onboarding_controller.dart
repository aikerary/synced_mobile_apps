import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:meetings_app/features/app/screens/main/main.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Guarda que el usuario ya vio el onboarding y lo redirige al login
  void completeOnBoarding() {
    final storage = GetStorage();
    storage.write('IsFirstTime', false);
    Get.offAll(() => MainScreen());
  }
}
