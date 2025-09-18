import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import '../controller/accounts_controller.dart';

class InspireView extends GetView<AccountsController> {
  const InspireView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountsController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 0.588, // 100% progress
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Which personal traits inspire you the most?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose minimum 3 qualities which speak to your soul and make a connection that much stronger. ',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Traits selection
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.traits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Obx(() => CustomCheckbox(
                      label: controller.traits[index],
                      isSelected: controller.selectedTraitIndices.contains(index),
                      onTap: () => controller.toggleTrait(index),
                      titleFontSize: 16.0,
                      descriptionFontSize: 14.0,
                    ));
              },
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.selectedTraitIndices.isNotEmpty && controller.selectedTraitIndices.length < 3)
                return Text(
                  'Select ${3 - controller.selectedTraitIndices.length} more to continue',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.amber[300],
                    fontSize: 14.0,
                  ),
                );
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Obx(() => CustomGradientButton(
          text: 'Next',
          onPressed: controller.isInspireButtonEnabled ? () {
            // Navigate to Faith/Belief view
            Get.toNamed(AppRoutes.faithBeliefView);
          } : null,
          enabled: controller.isInspireButtonEnabled,
        )),
      ),
    );
  }
}