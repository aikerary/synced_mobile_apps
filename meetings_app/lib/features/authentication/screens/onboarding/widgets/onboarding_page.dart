import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/features/authentication/controllers/onboarding/onboarding_controller.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.title,
    required this.subTitle,
  });

  final String title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          
          // Circular background
          Positioned(
            top: -240,
            left: -400,
            child: LCircularContainer(width: 600, height: 600, radius: 600, backgraundColor: LColors.accent4),
          ),
          Positioned(
            top: -150,
            right: -120,
            child: LCircularContainer(backgraundColor: LColors.accent,),
          ),
          Positioned(
            top: 195,
            right: 80,
            child: LCircularContainer(width: 100, height: 100, radius: 100, backgraundColor: LColors.secondary),
          ),
          Positioned(
            bottom: -180,
            left: 150,
            child: LCircularContainer(width: 400, height: 400, radius: 200, backgraundColor: LColors.accent),
          ),
          Positioned(
            bottom: -100,
            left: -150,
            child: LCircularContainer(width: 400, height: 400, radius: 400, backgraundColor: LColors.secondary),
          ),
          Padding(
            padding: const EdgeInsets.all(LSizes.defaultSpace*3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LColors.light,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: LSizes.spaceBtwItems),
                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LColors.light,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: LSizes.spaceBtwItems),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric( vertical: 12), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => OnBoardingController.instance.completeOnBoarding(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Comenzar",
                        style: TextStyle(
                          color: Colors.white, // Color del texto
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white, // Color del ícono
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] 
      ),
    );
  }
}
