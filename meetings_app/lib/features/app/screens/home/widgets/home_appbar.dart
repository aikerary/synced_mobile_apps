import 'package:flutter/material.dart';
import 'package:meetings_app/common/widgets/appbar/appbar.dart';
import 'package:meetings_app/utils/constants/sizes.dart';

import '../../../../../utils/constants/colors.dart';

class LHomeAppBar extends StatelessWidget {
  const LHomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LSizes.lg),
      child: LAppBar(
        actions: [
          Container(
            decoration: BoxDecoration(
              color: LColors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
