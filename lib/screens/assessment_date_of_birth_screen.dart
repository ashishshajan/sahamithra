import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/global_utils.dart';
import 'date_of_birth_screen.dart';

/// Route host: reads [Get.arguments] and shows [DateOfBirthScreen], then
/// persists DOB and replaces this route with the target assessment.
///
/// Arguments map:
/// - `nextRoute` (String, required)
/// - `title`, `subtitle`, `assessmentName`, `assessmentDescription` (String)
/// - `primaryColor`, `secondaryColor` ([Color])
/// - `dobFirstDate`, `dobLastDate` ([DateTime], optional)
class AssessmentDateOfBirthScreen extends StatelessWidget {
  const AssessmentDateOfBirthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is! Map) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return const SizedBox.shrink();
    }

    final map = Map<String, dynamic>.from(args);
    final nextRoute = map['nextRoute'];
    if (nextRoute is! String || nextRoute.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return const SizedBox.shrink();
    }

    final primary = map['primaryColor'];
    final secondary = map['secondaryColor'];
    if (primary is! Color || secondary is! Color) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return const SizedBox.shrink();
    }

    final dobFirst = map['dobFirstDate'];
    final dobLast = map['dobLastDate'];

    return DateOfBirthScreen(
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      assessmentName: map['assessmentName']?.toString() ?? '',
      assessmentDescription: map['assessmentDescription']?.toString() ?? '',
      primaryColor: primary,
      secondaryColor: secondary,
      dobFirstDate: dobFirst is DateTime ? dobFirst : null,
      dobLastDate: dobLast is DateTime ? dobLast : null,
      onBack: () => Get.back(),
      onNext: (dobDdMmYyyy) async {
        final utils = GlobalUtils();
        final hasSession = utils.token?.isNotEmpty ?? false;
        if (hasSession) {
          await utils.setChildDob(dobDdMmYyyy);
        } else if (utils.isGuestUser) {
          await utils.setGuestDob(dobDdMmYyyy);
        } else {
          await utils.setChildDob(dobDdMmYyyy);
        }
        Get.offNamed(nextRoute);
      },
    );
  }
}
